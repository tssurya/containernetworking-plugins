# This dockerfile is specific to building Multus for OpenShift
FROM openshift/origin-release:rhel-8-golang-1.12 as rhel8
ADD . /usr/src/plugins
WORKDIR /usr/src/plugins
ENV CGO_ENABLED=0
RUN ./build_linux.sh && \
    cd /usr/src/plugins/bin
WORKDIR /

FROM openshift/origin-release:rhel-7-golang-1.12 as rhel7
ADD . /usr/src/plugins
WORKDIR /usr/src/plugins
ENV CGO_ENABLED=0
RUN ./build_linux.sh && \
    cd /usr/src/plugins/bin
WORKDIR /

FROM openshift/origin-base
RUN mkdir -p /usr/src/plugins/bin && \
    mkdir -p /usr/src/plugins/rhel7/bin && \
    mkdir -p /usr/src/plugins/rhel8/bin
COPY --from=rhel7 /usr/src/plugins/bin/* /usr/src/plugins/rhel7/bin/
COPY --from=rhel7 /usr/src/plugins/bin/* /usr/src/plugins/bin/
COPY --from=rhel8 /usr/src/plugins/bin/* /usr/src/plugins/rhel8/bin/

LABEL io.k8s.display-name="Container Networking Plugins" \
      io.k8s.description="This is a component of OpenShift Container Platform and provides the reference CNI plugins." \
      io.openshift.tags="openshift" \
      maintainer="Doug Smith <dosmith@redhat.com>"

