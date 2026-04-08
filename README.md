# Ragflow with Infinity --- Working ✅

[![Deploy on
Railway](https://railway.com/button.svg)](https://railway.com/deploy/ragflow-with-infinity-working?referralCode=1q5cCO&utm_medium=integration&utm_source=template&utm_campaign=generic)

RAGFlow with Infinity is a production-ready Retrieval-Augmented
Generation (RAG) stack combining document ingestion, vector search, and
AI-powered chat. It integrates Infinity as a vector database, MinIO for
object storage, and MySQL/Redis for persistence and caching.

## 🚀 Features

-   Fully working RAG stack on Railway
-   Infinity vector database integration
-   MinIO object storage (auto bucket creation)
-   MySQL + Redis preconfigured
-   Ready for document ingestion and semantic search
-   Clean Dockerfile with required patches

## 🧱 Architecture

-   **RAGFlow** --- main API + ingestion + chat
-   **Infinity** --- vector database
-   **MinIO** --- object storage
-   **MySQL** --- metadata database
-   **Redis** --- cache & queue

## 📦 Service Versions

-   ragflow: `infiniflow/ragflow:v0.23.1`
-   infinity: `infiniflow/infinity:v0.6.15`
-   redis: `redis:8.2.1`
-   mysql: `mysql:9.4`
-   minio: `minio/minio:latest`

## ⚙️ Environment Variables (Essential)

``` bash
TZ="UTC" # Timezone
DEVICE="cpu" # Compute device
DOC_ENGINE="infinity" # Vector engine

INFINITY_HOST="${{infinity.RAILWAY_PRIVATE_DOMAIN}}" # Infinity host
INFINITY_PORT="${{infinity.INFINITY_PORT}}" # Infinity port

MINIO_HOST="${{minio.RAILWAY_PRIVATE_DOMAIN}}" # MinIO host
MINIO_PORT="9000" # MinIO port
MINIO_USER="${{minio.MINIO_ROOT_USER}}" # MinIO user
MINIO_PASSWORD="${{minio.MINIO_ROOT_PASSWORD}}" # MinIO password
MINIO_BUCKET="ragflow" # Bucket
MINIO_SECURE="false" # Disable HTTPS

MYSQL_HOST="${{MySQL.MYSQLHOST}}" # MySQL host
MYSQL_PORT="${{MySQL.MYSQLPORT}}" # MySQL port
MYSQL_USER="${{MySQL.MYSQLUSER}}" # MySQL user
MYSQL_PASSWORD="${{MySQL.MYSQL_ROOT_PASSWORD}}" # MySQL password
MYSQL_DBNAME="${{MySQL.MYSQLDATABASE}}" # MySQL DB

REDIS_HOST="${{Redis.RAILWAY_PRIVATE_DOMAIN}}" # Redis host
REDIS_PORT="${{Redis.REDISPORT}}" # Redis port
REDIS_USERNAME="${{Redis.REDISUSER}}" # Redis user
REDIS_PASSWORD="${{Redis.REDISPASSWORD}}" # Redis password

SECRET_KEY="${{ secret(32) }}" # App secret
API_PROXY_SCHEME="python" # API mode
REGISTER_ENABLED=1 # Set to 1 to enable registration, 0 to disable
```

## 🧪 How to Test

1.  Upload a `.txt` document in the UI
2.  Wait for processing (status: completed)
3.  Ask questions in the chat:
    -   "What is the budget?"
    -   "Who is the project manager?"
4.  Verify answers come from your document

## 🎯 Use Cases

-   Internal AI knowledge base
-   Document Q&A assistant
-   Semantic search engine

## 🧠 Notes

-   MinIO bucket is auto-created at startup
-   Works on CPU (no GPU required)
-   Optimized for Railway internal networking

## 📄 License

MIT
