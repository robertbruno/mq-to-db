ARG ARCH="amd64"
ARG OS="linux"
ARG PROJECT_NAME="mq-to-db"

FROM ${ARCH}/busybox:glibc

LABEL maintainer="Mantainer User <mantainer.user@mail.com>" \
      org.opencontainers.image.authors="Mantainer User <mantainer.user@mail.com>" \
      org.opencontainers.image.url="https://github.com/christiangda/${PROJECT_NAME}" \
      org.opencontainers.image.documentation="https://github.com/christiangda/${PROJECT_NAME}" \
      org.opencontainers.image.source="https://github.com/christiangda/${PROJECT_NAME}"

ARG METRICS_PORT="8080"
EXPOSE  ${METRICS_PORT}

RUN mkdir -p /home/nobody && chown -R nobody.nogroup /home/nobody
ENV HOME="/home/nobody"

USER nobody
WORKDIR ${HOME}

COPY /${PROJECT_NAME}  /bin/${PROJECT_NAME}

HEALTHCHECK CMD wget --spider -S "http://localhost:${METRICS_PORT}/health" -T 60 2>&1 || exit 1

VOLUME ["/home/nobody"]

ENTRYPOINT  [ "/bin/${PROJECT_NAME}" ]
# CMD  [ "/bin/${PROJECT_NAME}" ]
