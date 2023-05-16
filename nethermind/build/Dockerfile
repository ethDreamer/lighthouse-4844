FROM nethermindeth/nethermind:eip-4844-v5

USER root
RUN apt update && apt install -y tini dnsutils

ARG PROCESS_UID
ARG PROCESS_GID
ARG USER=execution

RUN getent group  ${PROCESS_GID} || groupadd -g ${PROCESS_GID} ${USER}
RUN getent passwd ${PROCESS_UID} || useradd -r -u ${PROCESS_UID} -g ${PROCESS_GID} ${USER};

WORKDIR /home/${USER}/run
RUN chown -R ${PROCESS_UID}:${PROCESS_GID} /home/${USER}

USER ${PROCESS_UID}

ENTRYPOINT ["/usr/bin/tini", "-v", "--", "./execute.sh"]

