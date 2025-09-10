from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="FastAPI on Cloud Run", version="1.0.0")

class Ping(BaseModel):
    message: str = "pong"

@app.get("/healthz")
def healthz():
    return {"status": "ok"}

@app.get("/ping", response_model=Ping)
def ping():
    return Ping()

@app.get("/")
def root():
    return {"hello": "cloud run + jenkins"}
