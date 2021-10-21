# Using with Localstack and Crossplane

This container is a perfect companion to work with [Crossplane](https://crossplane.io/), [provider-aws](https:/github.com/crossplane/provider-aws) and [localstack](https://localstack.cloud/). 


## prequisites

    kind create cluster
    helm install crossplane --namespace crossplane-system  --create-namespace crossplane-stable/crossplane

## install localstack

    helm repo add localstack-repo https://helm.localstack.cloud
    # only select s3 as a service
    helm install localstack localstack-repo/localstack --set startServices="s3"

    # check the localstack container logs
    kubectl logs $(kubectl get pods -l app.kubernetes.io/name=localstack -o name) -f

    # test the availabilty of the localstack endpoint
    kubectl run curl-pod --image=radial/busyboxplus:curl -i --tty --rm
    curl http://localstack.default.svc.cluster.local:4566

## run and configure crossplane aws-provider

    kubectl crossplane install provider crossplane/provider-aws:v0.20.0

    # install a secret and providerconfig for localstack   
    kubectl apply -f https://raw.githubusercontent.com/crossplane/provider-aws/master/examples/providerconfig/localstack.yaml

    # patch provider config to point to the right endpoint
    kubectl patch providerconfig example --type=json --patch='[{"op": "replace", "path": "/spec/endpoint/url/static", "value": "http://localstack.default.svc.cluster.local:4566"}]'

    kubectl get providers.pkg.crossplane.io,providerconfigs.aws.crossplane.io

## use crossplane to create an s3 bucket on localstack

    # create s3 bucket
```console
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
```

    # check the mangaged resource is installed
    kubectl get bucket
    NAME          READY   SYNCED   AGE
    test-bucket   True    True     4s

## use AWS cli to verify

    kubectl run aws-cli-runtime --image=luebken/aws-cli-runtime
    kubectl exec --stdin --tty aws-cli-runtime -- /bin/bash

    # configure the aws cli for localstack setup
    # use test/test for key and secret and default for the rest
    aws configure
    ...

    # point to the right endpoint
    aws --endpoint-url=http://localstack.default.svc.cluster.local:4566 s3 ls

## example uploading html

```console
# create the bucket
cat <<EOF | kubectl apply -f -
apiVersion: s3.aws.crossplane.io/v1beta1
kind: Bucket
metadata:
  name: website-bucket
spec:
  forProvider:
    acl: public-read
    locationConstraint: us-east-1
    corsConfiguration:
      corsRules:
        - allowedMethods:
            - "GET"
          allowedOrigins:
            - "*"
          allowedHeaders:
            - "*"
          exposeHeaders:
            - "x-amz-server-side-encryption"
  providerConfigRef:
    name: example
EOF
```

    # on aws-cli-runtime:
    # create html and upload it to the bucket
    echo "<html>hello from crossplane</html>" > index.html
    aws --endpoint-url=http://localstack.default.svc.cluster.local:4566 s3 cp index.html s3://website-bucket --acl public-read
    upload: ./index.html to s3://website-bucket/index.html

    # verify the bucket has the html file
    aws --endpoint-url=http://localstack.default.svc.cluster.local:4566 s3api head-object --bucket website-bucket --key index.html
    {
    "LastModified": "2021-10-21T11:52:01+00:00",
    "ContentLength": 35,
    "ETag": "\"b785e6dedf26b0acefc463b9f12a74df\"",
    "ContentType": "text/html",
    "Metadata": {}
    }

    # curl the html
    curl localstack.default.svc.cluster.local:4566/website-bucket/index.html