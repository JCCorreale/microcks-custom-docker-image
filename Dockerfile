FROM quay.io/microcks/microcks-uber:latest

USER root

COPY jq /usr/local/bin/

COPY import-repositories.sh /import-repositories.sh

ENTRYPOINT ["/import-repositories.sh"]