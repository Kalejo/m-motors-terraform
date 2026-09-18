from fastapi import FastAPI

app = FastAPI(
    title="M-Motors Backend",
    description="API du projet M-Motors",
    version="1.0.0",
)


@app.get("/")
def read_root():
    """Retourne le message demandé dans l'ECF."""
    return {"message": "Hello World"}


@app.get("/health")
def health_check():
    """Permet au Load Balancer de vérifier l'état de l'application."""
    return {"status": "ok"}

    