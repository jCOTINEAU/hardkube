FROM docker:stable-dind

RUN apk update
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing cfssl


RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing etcd
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing etcd-ctl

RUN rm /etc/etcd/conf.yml

RUN wget "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver" "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager" "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler"
RUN chmod +x kube-apiserver kube-controller-manager kube-scheduler
RUN mv kube-apiserver kube-controller-manager kube-scheduler /usr/local/bin/

RUN mkdir /var/lib/kubernetes

RUN apk add nginx
COPY health/health.conf /etc/nginx/conf.d/health.conf

##worker part
RUN apk add socat conntrack-tools ipset

RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz \
         https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64 \
         https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz \
         https://github.com/containerd/containerd/releases/download/v1.2.9/containerd-1.2.9.linux-amd64.tar.gz \
         https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy \
         https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet

RUN mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
