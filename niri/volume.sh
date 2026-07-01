#!/bin/bash

ACAO=$1

if [ "$ACAO" = "up" ]; then
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 1%+
    ICON="audio-volume-high"
elif [ "$ACAO" = "down" ]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
    ICON="audio-volume-medium"
fi

# Pega o volume atual formatado
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100 + 0.5)}')

# Envia a notificação
notify-send -h string:x-canonical-private-synchronous:sys-notify -h int:value:"$VOL" -i "$ICON" -u low "Volume" "${VOL}%"