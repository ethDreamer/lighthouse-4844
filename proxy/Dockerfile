FROM ethdreamer/json_rpc_snoop:latest

USER root
RUN chown -R json_rpc_snoop:json_rpc_snoop /home/json_rpc_snoop
USER json_rpc_snoop
RUN mkdir /home/json_rpc_snoop/run

ENTRYPOINT ["/usr/bin/tini", "-v", "--", "/home/json_rpc_snoop/run/execute.sh"]
