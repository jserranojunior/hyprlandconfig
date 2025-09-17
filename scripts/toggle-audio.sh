#!/bin/bash

# Verifica qual é o sink atual
current_sink=$(pactl get-default-sink)

if [[ "$current_sink" == "alsa_output.pci-0000_00_1b.0.analog-stereo" ]]; then
    pactl set-default-sink "alsa_output.usb-Kingston_HyperX_Quadcast_4110-00.analog-stereo"
    notify-send "Áudio" "Saída definida para HyperX"
else
    pactl set-default-sink "alsa_output.pci-0000_00_1b.0.analog-stereo"
    notify-send "Áudio" "Saída definida para Interno"
fi