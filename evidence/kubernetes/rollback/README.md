# L00205530 - Kubernetes Rollback and Recovery Test

## Objective

Validate Kubernetes deployment recovery following an unsuccessful
container image update.

## Environment

- Platform: Docker Desktop Kubernetes
- Application: L00205530 DevOps Mini-Pipeline
- Deployment: l00205530-flask
- Desired replicas: 2
- Container registry: GitHub Container Registry (GHCR)

## Test Procedure

1. Verified that the original deployment had two healthy replicas.
2. Identified revision 3 as the known-good deployment.
3. Introduced a deliberately invalid GHCR image tag.
4. Observed the image pull failure.
5. Rolled back to revision 3 using kubectl rollout undo.
6. Verified the restored deployment and application endpoints.

## Failure Observed

Invalid image:

ghcr.io/l00205530/l00205530-devops-mini-pipeline:invalid-rollback-test

Kubernetes reported:

- ErrImagePull
- ImagePullBackOff
- Image not found in GHCR

The failed ReplicaSet was subsequently scaled down to zero replicas.

## Recovery

Command used:

kubectl rollout undo deployment/l00205530-flask --to-revision=3

Recovery verification:

- Kubernetes rollout completed successfully.
- Deployment reported 2/2 available replicas.
- Both original application pods remained running.
- Both pods reported zero container restarts.
- The health endpoint returned HTTP 200.
- The application endpoint returned HTTP 200.

## Results

| Test | Result |
|---|---|
| Invalid image deployment | PASS |
| Image pull failure detected | PASS |
| Failed ReplicaSet identified | PASS |
| Rollback to known-good revision | PASS |
| Two healthy replicas available | PASS |
| Health endpoint HTTP 200 | PASS |
| Application endpoint HTTP 200 | PASS |

## Evidence

- baseline-deployment.yaml
- baseline-history.txt
- baseline-pods.txt
- failed-deployment-pods.txt
- failed-deployment-status.txt
- failed-replicaset.yaml
- failed-rollout-history.txt
- failure-and-recovery-events.txt
- recovered-deployment.txt
- recovered-pods.txt
- recovered-health.json
- recovered-application.json
- recovery-history.txt

## Conclusion

The test demonstrated that Kubernetes detected an invalid container
image and retained the existing healthy application replicas during
the unsuccessful rolling update.

Rolling back to the known-good deployment revision restored the
desired deployment configuration.

The successful HTTP endpoint checks confirmed application availability
after recovery.

This test validates the deployment's recovery procedure. Continuous
application availability throughout the entire failure window was not
independently measured.
