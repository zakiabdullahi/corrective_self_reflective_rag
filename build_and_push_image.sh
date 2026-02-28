AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="crag-rag-app"
ECR_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest"

# Create the ECR repository (one-time)
aws ecr create-repository \
    --repository-name $ECR_REPO \
    --region $AWS_REGION \
    --image-scanning-configuration scanOnPush=true

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build for linux/amd64 (required on Apple Silicon M1/M2/M3)
docker build --platform linux/amd64 -t $ECR_REPO:latest .

# Tag and push
docker tag $ECR_REPO:latest $ECR_IMAGE
docker push $ECR_IMAGE
