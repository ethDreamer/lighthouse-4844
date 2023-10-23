ARG BASE_IMAGE
FROM ${BASE_IMAGE}

USER root

ARG PROCESS_UID
ARG PROCESS_GID
ARG USER=promuser

RUN if ! grep -q ":x:${PROCESS_GID}:" /etc/group; then \
  addgroup -g ${PROCESS_GID} ${USER}; \
fi

RUN if ! grep -q ":x:${PROCESS_UID}:" /etc/passwd; then \
  adduser -u ${PROCESS_UID} -G ${USER} -h /home/${USER} -s /bin/sh -D ${USER}; \
fi


WORKDIR /home/${USER}/run
RUN chown -R ${PROCESS_UID}:${PROCESS_GID} /home/${USER}

USER ${PROCESS_UID}

ENTRYPOINT [ "./execute.sh" ]

