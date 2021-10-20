A container to run on your K8s cluster to work with the AWS CLI.

## build
    docker build --platform linux/amd64 -t luebken/aws-cli-runtime .
    docker push luebken/aws-cli-runtime

## run
    docker run --rm -it luebken/aws-cli-runtime
 
    kubectl run aws-cli-runtime --image=luebken/aws-cli-runtime
    kubectl exec --stdin --tty aws-cli-runtime -- /bin/bash

## usage
    aws configure
    ...
    aws --endpoint-url=http://localstack.default.svc.cluster.local:4566 s3 ls