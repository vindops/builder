# How to build docker image

```bash
sudo apt update
sudo apt install qemu-user-static
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx create --use --name multiarch
docker buildx inspect --bootstrap


docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --push \
  --progress=plain \
  --tag ghcr.io/vindops/python3-builder:3.12-jammy-uf -f ./Dockerfile.jammy . | tee -a build.log 2>&1
docker image prune -f


crane flatten ghcr.io/vindops/python3-builder:3.12-jammy-uf -t ghcr.io/vindops/python3-builder:3.12-jammy -v

crane flatten --platform linux/amd64 \
  ghcr.io/vindops/python3-builder:3.12-jammy-uf \
  -t ghcr.io/vindops/python3-builder:3.12-jammy-amd64 -v

crane flatten --platform linux/amd64 \
  ghcr.io/vindops/python3-builder:3.12-jammy-uf \
  -t ghcr.io/vindops/python3-builder:3.12-jammy-amd64 -v

crane flatten --platform linux/arm64 \
  ghcr.io/vindops/python3-builder:3.12-jammy-uf \
  -t ghcr.io/vindops/python3-builder:3.12-jammy-arm64 -v

crane manifest \
  -t ghcr.io/vindops/python3-builder:3.12-jammy \
  ghcr.io/vindops/python3-builder:3.12-jammy-amd64 \
  ghcr.io/vindops/python3-builder:3.12-jammy-arm64

gh api /user/packages/container/python3-builder/versions --jq '.[] | select(.metadata.container.tags[]=="3.12-jammy-uf") | .id' | \
  xargs -r -I {} gh api --method DELETE /user/packages/container/python3-builder/versions/{}

gh api /user/packages/container/python3-builder/versions --jq '.[] | select(.metadata.container.tags[]=="3.12-jammy-amd64") | .id' | \
  xargs -r -I {} gh api --method DELETE /user/packages/container/python3-builder/versions/{}

gh api /user/packages/container/python3-builder/versions --jq '.[] | select(.metadata.container.tags[]=="3.12-jammy-arm64") | .id' | \
  xargs -r -I {} gh api --method DELETE /user/packages/container/python3-builder/versions/{}

gh api /user/packages/container/python3-builder/versions --jq '.[] | select(.metadata.container.tags==[]) | .id' | \
  xargs -r -I {} gh api --method DELETE /user/packages/container/python3-builder/versions/{}

gh api --method DELETE /user/packages/container/python3-builder
```
