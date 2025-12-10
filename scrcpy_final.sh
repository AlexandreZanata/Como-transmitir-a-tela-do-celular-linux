#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
SCRCPY_ROT="0" # Rotação da tela (0 para paisagem)

# Menu de seleção
echo "Selecione o modo:"
echo "1 - Modo Normal (Enter)"
echo "2 - Modo Filme"
read -t 30 -p "Digite 1 ou 2 (padrão: 1): " MODO

# Se não houver entrada em 30 segundos ou Enter pressionado, usa modo normal
if [ -z "$MODO" ] || [ "$MODO" = "1" ] || [ "$MODO" = "" ]; then
    echo "Modo Normal selecionado"
    
    # Obter resolução do monitor
    MON_RES=$(xrandr | awk '/\*/{print $1; exit}')
    MON_W=$(echo $MON_RES | cut -d'x' -f1)
    MON_H=$(echo $MON_RES | cut -d'x' -f2)
    MON_RATIO=$(echo "$MON_W/$MON_H" | bc -l)

    # Obter resolução do dispositivo
    DEV_INFO=$(adb shell wm size)
    DEV_WH=$(echo "$DEV_INFO" | awk -F': ' '{print $2}')
    DEV_W=$(echo $DEV_WH | cut -d'x' -f1)
    DEV_H=$(echo $DEV_WH | cut -d'x' -f2)
    DEV_RATIO=$(echo "$DEV_W/$DEV_H" | bc -l)

    # Calcular crop baseado na proporção de aspecto
    if [ $(echo "$MON_RATIO > $DEV_RATIO" | bc -l) -eq 1 ]; then
        # Monitor é mais largo - cortar topo e base
        CROP_H=$DEV_H
        CROP_W=$(echo "$DEV_H * $MON_RATIO" | bc)
        X_OFF=$(( (DEV_W - CROP_W) / 2 ))
        Y_OFF=0
    else
        # Monitor é mais alto - cortar laterais
        CROP_W=$DEV_W
        CROP_H=$(echo "$DEV_W / $MON_RATIO" | bc)
        X_OFF=0
        Y_OFF=$(( (DEV_H - CROP_H) / 2 ))
    fi

    # Garantir valores inteiros e dentro dos limites do dispositivo
    CROP_W=${CROP_W%.*}
    CROP_H=${CROP_H%.*}
    CROP_W=$(( CROP_W > DEV_W ? DEV_W : CROP_W ))
    CROP_H=$(( CROP_H > DEV_H ? DEV_H : CROP_H ))
    X_OFF=$(( X_OFF < 0 ? 0 : X_OFF ))
    Y_OFF=$(( Y_OFF < 0 ? 0 : Y_OFF ))

    CROP_PARAM="--crop=${CROP_W}:${CROP_H}:${X_OFF}:${Y_OFF}"
    echo "Monitor: ${MON_W}x${MON_H} (ratio: ${MON_RATIO})"
    echo "Dispositivo: ${DEV_W}x${DEV_H} (ratio: ${DEV_RATIO})"
    echo "Usando crop: $CROP_PARAM"

else
    echo "Modo Filme selecionado"
    # Formato que melhor se adaptou para modo filme
    CROP_PARAM="--crop=1220:2160:0:228"
fi

echo "Usando crop: $CROP_PARAM e Rotação: $SCRCPY_ROT"

exec scrcpy \
  --audio-codec=opus \
  --window-title="POCO X6 Pro (Áudio Interno)" \
  $CROP_PARAM \
  --orientation="$SCRCPY_ROT" \
  --fullscreen \
  --always-on-top \
  --shortcut-mod=lctrl \
  --max-fps=60 \
  --video-bit-rate=15M \
  --render-driver=opengl \
  --max-size=1920 \
  --turn-screen-off \
  --disable-screensaver \
  --video-codec=h264
  --no-audio \
