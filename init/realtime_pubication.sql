-- Create the publication that Supabase Realtime looks for by default
DROP PUBLICATION IF EXISTS supabase_realtime;

-- Add the tables you want to broadcast over websockets
CREATE PUBLICATION supabase_realtime FOR TABLE 
    api.message, 
    api.conversation, 
    api.participant;