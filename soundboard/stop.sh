#!/bin/bash

# Para todos os áudios que estão tocando agora
killall paplay 2>/dev/null
rm -f /tmp/soundboard_play_*.pid

# Seu comando original de parada
/opt/hyprlandconfig/soundboard/soundboard.sh --stop