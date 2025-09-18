cat > ~/bin/scrcpy_final.sh << 'EOF'
#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
SCRCPY_ROT="0" # Rotação inicial (0 para retrato)
TOGGLE_ROTATION_KEY="Ctrl+Shift+r" # Atalho para alternar rotação

# --- EXECUÇÃO AUTOMÁTICA ---
echo "Iniciando scrcpy com áudio (método final)..."

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

# Função para alternar rotação
toggle_rotation() {
    if [ "$SCRCPY_ROT" = "0" ]; then
        SCRCPY_ROT="1"
        echo "Mudando para paisagem (90°)"
    else
        SCRCPY_ROT="0"
        echo "Mudando para retrato (0°)"
    fi
    # Aqui você precisaria reiniciar o scrcpy com a nova rotação
    # Isso é complexo de implementar em um script em execução
}

exec scrcpy \
  
  --audio-codec=opus \
  --window-title="POCO X6 Pro (Áudio Interno)" \
  $CROP_PARAM \
  --orientation="$SCRCPY_ROT" \
  --fullscreen \
  --always-on-top \
  --shortcut-mod=lctrl \
  --max-fps=120 \
  --video-bit-rate=12M \
  --render-driver=opengl \
  --max-size=1920 \
  --turn-screen-off \
  --disable-screensaver \
  --video-codec=h264 \
  --keyboard=uhid
EOF

chmod +x ~/bin/scrcpy_final.sh
