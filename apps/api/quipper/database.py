import os

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DB_URL = f"postgresql://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASS']}@{os.environ['POSTGRES_URL']}/{os.environ['POSTGRES_DB']}"  # NOQA
engine = create_engine(DB_URL)

SessionLocal = sessionmaker(autocommit=False,
                            autoflush=False,
                            bind=engine)

Base = declarative_base()
