ARG IMAGE
ARG http_proxy
ARG https_proxy
FROM $IMAGE
COPY get-package-list.sh debian-cleanup.sh functions.sh yq.list /
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get update -qq && \
    apt-get install -qq --yes --no-install-recommends apt-utils gnupg 2>/dev/null && \
    mv yq.list /etc/apt/sources.list.d && \
    apt-key adv -qq --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 6657DBE0CC86BB64 2>/dev/null
RUN apt-get update && \
    apt-get install --yes --no-install-recommends $(/get-package-list.sh) && \
    apt-get autoremove --yes && \
    apt-get dist-upgrade --yes && \
    apt-get clean && \
    $(/debian-cleanup.sh)

