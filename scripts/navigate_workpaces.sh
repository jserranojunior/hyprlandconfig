#!/bin/bash

# Obtém o workspace atual, padrão 1 se não retornar nada
current_ws=$(hyprctl activeworkspace -j | jq -r '.id // 1')

# Lista os workspaces ativos, exceto o atual
readarray -t active_ws < <(hyprctl workspaces -j | jq -r '.[] | .id' | sort -n)

# Se só existir 1 workspace ativo, alterna entre 1 e 2 (ou 4, se preferir)
if [ ${#active_ws[@]} -le 1 ]; then
  if [ "$current_ws" -eq 1 ]; then
    hyprctl dispatch workspace 4
  else
    hyprctl dispatch workspace 1
  fi
  exit 0
fi

# Se mais de um workspace, navega para o próximo na lista, circulando
for i in "${!active_ws[@]}"; do
  if [ "${active_ws[i]}" -eq "$current_ws" ]; then
    next_index=$(( (i + 1) % ${#active_ws[@]} ))
    hyprctl dispatch workspace "${active_ws[next_index]}"
    exit 0
  fi
done

# Caso não encontre o workspace atual na lista, vai para o workspace 1
hyprctl dispatch workspace 1
