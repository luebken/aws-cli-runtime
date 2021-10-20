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


## setup localstack

    helm repo add localstack-repo https://helm.localstack.cloud
    helm upgrade --install localstack localstack-repo/localstack --set startServices="s3"

    kubectl logs localstack-7bb788957f-fkl9r -f

    kubectl run curl-pod --image=radial/busyboxplus:curl -i --tty --rm
    curl http://localstack.default.svc.cluster.local:4566

## run crossplane aws-provider

    kubectl crossplane install provider crossplane/provider-aws:v0.20.0

    kubectl apply -f https://raw.githubusercontent.com/crossplane/provider-aws/master/examples/providerconfig/localstack.yaml

    # patch 
    url:
      static: http://localstack.default.svc.cluster.local:4566

    # create s3 bucket
    cat <<EOF | kubectl apply -f -
    apiVersion: s3.aws.crossplane.io/v1beta1
    kind: Bucket
    metadata:
    name: test-bucket
    spec:
    forProvider:
        acl: public-read-write
        locationConstraint: us-east-1
    providerConfigRef:
        name: example
    EOF

