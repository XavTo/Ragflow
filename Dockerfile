ARG RAGFLOW_VERSION=v0.26.4
FROM infiniflow/ragflow:${RAGFLOW_VERSION}

ARG RAGFLOW_VERSION

# RAGFlow and Infinity must be upgraded together. Keep the legacy pair
# buildable for rollback/staging, but use the current validated pair by default.
RUN case "${RAGFLOW_VERSION}" in \
        v0.23.1|v0.26.4) ;; \
        *) echo "Unsupported RAGFLOW_VERSION=${RAGFLOW_VERSION}" >&2; exit 1 ;; \
    esac

COPY docker/nginx/ragflow.conf /etc/nginx/conf.d/ragflow.conf
COPY docker/nginx/proxy.conf /etc/nginx/proxy.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Preserve path-backed parsing used by this Railway deployment. Both patches
# are checked strictly so an incompatible upstream source fails during build.
RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

old = 'raise Exception("Embedding extraction from file path is not supported.")'
new = "embeds = []  # patched for path-backed parsing"

if s.count(old) != 1:
    raise RuntimeError("Embedded-file patch no longer matches upstream source")

s = s.replace(old, new, 1)
p.write_text(s)
print("Embedded-file patch applied")
EOF

RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

old = 'sections = TxtParser()(filename, binary,'
new = 'sections = TxtParser()(filename if binary is None else "", binary,'

if s.count(old) != 1:
    raise RuntimeError("TxtParser patch no longer matches upstream source")

s = s.replace(old, new, 1)
p.write_text(s)

compile(s, str(p), "exec")
print("TxtParser patch applied")
EOF

EXPOSE 80 9380
