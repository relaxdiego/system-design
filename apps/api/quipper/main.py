from fastapi import (
    Depends,
    FastAPI,
)
from fastapi.middleware.cors import CORSMiddleware

from sqlalchemy.orm import Session

from quipper import (
    models,
    schemas,
    services,
)
from quipper.database import (
    SessionLocal,
    engine,
)

# Create the tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# https://fastapi.tiangolo.com/tutorial/dependencies/dependencies-with-yield
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/healthz/", status_code=200)
def get_health():
    return {"healthy": True}


@app.post("/messages/", status_code=201)
def post_message(message: schemas.MessageCreate,
                 db: Session = Depends(get_db)):
    services.create_message(db=db, message=message)


@app.get("/conversations/{conversation_id}",
         response_model=schemas.Conversation)
def get_conversation(conversation_id: str,
                     db: Session = Depends(get_db)):
    return services.get_conversation(db=db,
                                     conversation_id=conversation_id)
