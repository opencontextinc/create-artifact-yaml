FROM alpine:latest
RUN apk update && apk upgrade --no-cache && apk add --no-cache jq tar yq
COPY templates /templates
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
