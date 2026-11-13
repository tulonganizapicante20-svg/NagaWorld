FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /mhgurecomp-hubserver .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /mhgurecomp-hubserver .

# Copiamos el binario playit de la raíz de GitHub
COPY playit .
RUN chmod +x playit && apk add --no-cache libc6-compat

# Script de inicio ultra robusto que arranca Go y Playit inyectando la llave por argumento
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo './mhgurecomp-hubserver -addr :10555 &' >> /app/start.sh && \
    echo './playit $SECRET_KEY run' >> /app/start.sh && \
    chmod +x /app/start.sh

EXPOSE 10555/tcp 10555/udp
ENTRYPOINT ["/app/start.sh"]