#!/bin/bash

updates=$(dnf check-update -q 2>/dev/null | grep -v "^$" | wc -l)
if [ "$updates" -gt 0 ]; then
    echo '{"text": "* '$updates'", "tooltip": "Atualizações disponíveis"}'
else
    echo '{"text": "0", "tooltip": "Sistema atualizado"}'
fi