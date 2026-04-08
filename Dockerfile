FROM infiniflow/ragflow:v0.23.1

COPY docker/nginx/ragflow.conf /etc/nginx/conf.d/ragflow.conf
COPY docker/nginx/proxy.conf /etc/nginx/proxy.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# ✅ PATCH 1 uniquement (stable)
RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

if "Embedding extraction from file path is not supported." not in s:
    raise Exception("Patch 1 failed")

s = s.replace(
    'raise Exception("Embedding extraction from file path is not supported.")',
    'embeds = []  # patched'
)

p.write_text(s)
print("✅ Patch 1 applied")
EOF

RUN python - <<'EOF'
import pathlib

p = pathlib.Path("/ragflow/rag/app/naive.py")
s = p.read_text()

old = 'sections = TxtParser()(filename, binary,'
new = 'sections = TxtParser()(filename if binary is None else "", binary,'

if old not in s:
    raise Exception("Patch TxtParser failed")

s = s.replace(old, new)
p.write_text(s)

print("✅ TxtParser patch applied")
EOF

EXPOSE 80 9380
