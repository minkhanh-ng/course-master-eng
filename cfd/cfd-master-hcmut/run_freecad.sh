#!/usr/bin/env bash
set -euo pipefail

# Run the generated FreeCAD macro from WSL using Windows FreeCAD installation.
FREECAD_CMD_WIN='C:\Program Files\FreeCAD 1.1\bin\freecadcmd.exe'
MACRO_PATH_WSL="${1:-manifold.FCMacro}"

if [[ ! -f "$MACRO_PATH_WSL" ]]; then
    echo "Macro file not found: $MACRO_PATH_WSL" >&2
    exit 1
fi

MACRO_PATH_WSL_ABS="$(realpath "$MACRO_PATH_WSL")"
MACRO_PATH_WIN="$(wslpath -w "$MACRO_PATH_WSL_ABS")"

powershell.exe -NoProfile -Command "& '$FREECAD_CMD_WIN' '$MACRO_PATH_WIN'"