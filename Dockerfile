FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /mhgurecomp-hubserver .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /mhgurecomp-hubserver .

# Instalamos dependencias y wget para una descarga limpia
RUN apk add --no-cache wget libc6-compat

# Descarga directa del binario oficial de playit con wget asegurando el archivo correcto
RUN wget -O playit https://github.com/playit-cloud/playit-agent/releases/download/v0.15.2/playit-0.15.2_x86_64 && chmod +x playit

# Script de inicio
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo './mhgurecomp-hubserver -addr :39510 &' >> /app/start.sh && \
    echo './playit run' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 39510/tcp 39510/udp
ENTRYPOINT ["/app/start.sh"]