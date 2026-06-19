#!/bin/bash

# Identifica o fone real e microfone automaticamente
REAL_SINK=$(pactl get-default-sink)
REAL_MIC="alsa_input.usb-Kingston_HyperX_Quadcast_4110-00.analog-stereo"

if [ -f "/tmp/soundboard_state" ]; then
    # Se está ligado, desliga
    /opt/hyprlandconfig/soundboard/stop.sh >/dev/null 2>&1
    sleep 0.5
    pactl set-default-sink "$REAL_SINK" 2>/dev/null
    pactl set-default-source "$REAL_MIC" 2>/dev/null
    notify-send "Soundboard" "🔴 Desativado - Áudio Padrão Restaurado"
else
    # Se está desligado, liga
    /opt/hyprlandconfig/soundboard/start.sh >/dev/null 2>&1
    sleep 0.6
    pactl set-default-sink "MonitorSink" 2>/dev/null
    pactl set-default-source "VirtualSink.monitor" 2>/dev/null
    notify-send "Soundboard" "🟢 Ativo - Roteamento Concluído"
fi