A container to run on your K8s cluster to work with the [AWS CLI](https://aws.amazon.com/cli/).

## build
    docker build --platform linux/amd64 -t luebken/aws-cli-runtime .
    docker push luebken/aws-cli-runtime

## run
    # locally as a docker container
    docker run --rm -it luebken/aws-cli-runtime
 
    # on a k8s cluster
    kubectl run aws-cli-runtime --image=luebken/aws-cli-runtime
    kubectl exec --stdin --tty aws-cli-runtime -- /bin/bash

## usage
Within the container the `aws` cli is available

    # configure the aws cli. use test/test for localstack setup
    aws configure
    ...

    # point to the right endpoint
    aws s3 --endpoint-url=http://localstack.default.svc.cluster.local:4566 s3 ls