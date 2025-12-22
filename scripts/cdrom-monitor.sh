#!/bin/bash

# Este script utiliza a verificação de tamanho de bloco e o comando 'break' 
# para garantir que o VLC abra APENAS UMA VEZ na inserção da mídia.

# --- CONFIGURAÇÕES ---
CD_DEVICE="/dev/sr0"
LOG_FILE="/tmp/cdrom_monitor.log"
USER_ID="jorge" # <--- SUBSTITUA PELO SEU NOME DE USUÁRIO
UID_USER=$(id -u $USER_ID)

# --- CONFIGURAÇÕES DE SESSÃO (CORREÇÃO DE AUTORIZAÇÃO) ---
export XDG_RUNTIME_DIR="/run/user/$UID_USER"
export DISPLAY=:0

# TRUQUE FINAL: Permite a execução de aplicativos X11/XWayland sem erro de autorização.
xhost +

echo "$(date): [START] Monitorando $CD_DEVICE. Aguardando inserção de mídia..." >> "$LOG_FILE"

# Loop principal para monitorar o drive
while true; do
    inotifywait -e attrib,open --timeout 0 "$CD_DEVICE"

    if [ $? -eq 0 ]; then
        echo "$(date): [EVENTO] Mídia detectada. Verificando presença..." >> "$LOG_FILE"
        sleep 3
        
        SIZE=$(cat /sys/block/sr0/size 2>/dev/null)

        if [ "$SIZE" -gt 0 ]; then
            echo "$(date): [SUCESSO] Mídia válida ($SIZE > 0). Abrindo VLC..." >> "$LOG_FILE"

            # COMANDO FINAL PARA CD DE ÁUDIO!
            /usr/bin/vlc cdda:///dev/sr0 &
            
            # ESSENCIAL: Interrompe o loop após o sucesso.
            break 
        else
            echo "$(date): [FALHA] SIZE=0. Ignorando evento de ejeção/vazio." >> "$LOG_FILE"
        fi
    fi
done

echo "$(date): [END] Monitoramento encerrado." >> "$LOG_FILE"