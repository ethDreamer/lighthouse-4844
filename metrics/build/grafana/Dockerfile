ARG BASE_IMAGE
FROM ${BASE_IMAGE}

USER root

ARG PROCESS_UID
ARG PROCESS_GID
ARG USER=grafuser

RUN getent group ${PROCESS_GID}  || addgroup -S ${USER} -g ${PROCESS_GID}
RUN getent passwd ${PROCESS_UID} || adduser  -S ${USER} -G `getent group ${PROCESS_GID} | cut -d: -f1` -u ${PROCESS_UID}

RUN mkdir /tmp/grafold/
RUN mv /etc/grafana/provisioning /tmp/grafold && mv /etc/grafana/grafana.ini /tmp/grafold

WORKDIR /home/${USER}/run
RUN chown -R ${PROCESS_UID}:${PROCESS_GID} /home/${USER}

RUN cd /etc/grafana && ln -s /home/${USER}/run/provisioning && ln -s /home/${USER}/run/grafana.ini

USER ${PROCESS_UID}

