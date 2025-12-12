# How to build docker image

```bash
docker build -t ghcr.io/vindops/python3-builder:3.12-jammy-uf -f ./Dockerfile.jammy .
docker image prune -f
docker push ghcr.io/vindops/python3-builder:3.12-jammy-uf

crane flatten ghcr.io/vindops/python3-builder:3.12-jammy-uf -t ghcr.io/vindops/python3-builder:3.12-jammy -v
```
