from flask import Flask, jsonify

app = Flask(__name__)

STUDENT_ID = "L00205530"
PROJECT_NAME = "DevOps Mini Pipeline"


@app.get("/")
def home():
    return jsonify({
        "project": PROJECT_NAME,
        "student_id": STUDENT_ID,
        "status": "running"
    })


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy"
    })


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
