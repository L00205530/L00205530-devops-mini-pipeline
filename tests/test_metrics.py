from app.main import app


def test_metrics_endpoint():
    client = app.test_client()

    response = client.get("/metrics")

    assert response.status_code == 200
    assert response.content_type.startswith("text/plain")
    assert b"flask_http_requests_total" in response.data
    assert b"flask_http_request_duration_seconds" in response.data


def test_request_counter():
    client = app.test_client()

    client.get("/health")
    response = client.get("/metrics")

    metrics = response.get_data(as_text=True)

    assert 'endpoint="/health",method="GET",status="200"' in metrics


def test_metrics_scrape_not_counted():
    client = app.test_client()

    first = client.get("/metrics").get_data(as_text=True)
    second = client.get("/metrics").get_data(as_text=True)

    def request_counters(metrics):
        return sorted(
            line
            for line in metrics.splitlines()
            if line.startswith("flask_http_requests_total{")
        )

    assert request_counters(first) == request_counters(second)
