#!/bin/bash

# Variáveis
MIC_SOURCE="alsa_input.usb-Kingston_HyperX_Quadcast_4110-00.analog-stereo"
VIRTUAL_SINK="VirtualSink"   # DESTINO: Live/Gravação
MONITOR_SINK="MonitorSink"   # DESTINO: Saída de fone de ouvido
REAL_SINK=$(pactl get-default-sink)
REAL_SOURCE=$(pactl get-default-source)

STATE_FILE="/tmp/soundboard_state"

cleanup() {
  echo "🧹 Limpando módulos..."
  
  pactl set-default-sink "$REAL_SINK"
  pactl set-default-source "$REAL_SOURCE" # Adicionado para garantir o reset completo
  echo "↪️ Saída/Entrada restauradas."
  
  pactl list short modules | grep -E "module-loopback|module-null-sink" | \
    grep -E "$VIRTUAL_SINK|$MONITOR_SINK|$MIC_SOURCE" | \
    cut -f1 | xargs -r -n1 pactl unload-module
  
  rm -f "$STATE_FILE"
  echo "✅ Módulos removidos. Saindo."
  exit 0
}

trap cleanup INT TERM

if [[ "$1" == "--stop" ]]; then
  cleanup
fi

if [ -f "$STATE_FILE" ]; then
  echo "❗ Soundboard já está ativo."
  exit 1
fi

touch "$STATE_FILE"

# --- Configuração dos Sinks ---
pactl list short modules | grep "module-null-sink.*sink_name=$VIRTUAL_SINK" | cut -f1 | xargs -r -n1 pactl unload-module
pactl list short modules | grep "module-null-sink.*sink_name=$MONITOR_SINK" | cut -f1 | xargs -r -n1 pactl unload-module

# Cria os sinks virtuais
pactl load-module module-null-sink sink_name=$VIRTUAL_SINK sink_properties=device.description=$VIRTUAL_SINK
pactl load-module module-null-sink sink_name=$MONITOR_SINK sink_properties=device.description=$MONITOR_SINK

# 🎯 Define o MONITOR_SINK como a SAÍDA de áudio padrão do sistema
pactl set-default-sink $MONITOR_SINK

# 🎯 CORREÇÃO: Define o MONITOR do VIRTUAL_SINK como a FONTE (ENTRADA) padrão
pactl set-default-source $VIRTUAL_SINK.monitor

# --- Configura loopbacks ---
# 1. Microfone -> VIRTUAL_SINK (Para a Live)
pactl load-module module-loopback source=$MIC_SOURCE sink=$VIRTUAL_SINK latency_msec=1

# 2. Monitor do MONITOR_SINK -> REAL_SINK (Para VOCÊ ouvir os sons do sistema/soundboard)
pactl load-module module-loopback source=$MONITOR_SINK.monitor sink=$REAL_SINK latency_msec=1

# --- Mute Contra Retorno (Software/Backup) ---
sleep 2 # Aumentei o delay para garantir a estabilidade
pactl list short sink-inputs | grep "$MIC_SOURCE" | cut -f1 | while read id; do
  pactl set-sink-input-mute "$id" 1
done

echo "✅ Soundboard finalizado! Live capta Monitor of $VIRTUAL_SINK. Você escuta via Monitor of $MONITOR_SINK."