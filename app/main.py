import time

from flask import Flask, Response, jsonify, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Histogram,
    generate_latest,
)

app = Flask(__name__)

STUDENT_ID = "L00205530"
PROJECT_NAME = "DevOps Mini Pipeline"

REQUEST_COUNT = Counter(
    "flask_http_requests_total",
    "Total HTTP requests processed by the Flask application",
    ["method", "endpoint", "status"],
)

REQUEST_LATENCY = Histogram(
    "flask_http_request_duration_seconds",
    "HTTP request processing duration in seconds",
    ["method", "endpoint"],
)


@app.before_request
def start_request_timer():
    if request.path != "/metrics":
        request.environ["request_start_time"] = time.perf_counter()


@app.after_request
def record_request_metrics(response):
    if request.path == "/metrics":
        return response

    endpoint = request.url_rule.rule if request.url_rule else "unmatched"
    method = request.method

    REQUEST_COUNT.labels(
        method=method,
        endpoint=endpoint,
        status=str(response.status_code),
    ).inc()

    start_time = request.environ.get("request_start_time")

    if start_time is not None:
        REQUEST_LATENCY.labels(
            method=method,
            endpoint=endpoint,
        ).observe(time.perf_counter() - start_time)

    return response


@app.get("/")
def home():
    return jsonify({
        "project": PROJECT_NAME,
        "student_id": STUDENT_ID,
        "status": "running",
    })


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
    })


@app.get("/metrics")
def metrics():
    return Response(
        generate_latest(),
	content_type=CONTENT_TYPE_LATEST,
    )


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
