#!/bin/bash

# Recebe o nome do arquivo como argumento (ex: 2.mp3)
AUDIO="$1"
CAMINHO_AUDIO="/opt/hyprlandconfig/soundboard/$AUDIO"

# Arquivos temporários para guardar os PIDs de cada paplay individual
PID_MONITOR="/tmp/soundboard_${AUDIO%.*}_monitor.pid"
PID_VIRTUAL="/tmp/soundboard_${AUDIO%.*}_virtual.pid"

# Se os arquivos de PID existem, significa que o som já está tocando
if [ -f "$PID_MONITOR" ] || [ -f "$PID_VIRTUAL" ]; then
    # O 'kill -9' força o encerramento imediato na raiz, limpando o buffer na hora
    [ -f "$PID_MONITOR" ] && kill -9 $(cat "$PID_MONITOR") 2>/dev/null
    [ -f "$PID_VIRTUAL" ] && kill -9 $(cat "$PID_VIRTUAL") 2>/dev/null
    
    # Limpa os arquivos temporários e fecha
    rm -f "$PID_MONITOR" "$PID_VIRTUAL"
    exit 0
fi

# --- SE NÃO ESTAVA RODANDO, TOCA O SOM INSTANTANEAMENTE ---

# Toca no seu fone (MonitorSink) e salva o ID do processo
paplay --device=MonitorSink "$CAMINHO_AUDIO" &
echo $! > "$PID_MONITOR"

# Toca na Live (VirtualSink) e salva o ID do processo
paplay --device=VirtualSink "$CAMINHO_AUDIO" &
echo $! > "$PID_VIRTUAL"

# Espera os dois terminarem de tocar naturalmente (se você não apertar a tecla de novo)
wait
rm -f "$PID_MONITOR" "$PID_VIRTUAL"