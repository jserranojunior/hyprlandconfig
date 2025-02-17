#!/bin/bash
# /* ---- 🌟 https://github.com/JaKooLit 🌟 ---- */
# Keyhints. Idea got from Garuda Hyprland

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Check if rofi is running and kill it if it is
if pgrep -x "rofi" > /dev/null; then
    pkill rofi
fi

# Detect monitor resolution and scale
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Calculate width and height based on percentages and monitor resolution
width=$((x_mon * hypr_scale / 100))
height=$((y_mon * hypr_scale / 100))

# Set maximum width and height
max_width=1200
max_height=1000

# Set percentage of screen size for dynamic adjustment
percentage_width=90
percentage_height=90

# Calculate dynamic width and height
dynamic_width=$((width * percentage_width / 100))
dynamic_height=$((height * percentage_height / 100))

# Limit width and height to maximum values
dynamic_width=$(($dynamic_width > $max_width ? $max_width : $dynamic_width))
dynamic_height=$(($dynamic_height > $max_height ? $max_height : $dynamic_height))

# Launch yad with corrected keybindings
GDK_BACKEND=$BACKEND yad --width=$dynamic_width --height=$dynamic_height \
    --center \
    --title="Keybindings" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"🐧+Enter"                 "Abrir Terminal"                       "kitty" \
"🐧+Shift+Enter"           "Abrir DropDown Terminal"              "kitty-pyprland" \
"🐧+D"                     "Abrir Aplicativo (Lançador)"          "rofi-wayland" \
"🐧+T"                     "Abrir Gerenciador de Arquivos"        "Thunar" \
"🐧+S"                     "Busca Google com rofi"               "rofi" \
"🐧+H"                     "Abrir Este App"                      "" \
"🐧+E"                     "Ver/Editar Atalhos, Configurações"   "" \
"🐧+ESC"                   "Fechar a janela ativa"               "" \
"🐧+Shift+Q"               "Matar janela ativa"                  "kill" \
"🐧+Q"                     "Fechar janela ativa sem matar"       "Not kill" \
"######"                   "Resize Windows"                      "######" \
"🐧+j"                     "Redimensionar janela ativa -50 0"     "Redimensionar esquerda" \
"🐧+l"                     "Redimensionar janela ativa +50 0"     "Redimensionar direita" \
"🐧+i"                     "Redimensionar janela ativa 0 -50"     "Redimensionar cima" \
"🐧+k"                     "Redimensionar janela ativa 0 +50"     "Redimensionar baixo" \
"######"                   "Move Windows"                        "######" \
"🐧+CTRL+j"                "Mover janela para a esquerda"         "Mover esquerda" \
"🐧+CTRL+l"                "Mover janela para a direita"          "Mover direita" \
"🐧+CTRL+i"                "Mover janela para cima"              "Mover cima" \
"🐧+CTRL+k"                "Mover janela para baixo"             "Mover baixo" \
"######"                   "Screenshot"                          "######" \
"🐧+X"                     "Captura de tela"                     "grim" \
"🐧+Shift+X"               "Captura de tela (região)"            "grim + slurp" \
"🐧+CTRL+X"                "Captura de tela (temporizador 5s)"   "grim" \
"CTRL+Shift+X"             "Captura de tela (temporizador 10s)"  "grim" \
"ALT+X"                    "Captura de tela (janela ativa)"      "Active window only" \
"######"                   "Outros Atalhos"                     "######" \
"CTRL+ALT+P"               "Menu de Energia"                    "wlogout" \
"CTRL+ALT+L"               "Bloquear Tela"                      "hyprlock" \
"CTRL+ALT+Del"             "Sair do Hyprland"                   "SAVE YOUR WORK!!!" \
"🐧+F"                     "Tela Cheia"                         "Toggle fullscreen" \
"🐧+CTRL+F"                "Tela Cheia Fake"                    "Toggle fake fullscreen" \
"🐧+ALT+L"                 "Alternar Layout Dwindle/Master"     "Hyprland Layout" \
"🐧+Shift+F"               "Alternar Float"                     "Single window" \
"🐧+ALT+F"                 "Alternar todos para float"          "All windows" \
"🐧+Shift+B"               "Alternar Desfoque"                  "Normal ou menos blur" \
"🐧+Shift+A"               "Menu de Animações"                  "Escolher animações via rofi" \
"🐧+Shift+G"               "Modo Game! Desativa todas animações" "Toggle" \
"🐧+ALT+E"                 "Emoticons do Rofi"                  "Emoticon" \
"🐧+ALT+V"                 "Gerenciador de Clipboard"           "cliphist" \
"🐧+B"                     "Ocultar/Reexibir Waybar"            "waybar" \
"🐧+CTRL+B"                "Escolher estilo do Waybar"          "waybar styles" \
"🐧+ALT+B"                 "Escolher layout do Waybar"          "waybar layout" \
"🐧+ALT+R"                 "Recarregar Waybar & swaync"         "Check notification first!!!" \
"🐧+Shift+N"               "Lançar Painel de Notificação"       "swaync Notification Center" \
"🐧+W"                     "Escolher papel de parede"           "Wallpaper Menu" \
"🐧+Shift+W"               "Escolher efeitos de papel de parede" "imagemagick + swww" \
"CTRL+Alt+W"               "Papel de parede aleatório"          "swww" \


