#!/bin/bash

# ================================
# SCRCPY MANAGER — COMPATÍVEL 3.x
# ================================

SCRCPY_BIN="/usr/local/bin/scrcpy"

# Não fechar imediatamente em erro
trap 'echo; echo "Erro detectado. Pressione ENTER para sair..."; read' ERR

clear
echo "===================================="
echo "        SCRCPY MANAGER 3.x           "
echo "===================================="
echo

# Verificação básica
if ! command -v scrcpy >/dev/null 2>&1; then
  echo "ERRO: scrcpy não encontrado no sistema."
  read -p "Pressione ENTER para sair..."
  exit 1
fi

# Detectar dispositivos
mapfile -t DEVICES < <(adb devices | awk 'NR>1 && $2=="device"{print $1}')
COUNT="${#DEVICES[@]}"

if [ "$COUNT" -eq 0 ]; then
  echo "Nenhum dispositivo Android conectado."
  read -p "Pressione ENTER para sair..."
  exit 0
fi

echo "Dispositivos detectados: $COUNT"
echo

# ======================================================
# MODO 1 — APENAS 1 DISPOSITIVO
# ======================================================
if [ "$COUNT" -eq 1 ]; then
  SERIAL="${DEVICES[0]}"
  echo "Abrindo dispositivo: $SERIAL"
  echo

  exec "$SCRCPY_BIN" -s "$SERIAL" \
    --shortcut-mod=lctrl \
    --max-fps=60 \
    --video-bit-rate=12M \
    --max-size=1920 \
    --turn-screen-off \
    --disable-screensaver
fi

# ======================================================
# MODO MULTI DISPOSITIVO
# ======================================================
echo "Selecione o modo:"
echo "1) Abrir TODOS os dispositivos"
echo "2) Escolher apenas UM"
echo
read -p "Opção [1/2]: " MODE

case "$MODE" in
  1)
    echo
    echo "Abrindo todos os dispositivos..."
    echo
    for SERIAL in "${DEVICES[@]}"; do
      "$SCRCPY_BIN" -s "$SERIAL" \
        --shortcut-mod=lctrl \
        --max-fps=60 \
        --video-bit-rate=10M \
        --max-size=1280 \
        --turn-screen-off \
        --disable-screensaver &
    done
    wait
    ;;
  2)
    echo
    for i in "${!DEVICES[@]}"; do
      echo "$i) ${DEVICES[$i]}"
    done
    echo
    read -p "Escolha o número: " IDX

    SERIAL="${DEVICES[$IDX]}"
    if [ -z "$SERIAL" ]; then
      echo "Seleção inválida."
      read -p "Pressione ENTER para sair..."
      exit 1
    fi

    exec "$SCRCPY_BIN" -s "$SERIAL" \
      --shortcut-mod=lctrl \
      --max-fps=60 \
      --video-bit-rate=12M \
      --max-size=1920 \
      --turn-screen-off \
      --disable-screensaver
    ;;
  *)
    echo "Opção inválida."
    read -p "Pressione ENTER para sair..."
    ;;
esac
