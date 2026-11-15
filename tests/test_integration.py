import json
import subprocess
import sys
import time
import urllib.error
import urllib.request


def test_application_http_health():
    """Verify that the running Flask application responds over HTTP."""

    server = subprocess.Popen(
        [sys.executable, "-m", "app.main"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    try:
        for _ in range(30):
            if server.poll() is not None:
                raise AssertionError("Flask server exited unexpectedly")

            try:
                with urllib.request.urlopen(
                    "http://127.0.0.1:5000/health",
                    timeout=1,
                ) as response:
                    assert response.status == 200
                    assert json.load(response)["status"] == "healthy"
                    return

            except urllib.error.URLError:
                time.sleep(0.2)

        raise AssertionError("Flask server did not become ready")

    finally:
        server.terminate()

        try:
            server.wait(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()
            server.wait()
