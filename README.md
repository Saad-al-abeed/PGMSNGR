# PGMSNGR - High-Performance SQL-Native Messenger

PGMSNGR is a state-of-the-art messaging platform built with a "Database-as-the-Backend" philosophy. By leveraging the full power of PostgreSQL and PostgREST, it eliminates the need for a traditional middle-tier application server, placing business logic and security directly where the data lives.

# Motivation

Hello. My name is Saad Al Abeed. Currently a undergraduate student pursuing a bachelor's degree in computer science and 
engineering at the Islamic University of Technology, Bangladesh. I am very interested in database systems, and I am always 
looking for ways to improve my skills in this area. I am also interested in backend development, so I have decided to build 
this project to showcase my skills in both areas. Initially, I tried learning and exploring stacks like Python Django, Node.
js, MERN etc. However, I realized that not only the learning curve just gets obsolete at one point, but also since the 
backend is seperate, mostly the database security is not built that well. A very recent youtube video came to me about the 
high versatility of PostgreSQL and PostgREST. It made me realize that with these tools, it's possible to build a fullstack 
application with robust security features, minimal boilerplate code, and at the same time, we can leverage the full 
potential of PostgreSQL. I really loved writing my own row level securities and ensuring the security of my application at
the database level with sql's power, whereas I would have to just memorize frameworks functions and syntax in Python or 
Java or whatever language it is, to implement them. The fact even frontends can be directly made using SQL and HTMX means 
a single DBMS really has the power to replace the full conventional backend, frontend stack that we see in these days. 
This is a truly revolutionary approach to software development that I believe will change the way we build web 
applications in the future. For now, to any POSTMAN or mad curl command backend testers seeing this repo, test out 
everything, go as deep as you can, if you find any vulnerability or loopholes, do let me know! I am just trying to learn 
and show my potential and consistency in being a Backend Developer and Database Administrator.


## Tech Stack

- **Core Database**: PostgreSQL 16+ (with Logical Replication)
- **API Engine**: PostgREST (Automatic RESTful API generation)
- **Real-time Engine**: Supabase Realtime (WebSocket broadcasting via PostgreSQL WAL)
- **Authentication**: JWT with Token Versioning Protocol
- **Frontend**: HTMX, Vanilla JavaScript, and Tailwind CSS (Glassmorphism UI)
- **Security**: Granular Row-Level Security (RLS) & Schema Isolation

---

## Backend Architecture & Security Deep Dive

The backbone of PGMSNGR is built on a multi-layered security architecture designed to be impenetrable. Unlike traditional apps where the backend server has "root" access to the DB, PGMSNGR treats the database as the application itself.

### 1. Schema Isolation
The database is strictly divided into two primary schemas:
- **`api` schema**: This is the only schema exposed to the web. It contains views and stored functions that serve as the API endpoints.
- **`private` schema**: This schema is completely hidden from the PostgREST interface. It contains sensitive data like `account` credentials and `password_hash`. No external request can ever touch this schema directly.

### 2. The JWT Token Versioning Protocol (HEAVY SECURITY)
Most JWT implementations suffer from a critical flaw: tokens cannot be invalidated until they expire. PGMSNGR solves this with a **Token Versioning System**.
- Every user account in `private.account` has a `token_version` integer.
- The `token_version` is baked into the JWT payload during login.
- Every single API request is intercepted by the `api.auth_profile_id()` helper function.
- This function extracts the `profile_id` and `token_version` from the request's JWT and compares it against the live `token_version` in the database.
- If the versions do not match (e.g., after a password change or remote logout), the request is instantly rejected as unauthorized, even if the JWT signature is valid.

### 3. Row-Level Security (RLS)
Security is enforced at the row level, not the application level.
- **Conversations**: Users can only see conversations where they are a registered participant.
- **Messages**: Users can only read messages belonging to their conversations and can only edit/delete messages where they are the `sender_id`.
- **Blocks**: The system automatically filters out and prevents interactions between users who have blocked each other using cross-referenced triggers.

---

## API Reference (Swagger-Style)

All endpoints expect the `Authorization: Bearer <token>` header unless otherwise specified.

### Authentication Endpoints

#### POST /rpc/register_account
**Description**: Registers a new user and creates their profile.
**Request Body**:
- `_email` (text): Valid email address.
- `_password` (text): Plaintext password (hashed using `crypt` and `gen_salt` in-DB).
- `_display_name` (text): User's public name.
**Response**: 200 OK with the created `api.profile` object.

#### POST /rpc/authenticate
**Description**: Authenticates a user and returns a 7-day JWT.
**Request Body**:
- `_email` (text): User email.
- `_password` (text): User password.
**Response**: 200 OK with `api.jwt_token` (contains `token` string).

#### POST /rpc/change_password
**Description**: Securely updates the user's password and invalidates all existing sessions.
**Security**: Triggers a `token_version` increment.
**Request Body**:
- `_new_password` (text): The new password.
**Response**: 204 No Content.

### Messaging & Social Endpoints

#### GET /inbox
**Description**: Retrieves the authenticated user's active conversation list.
**Logic**: Returns the `api.inbox` view, which dynamically aggregates the latest message, sender info, and unread status.
**Response**: JSON array of conversation objects.

#### GET /archive
**Description**: Retrieves conversations that the user has hidden/archived.
**Logic**: Returns the `api.archive` view.
**Response**: JSON array of hidden conversation objects.

#### POST /rpc/create_chat
**Description**: Initializes a 1-on-1 Direct Message session.
**Logic**: Checks for mutual blocks before creation. If a chat exists but was hidden, it reactivates it.
**Request Body**:
- `target_profile_id` (uuid): The profile ID of the user to chat with.
**Response**: 200 OK with the `conversation_id`.

#### POST /rpc/create_group_chat
**Description**: Creates a multi-user group chat.
**Request Body**:
- `_name` (text): Name of the group.
- `target_profile_ids` (uuid[]): Array of IDs to include.
**Response**: 200 OK with the `conversation_id`.

#### POST /message
**Description**: Sends a message to a conversation.
**Logic**: Enforced by the `enforce_message_blocks` trigger to prevent messaging blocked users.
**Request Body**:
- `conversation_id` (uuid): Target chat.
- `content` (text): Message body.
**Response**: 201 Created.

#### PATCH /message?id=eq.{id}
**Description**: Edits an existing message.
**Security**: Restricted by RLS to the original sender.
**Request Body**:
- `content` (text): Updated text.
**Response**: 204 No Content.

#### DELETE /message?id=eq.{id}
**Description**: Permanently deletes a message.
**Security**: Restricted by RLS to the original sender.
**Response**: 204 No Content.

#### POST /rpc/hide_chat
**Description**: Archives a conversation for the current user.
**Request Body**:
- `target_conv_id` (uuid): The conversation to hide.
**Response**: 204 No Content.

#### POST /rpc/unarchive_chat
**Description**: Restores a hidden conversation to the active inbox.
**Request Body**:
- `target_conv_id` (uuid): The conversation to restore.
**Response**: 204 No Content.

#### POST /block
**Description**: Blocks another user.
**Request Body**:
- `blocked_id` (uuid): The user to block.
**Response**: 201 Created.

#### DELETE /block?blocked_id=eq.{id}
**Description**: Unblocks a user.
**Response**: 204 No Content.

---
Here is an updated, enterprise-grade revision of your README section. 

From a senior engineering perspective, your read-throughput is exceptional, but the tests expose the classic vulnerability of the "Database-as-the-Backend" pattern: CPU-bound write operations (like password hashing and complex triggers) cause long-tail latency spikes. 

Here is how you can present this objectively, highlighting both the massive strengths and the identified scaling ceilings.

***

## Load Testing & Performance Architecture

To validate the "Database-as-the-Backend" philosophy, PGMSNGR is rigorously load-tested using **k6**. The tests evaluate raw throughput, concurrency scaling, and complex real-world workflows involving triggers, cryptographic functions, and Row-Level Security (RLS). 

The following results demonstrate the system's baseline performance and identify architectural ceilings for future horizontal scaling.

### 1. Single Endpoint RPS (Read Stress Test)
**Test Protocol**: Simulates 110 Virtual Users (VUs) constantly bombarding the `GET /inbox` endpoint without sleep delays for 30 seconds to measure absolute maximum Requests Per Second (RPS) and connection pool saturation.

**Results**:
* **Total Requests**: 152,089
* **Throughput**: ~5,050 RPS
* **p(95) Latency**: 29.01ms
* **Error Rate**: 0.00%

**Enterprise Assessment**: 
* **The Good**: Bypassing a traditional Node.js/Python middle tier shows immense strength here. PostgREST's Haskell-based connection pooler handles over 5,000 RPS effortlessly. Eliminating the typical ORM serialization overhead results in a p95 latency under 30ms, which is exceptional for authenticated, RLS-filtered database queries.
* **The Bottleneck**: The maximum request duration spiked to ~340ms. While the 95th percentile remained fast, this indicates that sustained, unthrottled read spam will eventually cause minor query queuing at the database engine level.

!RPS Stress Test Result

### 2. Concurrent Load Test (Batch Read Operations)
**Test Protocol**: Evaluates Connection Pool stability under gradual traffic swells. Ramps up to 110 VUs over 2 minutes, simulating human-paced interactions (1s sleep). VUs execute concurrent batch requests to both `GET /inbox` and `GET /archive`.

**Results**:
* **Total Requests**: 14,698
* **Throughput**: ~121 RPS
* **p(95) Latency**: 6.19ms
* **Error Rate**: 0.00%

**Enterprise Assessment**: 
* **The Good**: PostgreSQL’s Multi-Version Concurrency Control (MVCC) shines under human-paced loads. The system resolved 95% of batched, authenticated queries in under 6.5ms. The connection pool dynamically handled the ramp-up and ramp-down without dropping a single packet or throwing a 503 error. 
* **The Bottleneck**: At 110 VUs, the database is essentially idling. To find the true enterprise ceiling for concurrent read-locks, future tests should push this metric to 1,000+ simultaneous VUs to evaluate PostgREST's socket backpressure capabilities.

!Concurrent Load Test Result

### 3. Real-Life Simulation (Write-Heavy Workflow)
**Test Protocol**: The ultimate stress test for the Postgres logic layer. Simulates 20 distinct VUs simultaneously executing a full application lifecycle: Registration (cryptographic password hashing), Authentication (JWT minting), Inbox viewing, Chat creation (trigger execution), and Message sending.

**Results**:
* **Total Requests**: 2,000
* **Throughput**: ~32.6 RPS
* **p(95) Latency**: 16.10ms
* **Max Latency**: 407.38ms
* **Error Rate**: 0.00%

**Enterprise Assessment**: 
* **The Good**: The architecture successfully executed highly complex, multi-stage transactions entirely within PostgreSQL. Despite heavy `INSERT` operations, RLS evaluations, and trigger cascades, the workflow completed with a 0% failure rate and a stellar 16ms p95 latency. 
* **The Bottleneck**: The max latency of 407.38ms is the critical takeaway. In a DB-as-a-backend model, CPU-bound tasks like `pgcrypto` password hashing and trigger-based row insertions lock resources differently than simple reads. While 20 users writing concurrently is handled well, the 400ms tail-latency suggests that scaling to thousands of concurrent *writes* might result in thread starvation. At enterprise scale, CPU-intensive tasks (like hashing) might eventually need to be offloaded from the database layer to maintain linear write scalability.

!Real-Life Simulation Result
---

## Frontend Implementation Overview

The frontend is currently a **Work in Progress (WIP)**. It is designed as a High-Performance Single Page Application (SPA) using HTMX to bridge the gap between the REST API and the DOM.

### Current Features:
- **Server-Side Rendering (SSR) via SQL**: Complex UI components like the chat window, inbox cards, and settings dashboard are rendered directly as HTML strings within PostgreSQL functions (`api.render_chat`, `api.render_inbox`).
- **RESTful Interactivity**: Uses the `json-enc` extension to allow HTMX to communicate with PostgREST endpoints using standard JSON payloads.
- **Dynamic Theming**: Glassmorphism-inspired CSS with dark mode defaults.

### Remaining Work:
- Finalizing the group chat participant management UI.
- Integrating real-time state updates (see Future Upgrades).

---

## Roadmap & Future Upgrades

### 1. Supabase Realtime Integration (Websockets)
While the backend currently uses `pg_notify` to broadcast events, the frontend relies on polling or manual refreshes. The next major update will integrate a Realtime listener to subscribe to the `chat_stream` and `conversation_stream` channels, providing instant message delivery without page reloads.

### 2. Global User Search 
A specialized `api.search_users` RPC function is planned. It will utilize PostgreSQL's **Full-Text Search (FTS)** capabilities with `tsvector` and `tsquery` to allow users to search through thousands of profiles instantly with high relevancy.

### 3. Media Support
Implementation of an S3-compatible storage bucket integration to allow users to upload images and files, which will be stored as metadata in the `api.message` table.

### 4. End-to-End Encryption (E2EE)
Exploring the implementation of the Signal Protocol for client-side encryption, where the database only stores encrypted blobs that even the DB admins cannot read.

---

Here is the complete, polished **Deployment & Configuration** section, incorporating your custom configuration file and the recommended best practices. You can copy and paste this directly into your documentation.

***

## Deployment & Configuration

Follow these steps to set up PGMSNGR on your local machine.

### Deployment & Configuration (Docker)

The recommended way to run PGMSNGR is via Docker. This ensures that the Database, API Engine, and Realtime WebSocket server are all perfectly synchronized and configured.

### Prerequisites
Before you begin, ensure you have **Docker** and **Docker Compose** installed on your machine.

### 1. Spin up the Stack
Run the following command in the root of the project to start the entire infrastructure:

```bash
docker-compose up -d
```

### 2. Access the Application
Once the containers are healthy, open your web browser and navigate to:
**`http://localhost:3000/rpc/index`**

The `docker-compose.yml` file handles the following automatically:
- Initializes the PostgreSQL database with all required schemas, tables, and roles.
- Configures PostgREST to serve the API.
- Sets up the Supabase Realtime server for live WebSocket events.
- Enables Logical Replication for real-time data broadcasting.

---

**Security Warning**: Never share the `jwt-secret` in a production environment. For production deployments, use environment variables to manage sensitive credentials.