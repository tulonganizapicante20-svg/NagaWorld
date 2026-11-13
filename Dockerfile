FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /mhgurecomp-hubserver .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /mhgurecomp-hubserver .

# Instalamos curl y el cliente oficial de Playit.gg para los puertos TCP/UDP
RUN apk add --no-cache curl
RUN curl -SsL https://github.com/playit-cloud/playit-agent/releases/download/v0.15.2/playit-0.15.2_x86_64 -o playit && chmod +x playit

# Script de inicio para correr el servidor de Monster Hunter y Playit al mismo tiempo
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo './mhgurecomp-hubserver -addr :10164 &' >> /app/start.sh && \
    echo './playit' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 10164/tcp 10164/udp
ENTRYPOINT ["/app/start.sh"]