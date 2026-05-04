import http from 'k6/http';
import { check } from 'k6';

// ----------------------------------------------------------------------------
// 1. CONFIGURATION
// ----------------------------------------------------------------------------
// This configuration will run 110 Virtual Users (VUs) constantly for 30 seconds.
// It is designed to fire requests as quickly as possible to measure maximum RPS.
export const options = {
    vus: 110, // Number of concurrent connections hitting the endpoint
    duration: '30s',
    thresholds: {
        // We want 95% of requests to complete in under 200ms
        http_req_duration: ['p(95)<200'], 
        // We want error rate to be less than 1%
        http_req_failed: ['rate<0.01'],   
    },
};

const BASE_URL = 'http://localhost:3000';

// ----------------------------------------------------------------------------
// 2. SETUP FUNCTION (Runs exactly ONCE before the test starts)
// ----------------------------------------------------------------------------
// We need an authenticated user to test the /inbox endpoint securely.
export function setup() {
    const randomSuffix = Math.random().toString(36).substring(2, 10);
    const email = `stress_${randomSuffix}@test.com`;
    const password = 'stresspassword';

    // A. Register the user
    http.post(`${BASE_URL}/rpc/register_account`, JSON.stringify({
        _email: email,
        _password: password,
        _display_name: 'Stress Tester'
    }), {
        headers: { 'Content-Type': 'application/json' }
    });

    // B. Authenticate to get the JWT
    const authRes = http.post(`${BASE_URL}/rpc/authenticate`, JSON.stringify({
        _email: email,
        _password: password
    }), {
        headers: { 'Content-Type': 'application/json' }
    });

    // Depending on PostgREST header settings, this might return an object or array.
    // We gracefully try to extract the token string.
    let token = '';
    try {
        const body = authRes.json();
        token = Array.isArray(body) ? body[0].token : body.token;
    } catch (e) {
        console.error("Failed to parse token in setup:", authRes.body);
    }

    // Pass the token to the virtual users
    return { token: token }; 
}

// ----------------------------------------------------------------------------
// 3. DEFAULT FUNCTION (Runs repeatedly for every VU)
// ----------------------------------------------------------------------------
export default function (data) {
    // We attach the Bearer token we got from the setup() function
    const params = {
        headers: {
            'Authorization': `Bearer ${data.token}`,
            'Accept': 'application/json',
        },
    };

    // Fire a single HTTP GET request to the inbox view
    const res = http.get(`${BASE_URL}/inbox`, params);

    // Verify that the request succeeded and our RLS policies didn't block it
    check(res, {
        'is status 200': (r) => r.status === 200,
    });
}