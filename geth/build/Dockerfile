ARG GETH_IMAGE
FROM ${GETH_IMAGE}

USER root

RUN apk add --no-cache ca-certificates tini jq curl bash

ARG PROCESS_UID
ARG PROCESS_GID
ARG USER=execution

RUN getent group  ${PROCESS_GID} || addgroup -g ${PROCESS_GID} ${USER}
RUN getent passwd ${PROCESS_UID} || adduser -S execution -G `getent group ${PROCESS_GID} | cut -d: -f1` -s /bin/bash -u ${PROCESS_UID}

WORKDIR /home/${USER}/run
RUN chown -R ${PROCESS_UID}:${PROCESS_GID} /home/${USER}

USER ${PROCESS_UID}

ENTRYPOINT ["/sbin/tini", "-v", "--", "./execute.sh"]
