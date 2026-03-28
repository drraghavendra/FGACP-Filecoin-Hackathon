# app/schemas.py
from pydantic import BaseModel
from typing import List

class AgentCreate(BaseModel):
    wallet_address: str
    agent_id: str

class AgentResponse(BaseModel):
    wallet_address: str
    agent_ids: List[str]
    created_at: str

class FGACPMessage(BaseModel):
    from_did: str
    to_did: str
    payload: str
    fee_paid: str
