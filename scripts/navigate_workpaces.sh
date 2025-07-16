#!/bin/bash

# Obtém o workspace atual
current_ws=$(hyprctl activeworkspace -j | jq -r '.id // 1')

# Lista os workspaces ativos, exceto o atual e o 1
readarray -t relevant_ws < <(
  hyprctl workspaces -j | jq -r --argjson current "$current_ws" '
    [.[] | select(.id != $current and .id > 1) | .id] | sort | .[]
  '
)

# Alterna para o primeiro workspace relevante, se existir; senão alterna entre 1 e 2
if [[ ${#relevant_ws[@]} -gt 0 ]]; then
  hyprctl dispatch workspace "${relevant_ws[0]}"
else
  [[ "$current_ws" -eq 1 ]] && hyprctl dispatch workspace 2 || hyprctl dispatch workspace 1
fi
