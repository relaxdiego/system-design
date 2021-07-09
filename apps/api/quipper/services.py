from sqlalchemy.orm import Session

from quipper import (
    models,
    schemas,
)


def create_message(db: Session, message: schemas.MessageCreate):
    message = models.Message(
        sender=message.sender,
        conversation_id=message.conversation_id,
        message=message.message,
    )

    db.add(message)
    db.commit()


def get_conversation(db: Session, conversation_id: str):
    messages = db.query(models.Message) \
        .filter(models.Message.conversation_id == conversation_id) \
        .all()

    return schemas.Conversation(
        id=conversation_id,
        messages=messages
    )
