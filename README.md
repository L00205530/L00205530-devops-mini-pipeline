# L00205530 — DevOps Mini Pipeline

**Task 3: DevOps in Action — Creating a Mini-Pipeline**

## 1. Student Information

| Field | Details |
|---|---|
| Student ID | L00205530 |
| Project | DevOps Mini Pipeline |
| Development Environment | Ubuntu 26.04 LTS on WSL2 |
| Version Control | Git and GitHub |
| Container Platform | Docker |
| Container Orchestration | Kubernetes |
| Monitoring | Prometheus and Grafana |

## 2. Project Overview

This project demonstrates the design and implementation of an automated DevOps pipeline for a Python Flask web application.

The objective is to integrate source code management, automated testing, static code analysis, security scanning, containerisation, Kubernetes deployment, and application monitoring into a single development workflow.

The implementation follows DevOps principles, including automation, continuous integration, infrastructure reproducibility, observability, and incremental development through feature branches and pull requests.

### Project Objectives

- Develop a functional Python Flask application.
- Implement automated unit and integration testing.
- Enforce code quality and test coverage.
- Integrate static application security testing.
- Containerise the application using Docker.
- Scan container images for vulnerabilities.
- Publish container images to GitHub Container Registry.
- Deploy the application to Kubernetes.
- Implement health checks and application metrics.
- Monitor application performance using Prometheus and Grafana.
- Maintain a documented Git workflow with meaningful commits and pull requests.

## 3. Technology Stack

| Category | Technology | Purpose |
|---|---|---|
| Programming | Python | Application development |
| Web Framework | Flask | HTTP application |
| Testing | pytest, pytest-cov | Automated tests and coverage |
| Code Quality | Ruff | Linting and static analysis |
| Security | Bandit | Python security scanning |
| Containerisation | Docker | Application packaging |
| Container Security | Trivy | Image vulnerability scanning |
| CI/CD | GitHub Actions | Automated pipeline execution |
| Container Registry | GHCR | Container image distribution |
| Orchestration | Kubernetes | Container deployment and management |
| Package Management | Helm | Monitoring stack deployment |
| Monitoring | Prometheus | Metrics collection |
| Visualisation | Grafana | Application monitoring dashboards |
| Version Control | Git and GitHub | Collaboration and change tracking |

## 4. System Architecture

The solution uses the following workflow:

```text
Developer
    |
    v
Git Feature Branch
    |
    v
GitHub Pull Request
    |
    v
GitHub Actions CI Pipeline
    |
    +--> Python Tests and Coverage
    |
    +--> Ruff Code Quality Checks
    |
    +--> Bandit Security Scanning
    |
    +--> Docker Image Build
    |
    +--> Trivy Container Scanning
    |
    v
Merge into Main
    |
    v
GitHub Container Registry
    |
    v
Kubernetes Deployment
    |
    +--> Flask Replica 1
    |
    +--> Flask Replica 2
    |
    v
Prometheus Metrics Collection
    |
    v
Grafana Monitoring Dashboard
```

The CI pipeline validates code changes before merging.

The container publishing stage is configured to run when its GitHub Actions conditions are satisfied.

Kubernetes deployment and monitoring installation are performed using the repository's deployment configurations and scripts.

## 5. Flask Application

The project uses a lightweight Flask application to demonstrate automated testing, deployment, and observability.

### Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Application home endpoint |
| `/health` | Health endpoint used by Kubernetes |
| `/metrics` | Prometheus-compatible application metrics |

The application is served using Gunicorn in the container environment.

### Run Locally

Create and activate a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the Flask application using the project's configured application entry point.

## 6. Automated Testing

Automated testing is implemented using pytest.

The test suite covers application functionality, HTTP endpoints, and metrics behavior.

Run tests:

```bash
python -m pytest -v
```

Run tests with coverage:

```bash
python -m pytest --cov=app --cov-report=term-missing
```

The CI pipeline enforces a minimum coverage threshold of 90%.

During development, the project achieved approximately 97% test coverage.

## 7. Code Quality and Security

### Ruff

Ruff performs automated Python linting.

```bash
ruff check app/ tests/
```

### Bandit

Bandit identifies potential security issues in Python application code.

```bash
bandit -r app/ -ll
```

### Trivy

Trivy scans the Docker image for known vulnerabilities as part of the CI pipeline.

These checks support early detection of quality and security problems before deployment.

## 8. Docker Containerisation

The Flask application is packaged as a Docker image.

The Docker implementation uses a multi-stage build and runs the application as a non-root user.

This reduces unnecessary runtime components and limits container privileges.

Build the image locally:

```bash
docker build -t l00205530-flask:local .
```

Inspect the image:

```bash
docker images
```

The GitHub Actions workflow also builds and scans the container image.

When publishing conditions are met, the image is pushed to GitHub Container Registry.

## 9. Kubernetes Deployment

The application is deployed to a local Kubernetes cluster using Docker Desktop.

The deployment includes:

- Two Flask replicas.
- A Kubernetes ClusterIP Service.
- Container readiness probes.
- Container liveness probes.
- Resource management through Kubernetes.
- Internal service networking.

### Deployment Verification

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

Check the Flask deployment:

```bash
kubectl get deployment l00205530-flask
```

Verify rollout status:

```bash
kubectl rollout status deployment/l00205530-flask
```

The validated deployment had two available replicas, both running without restarts.

### Automated Application Deployment

The Flask application can be deployed using the version-controlled Kubernetes manifests and the automated deployment script.

```bash
./scripts/deploy-application.sh
```

The script performs six deployment stages:

1. Verifies Kubernetes connectivity.
2. Validates the Kubernetes manifests using server-side dry-run.
3. Applies the Deployment and Service manifests.
4. Waits for the Kubernetes rollout to complete.
5. Verifies that the expected number of application replicas are ready.
6. Displays the deployed resources and container image.

The application image is pinned to a SHA256 digest in the Kubernetes Deployment manifest to ensure that the same container image is used across repeated deployments.

The script supports repeated execution and exits with an error if manifest validation, deployment rollout, or replica verification fails.

**Validation results:** The script was executed successfully against the local Kubernetes cluster. Both application replicas were available, with zero container restarts. Kubernetes reported the existing Deployment and Service resources as unchanged.

This automation provides repeatable application deployment to an accessible Kubernetes cluster. Image publishing is handled separately by GitHub Actions, and deployment is not currently triggered automatically after each successful CI run.

## 10. Prometheus Monitoring

Prometheus collects application metrics from the Flask pods.

The application exposes metrics through:

```text
/metrics
```

Prometheus uses Kubernetes pod discovery to identify application instances.

The scrape configuration targets pods with the label:

```text
app=l00205530-flask
```

Metrics are collected at 15-second intervals.

### Prometheus Metrics

| Metric | Description |
|---|---|
| `flask_http_requests_total` | Total HTTP requests |
| `flask_http_request_duration_seconds` | HTTP request duration histogram |
| `up` | Prometheus target scrape availability |

The monitoring configuration is stored in:

`monitoring/prometheus/values.yaml`

### Verify Prometheus

```bash
kubectl port-forward -n monitoring service/prometheus-server 9090:80
```

Open:

`http://localhost:9090`

Execute:

```promql
up{job="l00205530-flask"}
```

A healthy deployment should report both Flask replicas with a value of `1`.

## 11. Grafana Monitoring Dashboard

Grafana provides a visual monitoring interface connected to Prometheus.

The project includes a version-controlled dashboard named:

**L00205530 - DevOps Monitoring**

### Dashboard Panels

| Panel | Description |
|---|---|
| Available Flask Replicas | Number of healthy Prometheus targets |
| HTTP Requests per Second | Application request throughput |
| HTTP 5xx Error Rate | Percentage of server-error responses |
| P95 HTTP Response Latency | 95th percentile HTTP request duration |

The HTTP error panel includes a zero-value fallback when no HTTP 5xx series exists.

### Dashboard as Code

The dashboard definition is stored in:

`monitoring/grafana/dashboards/devops-monitoring.json`

A Kubernetes ConfigMap supplies the dashboard to Grafana.

Grafana automatically provisions the dashboard from this configuration.

This enables dashboard restoration after redeployment without requiring manual creation.

### Access Grafana

```bash
kubectl port-forward -n monitoring service/grafana 3000:80
```

Open:

`http://localhost:3000`

Log in using the administrator credentials stored in the Kubernetes Secret.

## 12. Automated Monitoring Deployment

The monitoring infrastructure is deployed using Helm.

The project pins these chart versions:

| Component | Helm Chart Version |
|---|---|
| Prometheus | 29.48.0 |
| Grafana Community | 14.5.0 |

The deployment script is located at:

`scripts/deploy-monitoring.sh`

Run:

```bash
./scripts/deploy-monitoring.sh
```

The script:

1. Creates or verifies the monitoring namespace.
2. Checks for the Grafana administrator Secret.
3. Configures the required Helm repositories.
4. Creates or updates the Grafana dashboard ConfigMap.
5. Deploys or upgrades Prometheus.
6. Deploys or upgrades Grafana.
7. Displays monitoring pod status.

The deployment uses declarative Kubernetes configuration and Helm upgrade operations to support repeated execution.

For detailed instructions, see [Monitoring Documentation](docs/monitoring.md).

## 13. CI/CD Pipeline

GitHub Actions automatically validates pull requests and changes according to the workflow configuration.

### CI Stages

| Stage | Implementation |
|---|---|
| Source Code | GitHub |
| Application Tests | pytest |
| Coverage Validation | pytest-cov |
| Linting | Ruff |
| Security Analysis | Bandit |
| Docker Build | Docker |
| Image Security | Trivy |
| Image Publishing | GitHub Container Registry |

The pipeline is designed to prevent changes that fail required quality checks from being merged when repository protection rules enforce those checks.

### Pipeline Validation

The monitoring pull request (#15) completed with:

- Build and Test Flask Application: Passed.
- Docker Build and Security Scan: Passed.
- Publish Docker Image: Skipped as expected for the pull request.

## 14. Git Workflow

The project uses Git feature branches and GitHub pull requests to support incremental development.

The workflow is:

```text
main
 |
 +--> feature/application
 |
 +--> feature/integration-testing
 |
 +--> feature/security-scanning
 |
 +--> feature/monitoring
 |
 +--> documentation branches
 |
 v
Pull Request
 |
 v
CI Validation
 |
 v
Merge into main
```

Actual branch names vary by feature.

### Monitoring Implementation

Pull Request #15 implemented the Prometheus and Grafana monitoring stack.

It included six incremental monitoring commits, followed by documentation, before merging into `main`.

Merge commit:

`3baa049a6a18fc671c70b9c5cde8690803e7fbb3`

The commit history demonstrates separate development milestones for configuration, dashboard implementation, deployment automation, and testing improvements.

## 15. Testing and Validation Results

The following results were verified during development:

| Test | Result |
|---|---|
| Flask automated tests | Passed |
| Test coverage | Approximately 97% |
| Ruff linting | Passed |
| Bandit security scan | Passed |
| Docker build and security scan CI | Passed |
| Kubernetes Flask deployment | 2/2 replicas available |
| Prometheus Helm release | Deployed |
| Grafana Helm release | Deployed |
| Prometheus Flask targets | 2 healthy targets |
| Grafana dashboard | Successfully provisioned |
| HTTP 5xx zero-value fallback | Verified |
| Monitoring deployment script | Executed successfully |
| Monitoring PR #15 CI | 2 passed, 1 expected skip |
| Monitoring PR #15 | Merged |

These results describe the observed development and validation environment.

## 16. Security Considerations

The project incorporates several security controls:

- Automated static security scanning using Bandit.
- Container image vulnerability scanning using Trivy.
- Non-root application container execution.
- Kubernetes internal ClusterIP networking.
- Health probes for application availability.
- Grafana administrator credentials stored in a Kubernetes Secret.
- Version-controlled deployment and monitoring configuration.

Secrets and passwords are not intentionally stored in the repository.

### Limitations

This implementation is designed for a local academic development environment rather than production.

Prometheus and Grafana persistence are disabled. Monitoring history and changes made exclusively through the Grafana interface may be lost when storage is recreated.

The project does not currently demonstrate production-grade high availability, TLS ingress, external secret management, or a complete alerting strategy.

## 17. Project Documentation

Additional documentation is available in the repository:

- [Monitoring Architecture and Deployment](docs/monitoring.md)
- [GitHub Actions Workflow](.github/workflows/)
- [Kubernetes Configuration](k8s/)
- [Prometheus Configuration](monitoring/prometheus/values.yaml)
- [Grafana Configuration](monitoring/grafana/values.yaml)
- [Grafana Dashboard JSON](monitoring/grafana/dashboards/devops-monitoring.json)
- [Monitoring Deployment Script](scripts/deploy-monitoring.sh)

## 18. Conclusion

This project demonstrates a functional DevOps mini-pipeline integrating application development, automated quality assurance, containerisation, Kubernetes orchestration, and application monitoring.

The implementation illustrates how DevOps practices can improve software delivery through automation, repeatable infrastructure configuration, continuous validation, security integration, and observability.

The completed project provides practical experience with GitHub Actions, Docker, Kubernetes, Prometheus, Grafana, and supporting development tools.

## AI / LLM Usage Disclosure

During the development of this project, **OpenAI ChatGPT (GPT-6)** was used as a supporting technical resource.

The LLM was primarily used for:

- **Troubleshooting:** Assisting with the interpretation of error messages, CI/CD failures, configuration issues, and deployment problems.
- **Technical recommendations:** Suggesting approaches, tools, configuration improvements, and DevOps best practices.
- **Code and configuration review:** Providing example commands, configuration suggestions, and potential solutions for issues encountered during development.
- **Documentation support:** Assisting with the structure, clarity, and technical presentation of project documentation.
- **Learning support:** Explaining concepts related to Docker, Kubernetes, GitHub Actions, Prometheus, Grafana, and security scanning.

**Implementation and validation**

LLM responses were treated as recommendations rather than automatically accepted solutions.

The student was responsible for executing commands, implementing and reviewing changes, troubleshooting the actual development environment, and independently verifying the results.

All reported testing and validation activities were performed by the student, including:

- Running pytest and verifying test coverage.
- Executing Ruff and Bandit checks.
- Reviewing GitHub Actions pipeline results.
- Validating Docker builds and security scans.
- Deploying and verifying Kubernetes resources.
- Testing Prometheus metrics collection.
- Verifying Grafana dashboards and monitoring functionality.
- Reviewing Git commits, pull requests, and successful merges.

**The LLM did not independently execute or validate the project in the student's local environment.** Final responsibility for implementation decisions, testing, verification, and submitted work remained with the student.

AI assistance was used to support problem-solving and learning throughout the development process, with results independently checked against the actual project environment.
