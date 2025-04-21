#!/bin/bash

# Variáveis
URL="http://127.0.0.1"
LOG_FILE="/var/log/monitoramento.log"
WEBHOOK_URL="$DISCORD_WEBHOOK_URL"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Verificar se o diretório de log existe, se não, criar
if [ ! -d "/var/log" ]; then
    sudo mkdir -p /var/log
    sudo chmod 755 /var/log
fi

# Verificar o status do site
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" --connect-timeout 5)

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "[$TIMESTAMP] Site $URL está OK (Status: $STATUS_CODE)" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] Site $URL está FORA DO AR (Status: $STATUS_CODE)" >> "$LOG_FILE"
    # Enviar notificação ao Discord
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"🚨 ALERTA: Site $URL está FORA DO AR! Status: $STATUS_CODE em $TIMESTAMP\"}" \
         "$WEBHOOK_URL"
fi
