#!/bin/bash

# Função para obter workspaces ativos ordenados
get_active_workspaces() {
    hyprctl workspaces -j | jq -r '.[] | .id' | sort -n
}

# Obter workspaces ativos e workspace atual
active_workspaces=($(get_active_workspaces))
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Se não houver workspace ativo, começa no 1
if [ -z "$current_workspace" ]; then
    current_workspace=1
fi

# Filtrar workspaces ativos maiores que 1 (para o caso de só querermos alternar entre 1 e outros)
relevant_workspaces=()
for ws in "${active_workspaces[@]}"; do
    if [ "$ws" -ne "$current_workspace" ] && [ "$ws" -gt 1 ]; then
        relevant_workspaces+=("$ws")
    fi
done

# Se houver workspaces relevantes (além do 1 e do atual)
if [ "${#relevant_workspaces[@]}" -gt 0 ]; then
    # Vai para o primeiro workspace relevante
    hyprctl dispatch workspace "${relevant_workspaces[0]}"
else
    # Se não houver workspaces relevantes, alterna entre 1 e 2
    if [ "$current_workspace" -eq 1 ]; then
        hyprctl dispatch workspace 2
    else
        hyprctl dispatch workspace 1
    fi
fi