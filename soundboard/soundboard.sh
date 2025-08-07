#!/bin/bash

MIC_SOURCE="alsa_input.usb-Kingston_HyperX_Quadcast_4110-00.analog-stereo"
VIRTUAL_SINK="VirtualSink"
MONITOR_SINK="MonitorSink"
REAL_SINK=$(pactl get-default-sink)

STATE_FILE="/tmp/soundboard_state"

cleanup() {
  echo "🧹 Limpando módulos..."
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

# Remove sinks antigos se existirem
pactl list short modules | grep "module-null-sink.*sink_name=$VIRTUAL_SINK" | cut -f1 | xargs -r -n1 pactl unload-module
pactl list short modules | grep "module-null-sink.*sink_name=$MONITOR_SINK" | cut -f1 | xargs -r -n1 pactl unload-module

# Cria os sinks virtuais
pactl load-module module-null-sink sink_name=$VIRTUAL_SINK sink_properties=device.description=$VIRTUAL_SINK
pactl load-module module-null-sink sink_name=$MONITOR_SINK sink_properties=device.description=$MONITOR_SINK

# Configura loopbacks
pactl load-module module-loopback source=$MIC_SOURCE sink=$VIRTUAL_SINK latency_msec=1
pactl load-module module-loopback source=$MONITOR_SINK.monitor sink=$REAL_SINK latency_msec=1

# Muta o microfone no retorno (para evitar eco)
sleep 1
pactl list short sink-inputs | grep "$MIC_SOURCE" | cut -f1 | while read id; do
  pactl set-sink-input-mute "$id" 1
done

echo "✅ Soundboard configurado! Use os binds do Hyprland para tocar sons."