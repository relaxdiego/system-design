from datetime import datetime

from sqlalchemy import (
    Column,
    DateTime,
    Integer,
    String,
)

from quipper.database import Base

# Admittedly this design is limited in that if we ever wanted to
# add more attributes to a conversation then we cannot do that (yet).
# It will require a redesign where the conversation itself would
# be a model on its own and its id is a foreign key to each message.


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    sender = Column(String, unique=False, index=False)
    conversation_id = Column(String, unique=False, index=True)
    message = Column(String, unique=False, index=False)
    created_at = Column(DateTime, default=datetime.utcnow)
