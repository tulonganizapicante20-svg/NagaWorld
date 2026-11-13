FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /mhgurecomp-hubserver .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /mhgurecomp-hubserver .

# Instalamos dependencias necesarias y descargamos el agente de playit de forma segura
RUN apk add --no-cache curl libc6-compat
RUN curl -Lo playit https://github.com/playit-cloud/playit-agent/releases/download/v0.15.2/playit-0.15.2_x86_64 && chmod +x playit

# Creamos el script de inicio para ambos procesos
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo './mhgurecomp-hubserver -addr :10555 &' >> /app/start.sh && \
    echo './playit run' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 10555/tcp 10555/udp
ENTRYPOINT ["/app/start.sh"]