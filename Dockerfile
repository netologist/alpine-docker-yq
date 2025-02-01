FROM alpine

RUN apk fix && \
    apk --no-cache --update add yq

VOLUME /opt
WORKDIR /opt

ENTRYPOINT ["yq"]
CMD ["--help"]
