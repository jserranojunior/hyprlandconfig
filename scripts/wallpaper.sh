#!/bin/bash

# --- CONFIGURAÇÕES ---
WALLPAPER_DIR="/home/jorge/Imagens/Wallpaper/"
HYPRPAPER_CONF="/home/jorge/.config/hypr/hyprpaper.conf" # Alterado para sua home para evitar problemas de permissão
MONITOR="" # O monitor que o seu debug identificou
LOG_FILE="/tmp/hyprpaper_selector.log"

> "$LOG_FILE"

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

apply_wallpaper() {
    local image="$1"
    
    # 1. Garante que o diretório existe
    mkdir -p "$(dirname "$HYPRPAPER_CONF")"

    # 2. Atualiza o arquivo físico (O "cat" aqui garante a persistência no reboot)
    # Importante: Removi espaços extras e usei aspas simples no EOF para evitar expansão indesejada
    cat > "$HYPRPAPER_CONF" <<EOF
preload = $image
wallpaper = $MONITOR,$image
EOF
    
    # 3. Aplica em tempo real via IPC
    if pgrep hyprpaper >/dev/null; then
        # Precarrega a nova
        hyprctl hyprpaper preload "$image" &>> "$LOG_FILE"
        sleep 0.2
        # Aplica a nova
        hyprctl hyprpaper wallpaper "$MONITOR,$image" &>> "$LOG_FILE"
        sleep 0.2
        # 4. LIMPEZA INTELIGENTE: 
        # Em vez de 'unload all', vamos descarregar tudo EXCETO a imagem atual
        # Isso evita que o Hyprpaper fique "vazio"
        hyprctl hyprpaper unload unused &>> "$LOG_FILE"
    else
        # Se não estiver rodando, inicia
        hyprpaper -c "$HYPRPAPER_CONF" &>> "$LOG_FILE" &
    fi
    
    echo "$image" > ~/.current_wallpaper
}
select_wallpaper() {
    # Usando find para listar as imagens e passar para o fzf com preview do chafa
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | \
    fzf --height=90% \
        --border \
        --margin=1 \
        --padding=1 \
        --color='border:#FFA500' \
        --preview "chafa --size 60x40 --symbols block --colors 256 {}" \
        --preview-window="right,50%,border-left" \
        --header=$'[↑↓] Navegar  [Enter] Selecionar  [ESC] Cancelar' \
        --bind 'q:abort'
}

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
exituby