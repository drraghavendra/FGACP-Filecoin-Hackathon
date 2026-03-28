# app/crud.py
from sqlalchemy.orm import Session
from sqlalchemy import update
from .models import UserAgent
import uuid

def get_user_agents(db: Session, wallet_address: str) -> UserAgent:
    return db.query(UserAgent).filter(UserAgent.wallet_address == wallet_address).first()

def create_or_update_agent(db: Session, wallet: str, agent_id: str) -> UserAgent:
    user = get_user_agents(db, wallet)
    if not user:
        user = UserAgent(wallet_address=wallet, agent_ids=[agent_id])
        db.add(user)
    else:
        if agent_id not in user.agent_ids:
            user.agent_ids.append(agent_id)
        user.updated_at = func.now()
    db.commit()
    db.refresh(user)
    return user

def validate_wallet(wallet: str) -> bool:
    return len(wallet) == 42 and wallet.startswith('0x')
