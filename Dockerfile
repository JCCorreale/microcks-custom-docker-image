FROM quay.io/microcks/microcks-uber:latest

USER root

COPY jq /usr/local/bin/
RUN chmod +x /usr/local/bin/jq

COPY import-repositories.sh /import-repositories.sh
RUN chmod +x /import-repositories.sh

ENTRYPOINT ["/import-repositories.sh"]