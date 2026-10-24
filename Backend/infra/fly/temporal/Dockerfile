FROM temporalio/ui:2.27.2 as ui
FROM temporalio/server:1.24.1.0 as server

WORKDIR /etc/temporal

FROM temporalio/auto-setup:1.24.1.0 as final

COPY --from=ui --chown=temporal:temporal /home/ui-server /home/ui-server
RUN rm -rf /home/ui-server/config/*

EXPOSE 7233 8080

ENV DB=postgres12
ENV DB_PORT=5432 

ENV BIND_ON_IP=0.0.0.0
ENV TEMPORAL_BROADCAST_ADDRESS=0.0.0.0
ENV DEFAULT_NAMESPACE=default

ENV DYNAMIC_CONFIG_FILE_PATH=/etc/temporal/config/dynamicconfig/docker.yaml

# These two .sh files are defined below
COPY ./start.sh /etc/temporal/start.sh
COPY ./start-ui.sh /etc/temporal/start-ui.sh
CMD ["autosetup"]

ENTRYPOINT ["/etc/temporal/start.sh"]
