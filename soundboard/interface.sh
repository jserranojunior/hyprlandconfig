#!/bin/bash

# Caminho dos seus scripts
START_SCRIPT="/opt/hyprlandconfig/soundboard/start.sh"
STOP_SCRIPT="/opt/hyprlandconfig/soundboard/stop.sh"

# Salva qual é o seu fone de ouvido real antes de qualquer alteração
REAL_SINK=$(pactl get-default-sink)

encerrar_tudo() {
    echo -e "\n🧹 Encerrando painel e restaurando áudio original..."
    if [ -f "$STOP_SCRIPT" ]; then
        $STOP_SCRIPT >/dev/null 2>&1
    fi
    # Garante que o sistema volta para o fone físico ao fechar o app
    pactl set-default-sink "$REAL_SINK" 2>/dev/null
    exit 0
}

trap encerrar_tudo SIGINT SIGTERM

while true; do
    if [ -f "/tmp/soundboard_state" ]; then
        STATUS_TEXT="<span foreground='#A3BE8C'><b>ESTADO: ATIVO</b></span>"
    else
        STATUS_TEXT="<span foreground='#BF616A'><b>ESTADO: DESATIVADO</b></span>"
    fi

    # --- Janela YAD ---
    yad --title="Soundboard Panel" \
        --window-icon="audio-volume-high-symbolic" \
        --width=350 \
        --height=180 \
        --fixed \
        --pane \
        --form \
        --separator="" \
        --field="<span size='xx-large'>🎙️</span>":LBL "" \
        --field="<span size='large'><b>Mixer de Áudio Virtual</b></span>":LBL "" \
        --field="":LBL "" \
        --field="<span size='x-large'>$STATUS_TEXT</span>":LBL "" \
        --field="":LBL "" \
        --class="soundboard_gui" \
        --style='
            .soundboard_gui { background-color: #2E3440; color: #ECEFF4; border: 1px solid #4C566A; border-radius: 8px; }
            .soundboard_gui button { padding: 10px 20px; border-radius: 5px; font-weight: bold; border: none; }
            .soundboard_gui button#yad-b2 { background-color: #A3BE8C; color: #2E3440; }
            .soundboard_gui button#yad-b2:hover { background-color: #B48EAD; }
            .soundboard_gui button#yad-b3 { background-color: #BF616A; color: #ECEFF4; }
            .soundboard_gui button#yad-b3:hover { background-color: #B48EAD; }
            .soundboard_gui button#yad-b1 { background-color: #4C566A; color: #ECEFF4; }
            .soundboard_gui button#yad-b1:hover { background-color: #D8DEE9; color: #2E3440; }
        ' \
        --button="LIGAR":2 \
        --button="DESLIGAR":3 \
        --button="Sair":1

    RETORNO=$?

    case $RETORNO in
        2)  # Clicou em LIGAR
            if [ -f "$START_SCRIPT" ]; then
                # 1. Atualiza qual é o fone real caso você tenha mudado ele manualmente antes
                REAL_SINK=$(pactl get-default-sink)
                
                # 2. Roda o seu script de ativação
                $START_SCRIPT >/dev/null 2>&1
                sleep 0.5
                
                # 3. MUDA O ÁUDIO PARA O RETORNO (MonitorSink)
                pactl set-default-sink "MonitorSink" 2>/dev/null
                sleep 0.3
            fi
            ;;
        3)  # Clicou em DESLIGAR
            if [ -f "$STOP_SCRIPT" ]; then
                # 1. Roda o script que limpa os módulos virtuais
                $STOP_SCRIPT >/dev/null 2>&1
                sleep 0.5
                
                # 2. VOLTA O ÁUDIO PARA O SEU FONE FÍSICO
                pactl set-default-sink "$REAL_SINK" 2>/dev/null
                sleep 0.3
            fi
            ;;
        1|252) 
            encerrar_tudo
            ;;
    esac
done