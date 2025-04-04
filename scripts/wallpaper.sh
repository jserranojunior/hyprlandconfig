#!/bin/bash

# Configurações
WALLPAPER_DIR="/home/jorge/Imagens/Wallpaper/"
HYPRPAPER_CONF="/opt/hyprland/hypr/hyprpaper.conf"
LOG_FILE="/tmp/hyprpaper_selector.log"

# Limpar logs anteriores
> "$LOG_FILE"

# Verificar dependências
check_deps() {
    local missing=()
    command -v fzf >/dev/null || missing+=("fzf")
    command -v hyprctl >/dev/null || missing+=("hyprland")
    command -v chafa >/dev/null || missing+=("chafa")
    
    [ ${#missing[@]} -gt 0 ] && {
        notify-send "Erro" "Dependências faltando: ${missing[*]}" &>> "$LOG_FILE"
        exit 1
    }
}

# Aplicar wallpaper
apply_wallpaper() {
    local image="$1"
    
    # Criar configuração
    cat > "$HYPRPAPER_CONF.tmp" <<EOF && mv -f "$HYPRPAPER_CONF.tmp" "$HYPRPAPER_CONF"
preload = $image
wallpaper = ,$image
EOF
    
    # Recarregar hyprpaper
    if pgrep hyprpaper >/dev/null; then
        hyprctl hyprpaper unload all &>> "$LOG_FILE"
        hyprctl hyprpaper preload "$image" &>> "$LOG_FILE"
        hyprctl hyprpaper wallpaper ",$image" &>> "$LOG_FILE"
    else
        hyprpaper -c "$HYPRPAPER_CONF" &>> "$LOG_FILE" &
    fi
    
    echo "$image" > ~/.current_wallpaper
}

# Selecionar imagem
select_wallpaper() {
    fzf --height=90% \
        --border \
        --margin=1 \
        --padding=1 \
        --color='border:#FFA500' \
        --preview "chafa --size $(($(tput cols)/3))x$(($(tput lines)-5)) --symbols block --colors 256 {}" \
        --preview-window="right,50%,border-left" \
        --header=$'[↑↓] Navegar  [Enter] Selecionar  [ESC] Cancelar' \
        --bind 'q:abort' \
        < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \)) 2>/dev/null
}

# Main
check_deps
clear
IMAGE=$(select_wallpaper)

if [[ -n "$IMAGE" && -f "$IMAGE" ]]; then
    apply_wallpaper "$IMAGE"
    notify-send "Wallpaper Atualizado" "$(basename "$IMAGE")" -i "$IMAGE" &>> "$LOG_FILE"
else
    notify-send "Wallpaper" "Seleção cancelada" &>> "$LOG_FILE"
fi

clear
exit