from typing import List
from datetime import datetime

from pydantic import BaseModel


class MessageBase(BaseModel):
    sender: str
    message: str

    # Allow this pydantic model to read from SQLAlchemy models
    class Config:
        orm_mode = True


class MessageCreate(MessageBase):
    conversation_id: str


class Message(MessageBase):
    created_at: datetime


class Conversation(BaseModel):
    id: str
    messages: List[Message]
