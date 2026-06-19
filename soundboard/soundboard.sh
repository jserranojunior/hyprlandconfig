#!/bin/bash

# Variáveis
MIC_SOURCE="alsa_input.usb-Kingston_HyperX_Quadcast_4110-00.analog-stereo"
VIRTUAL_SINK="VirtualSink"   # Onde vai o Mic + Soundboard (Entrada do Discord)
MONITOR_SINK="MonitorSink"   # Onde vai o som do PC/Jogos (Sua saída)
REAL_SINK=$(pactl get-default-sink)
REAL_SOURCE=$(pactl get-default-source)

STATE_FILE="/tmp/soundboard_state"

cleanup() {
  echo "🧹 Limpando módulos..."
  pactl set-default-sink "$REAL_SINK"
  pactl set-default-source "$REAL_SOURCE"
  
  pactl list short modules | grep -E "module-loopback|module-null-sink" | \
    grep -E "$VIRTUAL_SINK|$MONITOR_SINK" | \
    cut -f1 | xargs -r -n1 pactl unload-module
  
  rm -f "$STATE_FILE"
  echo "✅ Áudio restaurado."
  exit 0
}

trap cleanup INT TERM
if [[ "$1" == "--stop" ]]; then cleanup; fi
if [ -f "$STATE_FILE" ]; then exit 1; fi
touch "$STATE_FILE"

# Remove módulos antigos para evitar duplicação
pactl list short modules | grep "module-null-sink.*sink_name=$VIRTUAL_SINK" | cut -f1 | xargs -r -n1 pactl unload-module
pactl list short modules | grep "module-null-sink.*sink_name=$MONITOR_SINK" | cut -f1 | xargs -r -n1 pactl unload-module

# 1. Cria os canais virtuais de áudio
pactl load-module module-null-sink sink_name=$VIRTUAL_SINK sink_properties=device.description=$VIRTUAL_SINK
pactl load-module module-null-sink sink_name=$MONITOR_SINK sink_properties=device.description=$MONITOR_SINK

# 2. Direciona o som geral do sistema para você ouvir no fone de ouvido físico
pactl load-module module-loopback source=$MONITOR_SINK.monitor sink="$REAL_SINK" latency_msec=1 dont_queue_audio=1

# 3. Joga o seu microfone Quadcast para dentro do canal da Live/Discord
pactl load-module module-loopback source="$MIC_SOURCE" sink=$VIRTUAL_SINK latency_msec=1 dont_queue_audio=1

# 4. Define o MonitorSink como padrão de SAÍDA do sistema para os jogos caírem nele
pactl set-default-sink $MONITOR_SINK

echo "✅ Cabos virtuais conectados com sucesso."