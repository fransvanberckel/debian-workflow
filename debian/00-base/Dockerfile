ARG IMAGE
ARG http_proxy
ARG https_proxy
FROM $IMAGE
COPY get-package-list.sh debian-cleanup.sh functions.sh yq.list /
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
RUN apt-get -qq update && \
    apt-get -qq --yes --no-install-recommends install apt-utils gnupg 2>/dev/null && \
    mv yq.list /etc/apt/sources.list.d && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 6657DBE0CC86BB64 2>/dev/null
RUN apt-get update && \
    apt-get --yes --no-install-recommends install $(/get-package-list.sh) && \
    apt-get --yes autoremove --purge && \
    apt-get --yes dist-upgrade && \
    apt-get --yes clean && \
    $(/debian-cleanup.sh)
