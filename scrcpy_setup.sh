cat > ~/bin/scrcpy_final.sh << 'EOF'
#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
SCRCPY_ROT="0" # Rotação da tela (90 para retrato, 0 para paisagem)

# --- EXECUÇÃO AUTOMÁTICA ---
echo "Iniciando scrcpy com áudio embutido (método final)..."

MON_RES=$(xrandr | awk '/\*/{print $1; exit}')
MON_W=$(echo $MON_RES | cut -d'x' -f1)
MON_H=$(echo $MON_RES | cut -d'x' -f2)

DEV_INFO=$(adb shell wm size)
DEV_WH=$(echo "$DEV_INFO" | awk -F': ' '{print $2}')
DEV_W=$(echo $DEV_WH | cut -d'x' -f1)
DEV_H=$(echo $DEV_WH | cut -d'x' -f2)

if [ "$DEV_W" -gt "$DEV_H" ]; then
  tmp=$DEV_W; DEV_W=$DEV_H; DEV_H=$tmp
fi

CROP_H=$(awk -v dev_w="$DEV_W" -v mon_w="$MON_W" -v mon_h="$MON_H" 'BEGIN{printf("%d", dev_w * mon_w / mon_h)}')
if [ "$CROP_H" -gt "$DEV_H" ]; then
  CROP_H=$DEV_H
fi
Y_OFF=$(( (DEV_H - CROP_H) / 2 ))
CROP="${DEV_W}:${CROP_H}:0:${Y_OFF}"
CROP_PARAM="--crop=$CROP"

echo "Usando crop: $CROP e Rotação: $SCRCPY_ROT"

exec scrcpy \
  --audio-codec=opus \
  --window-title="POCO X6 Pro (Áudio Interno)" \
  $CROP_PARAM \
  --orientation="$SCRCPY_ROT" \
  --fullscreen \
  --always-on-top \
  --shortcut-mod=lctrl
EOF

chmod +x ~/bin/scrcpy_final.sh