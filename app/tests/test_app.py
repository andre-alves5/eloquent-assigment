import os
from pathlib import Path

# --- Helpers ---


def get_app_version():
    """
    Reads the application version from the VERSION file in the parent directory.
    This makes the test robust to the current working directory.
    """
    # Path to this test file -> eloquent-assigment/app/tests/test_app.py
    # .parent -> eloquent-assigment/app/tests/
    # .parent.parent -> eloquent-assigment/app/
    version_file = Path(__file__).parent.parent / "VERSION"
    return version_file.read_text().strip()


# --- Tests ---


def test_health_endpoint(client):
    """
    The /health endpoint should return the version from the VERSION file.
    """
    expected_version = get_app_version()
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "healthy"
    assert data["version"] == expected_version


def test_version_endpoint(client):
    """
    The /version endpoint should correctly return the version from the VERSION file.
    """
    expected_version = get_app_version()
    resp = client.get("/version")
    assert resp.status_code == 200
    data = resp.json()
    assert data["version"] == expected_version


def test_api_hello_default_environment(client):
    """
    Without ENVIRONMENT set, /api/hello should return environment 'unknown'
    """
    # Ensure the environment variable is unset for this test
    if "ENVIRONMENT" in os.environ:
        del os.environ["ENVIRONMENT"]

    resp = client.get("/api/hello")
    assert resp.status_code == 200
    data = resp.json()
    assert "message" in data
    assert "Hello" in data["message"]
    assert data["environment"] == "unknown"


def test_api_hello_with_environment(client):
    os.environ["ENVIRONMENT"] = "ci-test"
    resp = client.get("/api/hello")
    assert resp.status_code == 200
    data = resp.json()
    assert data["environment"] == "ci-test"
    # Clean up the environment variable
    del os.environ["ENVIRONMENT"]


def test_health_response_structure(client):
    """
    Ensure health returns only expected keys (basic contract test)
    """
    resp = client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    # minimal contract: status and version
    assert set(data.keys()) >= {"status", "version"}
