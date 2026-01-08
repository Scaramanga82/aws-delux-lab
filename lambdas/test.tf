dev:

on:
  push:
    branches: [ master ]

name: Deploy on DEV env

env:
  ECR_REPOSITORY: lambda/rds-snapshot-full-export-to-s3
  LAMBDA_NAME: ananas-dev1-lambda-rds-snapshot-full-export-to-s3
  BUILT_BRANCH: master

jobs:
  deploy:
    name: Build and Update lambda
    runs-on: ubuntu-latest

    steps:
      - name: Extract branch name
        shell: bash
        run: echo "##[set-output name=branch;]$(echo ${GITHUB_REF#refs/heads/})"
        id: extract_branch

      - name: Checkout
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-central-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${{ env.ECR_REPOSITORY }}
          IMAGE_TAG: ${{ env.BUILT_BRANCH }}
        run: |
          # Build a docker container and
          # push it to ECR so that it can
          # be deployed to ECS.
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG-${GITHUB_SHA::7} .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG-${GITHUB_SHA::7}
          echo "::set-output name=dockerimage::$( echo ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}-${GITHUB_SHA::7})"

      - name: Update lambda
        uses: docker://amazon/aws-cli:latest
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: eu-central-1
          IMAGE_NAME: ${{ steps.build-image.outputs.dockerimage }}
        with:
          args: lambda update-function-code --function-name ${{ env.LAMBDA_NAME }} --image-uri ${{ env.IMAGE_NAME}}









prod:

on:
  push:
    tags:
      - v*

name: Deploy on PROD env

env:
  ECR_REPOSITORY: lambda/rds-snapshot-full-export-to-s3
  LAMBDA_NAME: ananas-prod-lambda-rds-snapshot-full-export-to-s3
  BUILT_BRANCH: master

jobs:
  deploy:
    name: Build and Update lambda
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_PROD }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_PROD }}
          aws-region: eu-central-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${{ env.ECR_REPOSITORY }}
          IMAGE_TAG: ${{ env.BUILT_BRANCH }}
        run: |
          # Build a docker container and
          # push it to ECR so that it can
          # be deployed to ECS.
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG-${GITHUB_SHA::7} .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG-${GITHUB_SHA::7}
          echo "dockerimage=$(echo ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}-${GITHUB_SHA::7})" >> $GITHUB_OUTPUT

      - name: Update lambda
        uses: docker://amazon/aws-cli:latest
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID_PROD }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY_PROD }}
          AWS_REGION: eu-central-1
          IMAGE_NAME: ${{ steps.build-image.outputs.dockerimage }}
        with:
          args: lambda update-function-code --function-name ${{ env.LAMBDA_NAME }} --image-uri ${{ env.IMAGE_NAME}}