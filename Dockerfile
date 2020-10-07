FROM alpine:3.12

ARG KUBECTL_VERSION=1.17.12
ARG HELM_VERSION=3.3.4
ARG HELM_DIFF_VERSION=3.1.3
ARG HELM_SECRETS_VERSION=2.0.2
ARG HELMFILE_VERSION=0.130.1
ARG HELM_S3_VERSION=0.9.2
ARG HELM_GIT_VERSION=0.8.1

WORKDIR /

RUN apk --update --no-cache add bash ca-certificates git gnupg curl gettext py3-pip jq && pip install gitpython~=2.1.11 requests~=2.22.0 PyYAML~=5.1.1 awscli

ADD https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
RUN kubectl version --client

ADD https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator
RUN aws-iam-authenticator version

ADD https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz /tmp
RUN tar -zxvf /tmp/helm* -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp/*
RUN helm version

RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} && \
    helm plugin install https://github.com/futuresimple/helm-secrets --version ${HELM_SECRETS_VERSION} && \
    helm plugin install https://github.com/hypnoglow/helm-s3.git --version ${HELM_S3_VERSION} && \
    helm plugin install https://github.com/aslafy-z/helm-git --version ${HELM_GIT_VERSION}

ADD https://github.com/roboll/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_linux_amd64 /bin/helmfile
RUN chmod 0755 /bin/helmfile
RUN helmfile version

ENTRYPOINT ["/bin/helmfile"]
