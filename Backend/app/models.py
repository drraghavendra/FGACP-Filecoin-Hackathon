# app/models.py
from sqlalchemy import Column, String, DateTime, ARRAY, Index
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from sqlalchemy.dialects.postgresql import ARRAY as PGArray

Base = declarative_base()

class UserAgent(Base):
    __tablename__ = "user_agents"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    wallet_address = Column(String, unique=True, index=True, nullable=False)
    agent_ids = Column(PGArray(String), default=list)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

Index('idx_wallet', UserAgent.wallet_address)
