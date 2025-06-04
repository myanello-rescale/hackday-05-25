# syntax=docker/dockerfile:1
ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/python/python39
ARG BASE_TAG=3.9
ARG BASE_DIGEST=sha256:4115bd7363870546a28b781aa00049f5ffad9520b8f84652beb0411004f23beb

ARG NODE_REGISTRY=docker.io
ARG NODE_IMAGE=node
ARG NODE_TAG=18-bullseye-slim
ARG NODE_DIGEST=sha256:912df8d9d8d23d39b463a8634d51cac990d89d2f62a6504e1d35296eb4f38251
# syntax=docker/dockerfile:1
ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/python/python39
ARG BASE_TAG=3.9
ARG BASE_DIGEST=sha256:4115bd7363870546a28b781aa00049f5ffad9520b8f84652beb0411004f23beb

ARG NODE_REGISTRY=docker.io
ARG NODE_IMAGE=node
ARG NODE_TAG=18-bullseye-slim
ARG NODE_DIGEST=sha256:912df8d9d8d23d39b463a8634d51cac990d89d2f62a6504e1d35296eb4f38251

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}@${BASE_DIGEST} AS base
WORKDIR /opt/rescale/
ARG APP_ROOT=/opt/rescale/
ARG HOME=${APP_ROOT}/
ARG UV_LINK_MODE=copy
ARG UV_COMPILE_BYTECODE=1
USER root
COPY ./rescale-platform-web/pyproject.toml ./rescale-platform-web/.python-version ./rescale-platform-web/docker/openssl/openssl-verify.sh /opt/rescale/
# we gotta do some BS to get the openssl version we need
COPY ./rescale-platform-web/docker/openssl/Rocky-Devel.repo ./rescale-platform-web/docker/openssl/Alma.repo /etc/yum.repos.d/
COPY ./rescale-platform-web/docker/openssl/RPM-GPG-KEY-rockyofficial ./rescale-platform-web/docker/openssl/RPM-GPG-KEY-AlmaLinux9 /etc/pki/rpm-gpg/
RUN dnf config-manager --add-repo /etc/yum.repos.d/Rocky-Devel.repo && \
    dnf config-manager --set-enabled devel && \
    dnf config-manager --add-repo /etc/yum.repos.d/Alma.repo && \
    dnf config-manager --set-enabled alma && \
    dnf config-manager --set-enabled alma-base && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux9
# after seeing this error: https://forums.rockylinux.org/t/rhel-9-to-rocky-9-issue/14251 try removing openssl-fips-provider
RUN rpm -e openssl-fips-provider openssl-fips-provider-so --nodeps
RUN dnf install -y --refresh --allowerasing \
    openssl-devel-3.0.7 rust cargo gcc gcc-c++ \
    make openssh-clients git pkgconf-pkg-config \
    xmlsec1-devel libpq-devel libtool-ltdl-devel

FROM base AS poetry-builder
WORKDIR /opt/rescale/
ARG APP_ROOT=/opt/rescale/
ARG HOME=${APP_ROOT}/
USER root
RUN pip install poetry && \
    python3 -m venv venv
RUN mkdir -p -m 600 /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN --mount=type=ssh \
    source venv/bin/activate && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    poetry config --local installer.no-binary cryptography && \
    poetry install --verbose --no-interaction --no-root && \
    # Verify that python cryptography uses the OpenSSL we require
    bash -c "source /opt/rescale/venv/bin/activate && /opt/rescale/openssl-verify.sh"


FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}@${BASE_DIGEST} AS backend
ARG APP_ROOT=/opt/app-root
ARG HOME=${APP_ROOT}/src \
    PATH=$HOME/.local/bin/:/opt/app-root/src/bin:/opt/app-root/bin:$PATH
USER root
WORKDIR /opt/rescale
RUN dnf upgrade -y --refresh --nodocs && \
    dnf install -y --nodocs \
    xmlsec1-openssl gettext git \
    openssh openssh-clients libpq-devel && \
    dnf -y clean all && rm -rf /var/dnf/cache
COPY rescale-platform-metadata ./rescale-platform-metadata
COPY rescale-platform-web ./rescale-platform-web
COPY --from=poetry-builder /opt/rescale/venv venv 


FROM backend AS backend-prod
RUN find /opt/ -name '.git' -exec rm -rf {} + && \
    find /opt/ -name '.github' -exec rm -rf {} + && \
    find /opt/ -name 'git-hooks' -exec rm -rf {} +


FROM backend-prod AS backend-hardened
RUN dnf remove -y \
    perl-macros perl-base perl-libs perl-IO \
    perl-interpreter perl-Errno perl-HTTP-Tiny \
    perl-Git subscription-manager python3-syspurpose \
    python3-subscription-manager-rhsm \
    dnf-plugin-subscription-manager \
    python3-cloud-what perl ncurses
RUN chmod -R ug-s /opt/rescale/
RUN chmod -f ug-s /usr/bin/chage /usr/bin/gpasswd /usr/bin/mount /usr/bin/newgrp /usr/bin/passwd \
    /usr/bin/su /usr/bin/umount /usr/libexec/utempter/utempter /usr/sbin/pam_timestamp_check \
    /usr/sbin/unix_chkpwd /usr/sbin/userhelper /usr/libexec/openssh/ssh-keysign
# Removing wrapper script folder to fix vuln in numba package in requirement.txt in analysis_wrapper_scripts
# the wrapper scripts only get added to the analysis images and thats where they actually run
# anchore is reading that req.txt and using that as its signal for the vuln
RUN rm -rf /opt/rescale/rescale-platform-metadata/jobs/management/commands/analysis_wrapper_scripts
RUN rm -rf /opt/rescale/venv/src
RUN pip uninstall -y pip && \
    rm -rf /usr/local/lib/python3.9/site-packages/pip \
    /opt/app-root/lib/python3.9/site-packages/setuptools \
    /opt/app-root/lib/python3.9/site-packages/setuptools-53.0.0.dist-info \
    /usr/local/lib/python3.9/site-packages/setuptools \
    /usr/local/lib/python3.9/site-packages/setuptools-69.1.1.dist-info
RUN update-crypto-policies --set FIPS:NO-ENFORCE-EMS


FROM ${NODE_REGISTRY}/${NODE_IMAGE}:${NODE_TAG}@${NODE_DIGEST} AS frontend-builder
WORKDIR /opt/rescale/rescale-platform-web
RUN npm config set engine-strict true && \
    echo "NODE_PATH=apps/shared:apps" >> .env && \
    echo "NODE_OPTIONS=--max-old-space-size=8192" >> .env
COPY ./rescale-platform-web ./
# we need the venv for some frontend scripts
COPY --from=poetry-builder /opt/rescale/venv /opt/rescale/venv 
RUN npm install
RUN npm run build


# use the backend image because it has our python stuff
FROM backend AS frontend 
WORKDIR /opt/rescale/rescale-platform-web
COPY --from=frontend-builder /opt/rescale/rescale-platform-web/ /opt/rescale/
ARG NODE_VERSION=18 
RUN dnf module enable -y nodejs:$NODE_VERSION && \
    dnf install -y --nodocs nodejs