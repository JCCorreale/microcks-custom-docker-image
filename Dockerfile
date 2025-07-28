FROM quay.io/microcks/microcks-uber:latest

COPY jq /usr/local/bin/

COPY import-repositories.sh /import-repositories.sh
RUN chmod +x /import-repositories.sh

ENTRYPOINT ["/import-repositories.sh"]