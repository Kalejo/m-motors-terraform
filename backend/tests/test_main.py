from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_my_test():
    """Vérifie la réponse principale de l'application."""
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}


def test_health_check():
    """Vérifie le chemin utilisé par le Load Balancer."""
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}