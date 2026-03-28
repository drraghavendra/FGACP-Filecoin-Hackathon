-- Enable UUID extension for DIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Wallets Table: Core hybrid storage (wallet -> agents mapping only)
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    address TEXT UNIQUE NOT NULL,  -- e.g., "0x1234...abcd" (lowercase)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    agent_count INTEGER DEFAULT 0 CHECK (agent_count >= 0)
);

-- Row Level Security (RLS) for wallet owners only
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Wallet owners can view/update own wallet" ON wallets
FOR ALL USING (true) WITH CHECK (true);  -- Refine with wallet auth

-- Agents Table: Links to wallets + cached on-chain data
CREATE TABLE agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    did TEXT UNIQUE NOT NULL,  -- "did:fgacp:zk1...abc"
    wallet_address TEXT NOT NULL REFERENCES wallets(address) ON DELETE CASCADE,
    name TEXT NOT NULL,  -- "Trading Bot"
    capabilities TEXT[] NOT NULL DEFAULT '{}',  -- ["stock-analysis", "trading"]
    pricing JSONB,  -- {"per_message": "0.001 ETH", "subscription": "0.1 ETH/month"}
    reputation INTEGER DEFAULT 0 CHECK (reputation >= 0),  -- Cached from ReputationSystem.sol
    stake_amount NUMERIC(36,18) DEFAULT 0,  -- Cached on-chain stake
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_agents_wallet ON agents(wallet_address);
CREATE INDEX idx_agents_capabilities ON agents USING GIN(capabilities);
CREATE INDEX idx_agents_did ON agents(did);

-- RLS: Wallet owners view own agents
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Wallet owners view own agents" ON agents
FOR SELECT USING (wallet_address = current_setting('app.current_wallet', true));

-- Agent Messages Cache: Off-chain indexing for dashboard (optional, for speed)
CREATE TABLE agent_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_did TEXT NOT NULL REFERENCES agents(did) ON DELETE CASCADE,
    to_did TEXT NOT NULL,
    filecoin_cid TEXT NOT NULL,  -- "bafybei..."
    fee_paid NUMERIC(36,18) NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    payload_hash TEXT,  -- For verification
    validated BOOLEAN DEFAULT false,
    indexed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_messages_agent ON agent_messages(agent_did);
CREATE INDEX idx_messages_timestamp ON agent_messages(timestamp);

-- Capabilities Marketplace Cache: Fast discovery (sync from AgentRegistry.sol)
CREATE TABLE capability_index (
    capability TEXT NOT NULL,
    agent_did TEXT NOT NULL REFERENCES agents(did),
    reputation INTEGER NOT NULL,
    pricing JSONB,
    PRIMARY KEY (capability, agent_did),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_capability ON capability_index(capability);

-- Sessions: Track dashboard logins (wallet sessions)
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_address TEXT NOT NULL REFERENCES wallets(address) ON DELETE CASCADE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
