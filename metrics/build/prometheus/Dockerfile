ARG BASE_IMAGE
FROM ${BASE_IMAGE}

USER root

ARG PROCESS_UID
ARG PROCESS_GID
ARG USER=promuser

RUN getent group ${PROCESS_GID}  || addgroup -S ${USER} -g ${PROCESS_GID}
RUN getent passwd ${PROCESS_UID} || adduser  -S ${USER} -G ${USER} -u ${PROCESS_UID}

WORKDIR /home/${USER}/run
RUN chown -R ${PROCESS_UID}:${PROCESS_GID} /home/${USER}

USER ${PROCESS_UID}

ENTRYPOINT [ "./execute.sh" ]

