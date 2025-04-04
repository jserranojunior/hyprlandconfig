#!/bin/bash

get_active_workspaces() {
    hyprctl workspaces -j | jq -r '.[] | .id' | sort -n
}

active_workspaces=($(get_active_workspaces))
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

if [ -z "$current_workspace" ]; then
    current_workspace=1
fi

relevant_workspaces=()
for ws in "${active_workspaces[@]}"; do
    if [ "$ws" -ne "$current_workspace" ] && [ "$ws" -gt 1 ]; then
        relevant_workspaces+=("$ws")
    fi
done

if [ "${#relevant_workspaces[@]}" -gt 0 ]; then
    hyprctl dispatch workspace "${relevant_workspaces[0]}"
else
    if [ "$current_workspace" -eq 1 ]; then
        hyprctl dispatch workspace 2
    else
        hyprctl dispatch workspace 1
    fi
fi
