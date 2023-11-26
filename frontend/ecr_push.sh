# !/bin/sh

GIT_COMMIT_ID=$(git log --format="%H" -n 1)
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 806467626197.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-react
docker build -t nginx-react:"${GIT_COMMIT_ID}" -f Dockerfile.prod .
docker tag nginx-react:"${GIT_COMMIT_ID}" 806467626197.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-react:"${GIT_COMMIT_ID}"
docker push 806467626197.dkr.ecr.ap-northeast-1.amazonaws.com/nginx-react:"${GIT_COMMIT_ID}"
