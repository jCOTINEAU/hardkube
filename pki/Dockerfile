FROM alpine:3.10

RUN apk update
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing cfssl
RUN apk add gettext

RUN mkdir tmpcert
WORKDIR tmpcert

COPY ca-config.json .
COPY ca-csr.json .
COPY admin-csr.json .
COPY client-csr.json .
COPY kube-controller-manager-csr.json .
COPY kube-proxy-csr.json .
COPY kube-scheduler-csr.json .
COPY kubernetes-csr.json .
COPY service-account-csr.json .
COPY encryption-config.yaml .
COPY kube-scheduler.yaml .

RUN cfssl gencert -initca ca-csr.json | cfssljson -bare ca
RUN cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=ca-config.json \
    -profile=kubernetes \
    admin-csr.json | cfssljson -bare admin

RUN cat client-csr.json | INSTANCE=w1 envsubst > clientw1-csr.json
RUN cat client-csr.json | INSTANCE=w2 envsubst > clientw2-csr.json
RUN cat client-csr.json | INSTANCE=w3 envsubst > clientw3-csr.json

RUN for instance in w1 w2 w3; do \
    cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=${instance}\
      -profile=kubernetes \
      client${instance}-csr.json | cfssljson -bare ${instance}; \
    done

RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-proxy-csr.json | cfssljson -bare kube-proxy

RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      kube-scheduler-csr.json | cfssljson -bare kube-scheduler

RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -hostname=10.32.0.1,m1,m2,m3,10.5.0.6,10.5.0.7,10.5.0.8,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local\
      -profile=kubernetes \
      kubernetes-csr.json | cfssljson -bare kubernetes

RUN cfssl gencert \
      -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config=ca-config.json \
      -profile=kubernetes \
      service-account-csr.json | cfssljson -bare service-account

RUN export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64) && cat encryption-config.yaml | envsubst > encryption.yaml
