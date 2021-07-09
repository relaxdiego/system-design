# Stuck with 3.7 due to psycopg2
FROM python:3.7-slim AS builder
WORKDIR /opt/api
COPY ./ .
RUN pip install -r requirements-dev.txt
RUN pytest

FROM python:3.7-slim
WORKDIR /opt/api
COPY ./quipper/ ./quipper/
COPY ./setup.py .
RUN pip install .

EXPOSE 80

ENTRYPOINT ["uvicorn", "--host", "0.0.0.0", "--port", "80", "--app-dir", "/opt/api/quipper", "--reload", "main:app"]
