# app/main.py
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from .database import engine, SessionLocal  # See below
from .crud import create_or_update_agent, get_user_agents, validate_wallet
from .schemas import AgentCreate, AgentResponse, FGACPMessage
from .blockchain import FGACPBlockchain
from dotenv import load_dotenv
import os

load_dotenv()
app = FastAPI(title="FGACP Backend")

# DB setup
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:pass@localhost/fgacp")
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

blockchain = FGACPBlockchain(os.getenv("RPC_URL"), os.getenv("PRIVATE_KEY"))

@app.post("/agents", response_model=AgentResponse)
def create_agent(agent: AgentCreate, db: Session = Depends(get_db)):
    if not validate_wallet(agent.wallet_address):
        raise HTTPException(400, "Invalid wallet address")
    user = create_or_update_agent(db, agent.wallet_address, agent.agent_id)
    return AgentResponse(
        wallet_address=user.wallet_address,
        agent_ids=user.agent_ids,
        created_at=user.created_at.isoformat()
    )

@app.get("/agents/{wallet_address}", response_model=AgentResponse)
def read_agents(wallet_address: str, db: Session = Depends(get_db)):
    if not validate_wallet(wallet_address):
        raise HTTPException(400, "Invalid wallet address")
    user = get_user_agents(db, wallet_address)
    if not user:
        raise HTTPException(404, "No agents found")
    return AgentResponse(
        wallet_address=user.wallet_address,
        agent_ids=user.agent_ids,
        created_at=user.created_at.isoformat()
    )

@app.post("/messages/validate")
def validate_fgacp_message(msg: FGACPMessage):
    if blockchain.validate_message(msg):
        return {"valid": True, "cid": "bafybei..."}  # Pin to Filecoin
    raise HTTPException(400, "Message validation failed")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
