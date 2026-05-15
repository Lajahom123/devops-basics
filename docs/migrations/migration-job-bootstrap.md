Initial bootstrap image upload required because
Container Apps Job resources require a valid image
during infrastructure creation.

After bootstrap:
- GitHub Actions builds and pushes migration images
- CI/CD updates the job image dynamically
- manual upload is no longer part of normal operations

ACR_NAME="devopstracker29193"
ACR_LOGIN_SERVER="$ACR_NAME.azurecr.io"

az acr login --name "$ACR_NAME"

docker buildx build \
  --platform linux/amd64 \
  -f Dockerfile.flyway \
  -t "$ACR_LOGIN_SERVER/devops-tracker-migrations:bootstrap" \
  --push \
  .