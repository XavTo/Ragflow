# RAGFlow with Infinity on Railway

[![Deploy on
Railway](https://railway.com/button.svg)](https://railway.com/deploy/ragflow-with-infinity-working?referralCode=1q5cCO&utm_medium=integration&utm_source=template&utm_campaign=generic)

RAGFlow with Infinity is a production-ready Retrieval-Augmented
Generation (RAG) stack combining document ingestion, vector search, and
AI-powered chat. It integrates Infinity as a vector database, MinIO for
object storage, and MySQL/Redis for persistence and caching.

## Version strategy

This repository now uses `v0.26.4` as the Docker build default. A RAGFlow
upgrade must be coordinated with the matching Infinity service: RAGFlow
`v0.26.4` expects Infinity `v0.7.0`.

| Deployment | RAGFlow | Infinity | Status |
| --- | --- | --- | --- |
| Legacy rollback | `v0.23.1` | `v0.6.15` | Validated legacy pair |
| Default/current | `v0.26.4` | `v0.7.0` | Official dependency pair |

RAGFlow `v0.24.0` and later use an Infinity `0.7.x` SDK. Do not upgrade only
RAGFlow while leaving Infinity on `v0.6.15`.

For a rollback or isolated legacy staging deployment, add this variable to the
`ragflow` service:

```bash
RAGFLOW_VERSION="v0.23.1"
```

Railway exposes service variables as Docker build arguments, and the
`Dockerfile` declares `ARG RAGFLOW_VERSION` before `FROM`. Only the two pairs
listed above are accepted; an unknown version fails the image build instead of
deploying an unverified combination.

## Features

- Fully working RAG stack on Railway
- Infinity vector database integration
- MinIO object storage with automatic bucket creation
- MySQL and Redis persistence
- CPU deployment with external embedding and LLM providers
- Strict, build-time checked parser patches

## Architecture

-   **RAGFlow** --- main API + ingestion + chat
-   **Infinity** --- vector database
-   **MinIO** --- object storage
-   **MySQL** --- metadata database
-   **Redis** --- cache & queue

## Template versions

- RAGFlow: `infiniflow/ragflow:v0.26.4` (Dockerfile default)
- Infinity: `infiniflow/infinity:v0.7.0`
- Redis: `redis:8.2.1`
- MySQL: `mysql:9.4`
- MinIO: `minio/minio:latest`

The official RAGFlow `v0.26.4` compose stack pins Infinity `v0.7.0`, MySQL
`8.0.39`, Valkey `8`, and
`pgsty/minio:RELEASE.2026-03-25T00-00-00Z`.

Do not downgrade an existing MySQL `9.4` volume to `8.0.39`. Keep that service
unchanged during the RAGFlow/Infinity upgrade. For new template deployments,
prefer the official pinned dependencies over floating `latest` tags.

## Required environment variables

``` bash
TZ="UTC" # Timezone
DEVICE="cpu" # Compute device
DOC_ENGINE="infinity" # Vector engine

INFINITY_HOST="${{infinity.RAILWAY_PRIVATE_DOMAIN}}" # Infinity host
# RAGFlow uses Infinity's Thrift API on port 23817.

MINIO_HOST="${{minio.RAILWAY_PRIVATE_DOMAIN}}" # MinIO host
MINIO_USER="${{minio.MINIO_ROOT_USER}}" # MinIO user
MINIO_PASSWORD="${{minio.MINIO_ROOT_PASSWORD}}" # MinIO password
MINIO_BUCKET="ragflow" # Bucket
# The private Railway connection is plain HTTP on port 9000.

MYSQL_HOST="${{MySQL.MYSQLHOST}}" # MySQL host
MYSQL_PORT="${{MySQL.MYSQLPORT}}" # MySQL port
MYSQL_USER="${{MySQL.MYSQLUSER}}" # MySQL user
MYSQL_PASSWORD="${{MySQL.MYSQL_ROOT_PASSWORD}}" # MySQL password
MYSQL_DBNAME="${{MySQL.MYSQLDATABASE}}" # MySQL DB

REDIS_HOST="${{Redis.RAILWAY_PRIVATE_DOMAIN}}" # Redis host
REDIS_USERNAME="${{Redis.REDISUSER}}" # Redis user
REDIS_PASSWORD="${{Redis.REDISPASSWORD}}" # Redis password

SECRET_KEY="${{ secret(32) }}" # App secret
API_PROXY_SCHEME="python" # API mode
REGISTER_ENABLED=1 # Set to 1 to enable registration, 0 to disable
```

`INFINITY_PORT`, `MINIO_PORT`, and `REDIS_PORT` belong on their dependency
service definitions. RAGFlow's official configuration currently uses internal
ports `23817`, `9000`, and `6379` respectively, so adding those variables only
to the `ragflow` service does not change its connection ports.

## Safe upgrade procedure

1. Create Railway volume backups for Infinity, MySQL, and MinIO. Back up Redis
   too if queued parsing jobs must be preserved.
2. Test the upgrade in a duplicated/staging environment first.
3. Stop or suspend the `ragflow` service to prevent writes during the engine
   change.
4. Change the Infinity service image to `infiniflow/infinity:v0.7.0`, keep its
   `/var/infinity` volume attached, deploy it, and check its startup logs and
   HTTP status endpoint on port `23820`.
5. Deploy the `ragflow` service. The Dockerfile defaults to
   `RAGFLOW_VERSION=v0.26.4`; keep `API_PROXY_SCHEME=python`. The image selects
   its matching Nginx config at startup.
6. Confirm login, dataset listing, an existing document retrieval, a new `.txt`
   ingestion, and a chat answer with citations.
7. Keep the backups until the migrated stack has run successfully under normal
   workload.

RAGFlow initializes and migrates its MySQL schema during startup. A rollback is
therefore not just an image-tag change: restore the Infinity and MySQL snapshots
before returning to `RAGFlow v0.23.1 + Infinity v0.6.15`.

## Smoke test

1.  Upload a `.txt` document in the UI
2.  Wait for processing (status: completed)
3.  Ask questions in the chat:
    -   "What is the budget?"
    -   "Who is the project manager?"
4.  Verify answers come from your document

## Use cases

-   Internal AI knowledge base
-   Document Q&A assistant
-   Semantic search engine

## Notes

- The MinIO bucket is created by the MinIO service start command.
- The official self-hosting baseline is 4 CPU cores, 16 GB RAM, and 50 GB of
  disk. Size Railway services and volumes for the actual ingestion workload;
  document parsing can exceed a small instance's memory even in CPU mode.
- The stack works on CPU; RAGFlow images from `v0.22.0` onward do not bundle
  embedding models, so configure an external embedding provider.
- The Nginx files in this repository match the Python proxy mode. Newer RAGFlow
  entrypoints select their version-matched proxy file automatically.
- RAGFlow officially requires Nginx `1.31.0` or newer from `v0.25.5`; the
  official `v0.26.4` image already includes it.

## Upstream references

- [RAGFlow releases](https://github.com/infiniflow/ragflow/releases)
- [RAGFlow Docker configuration](https://github.com/infiniflow/ragflow/tree/v0.26.4/docker)
- [Infinity v0.7.0 release](https://github.com/infiniflow/infinity/releases/tag/v0.7.0)
- [Railway Dockerfile build variables](https://docs.railway.com/builds/dockerfiles)

## License

MIT
