FROM docker:stable-dind

RUN apk update

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin

##worker part
RUN apk add socat conntrack-tools ipset

RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz \
 https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64 \
 https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz \
 https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl \
 https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet \
 https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy

RUN mkdir -p \
 /etc/cni/net.d \
 /opt/cni/bin \
 /var/lib/kubelet \
 /var/lib/kube-proxy \
 /var/lib/kubernetes \
 /var/run/kubernetes \

RUN apk add containerd

RUN tar -xvf crictl-v1.15.0-linux-amd64.tar.gz
RUN tar -xvf cni-plugins-linux-amd64-v0.8.2.tgz -C /opt/cni/bin/
RUN mv runc.amd64 runc
RUN chmod +x crictl kubectl kube-proxy kubelet runc
RUN mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/

## THIS WILL BREAK EVERYTHING BECAUSE WE USE FLANNEL DEPLOYMENT AS NETORK PLUGIN
#COPY cnicontainerd/bridge.conf /etc/cni/net.d/10-bridge.conf
#COPY cnicontainerd/loopback.conf /etc/cni/net.d/99-loopback.conf
COPY cnicontainerd/containerd.toml /etc/containerd/config.toml
COPY kubelet-config.yaml kubelet-config.yaml

RUN apk add gettext

RUN cat kubelet-config.yaml | HOSTNAME=w1 envsubst > /var/lib/kubelet/w1-kubelet-config.yaml
RUN cat kubelet-config.yaml | HOSTNAME=w2 envsubst > /var/lib/kubelet/w2-kubelet-config.yaml
RUN cat kubelet-config.yaml | HOSTNAME=w3 envsubst > /var/lib/kubelet/w3-kubelet-config.yaml
COPY kube-proxy-config.yaml .

RUN apk add gcompat libc6-compat

RUN echo "cgroup /sys/fs/cgroup cgroup defaults 0 0" >> /etc/fstab

COPY cnicontainerd/cgconfig.conf /etc/cgconfig.conf