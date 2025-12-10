#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
SCRCPY_ROT="0" # Rotação da tela (0 para paisagem)

# Detectar dispositivos conectados e limpar a saída para pegar apenas os IDs
# O grep remove linhas vazias e a linha "List of devices attached"
mapfile -t DEVICES < <(adb devices | grep -w "device" | awk '{print $1}')
NUM_DEVICES=${#DEVICES[@]}

echo "--- GESTOR SCRCPY ---"
echo "Dispositivos detectados: $NUM_DEVICES"

# Menu de seleção
echo "1 - Modo Normal (Um dispositivo - Crop Automático)"
echo "2 - Modo Filme (Um dispositivo - Crop Fixo)"
echo "3 - Modo Duplo (Dois dispositivos simultâneos)"
read -t 30 -p "Digite 1, 2 ou 3 (padrão: 1): " MODO

# Define o dispositivo principal (o primeiro da lista) para evitar erros nos modos 1 e 2
PRIMARY_SERIAL=${DEVICES[0]}

# --- MODO 3: MULTIPLOS DISPOSITIVOS ---
if [ "$MODO" = "3" ]; then
    echo "Iniciando Modo Duplo..."
    
    if [ "$NUM_DEVICES" -lt 2 ]; then
        echo "ERRO CRÍTICO: Menos de 2 dispositivos encontrados."
        echo "Conecte ambos via USB e tente novamente."
        read -p "Pressione Enter para sair..."
        exit 1
    fi

    for SERIAL in "${DEVICES[@]}"; do
        echo "Lançando janela para: $SERIAL"
        
        # Iniciando em background (&)
        scrcpy -s "$SERIAL" \
          --window-title="Mobile $SERIAL" \
          --shortcut-mod=lctrl \
          --max-fps=60 \
          --video-bit-rate=8M \
          --max-size=1024 \
          --video-codec=h264 \
          --no-audio &  
    done
    
    echo "---------------------------------------------------"
    echo "As janelas foram abertas. O terminal ficará ativo."
    echo "Para encerrar, feche as janelas dos celulares ou use Ctrl+C aqui."
    echo "---------------------------------------------------"
    
    # O comando wait impede que o script feche até que os processos em background terminem
    wait
    exit 0
fi

# --- MODO 1 e 2: DISPOSITIVO ÚNICO ---

# Fallback para modo 1 se vazio
if [ -z "$MODO" ] || [ "$MODO" = "1" ] || [ "$MODO" = "" ]; then
    
    if [ -z "$PRIMARY_SERIAL" ]; then
        echo "Nenhum dispositivo encontrado!"
        read -p "Pressione Enter para sair..."
        exit 1
    fi

    echo "Modo Normal selecionado (Device: $PRIMARY_SERIAL)"
    
    # Resolução Monitor
    MON_RES=$(xrandr | awk '/\*/{print $1; exit}')
    MON_W=$(echo $MON_RES | cut -d'x' -f1)
    MON_H=$(echo $MON_RES | cut -d'x' -f2)
    MON_RATIO=$(echo "$MON_W/$MON_H" | bc -l)

    # Resolução Dispositivo
    DEV_INFO=$(adb -s "$PRIMARY_SERIAL" shell wm size)
    DEV_WH=$(echo "$DEV_INFO" | awk -F': ' '{print $2}')
    DEV_W=$(echo $DEV_WH | cut -d'x' -f1)
    DEV_H=$(echo $DEV_WH | cut -d'x' -f2)
    DEV_RATIO=$(echo "$DEV_W/$DEV_H" | bc -l)

    # Cálculo do Crop
    if [ $(echo "$MON_RATIO > $DEV_RATIO" | bc -l) -eq 1 ]; then
        CROP_H=$DEV_H
        CROP_W=$(echo "$DEV_H * $MON_RATIO" | bc)
        X_OFF=$(( (DEV_W - CROP_W) / 2 ))
        Y_OFF=0
    else
        CROP_W=$DEV_W
        CROP_H=$(echo "$DEV_W / $MON_RATIO" | bc)
        X_OFF=0
        Y_OFF=$(( (DEV_H - CROP_H) / 2 ))
    fi

    # Ajuste de Inteiros
    CROP_W=${CROP_W%.*}
    CROP_H=${CROP_H%.*}
    CROP_W=$(( CROP_W > DEV_W ? DEV_W : CROP_W ))
    CROP_H=$(( CROP_H > DEV_H ? DEV_H : CROP_H ))
    X_OFF=$(( X_OFF < 0 ? 0 : X_OFF ))
    Y_OFF=$(( Y_OFF < 0 ? 0 : Y_OFF ))

    CROP_PARAM="--crop=${CROP_W}:${CROP_H}:${X_OFF}:${Y_OFF}"

else
    echo "Modo Filme selecionado"
    CROP_PARAM="--crop=1220:2160:0:228"
fi

# Execução Modo 1/2
echo "Iniciando scrcpy..."
scrcpy -s "$PRIMARY_SERIAL" \
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
  --video-codec=h264 \
  --no-audio

# Adicionado pause no final caso dê erro no modo normal e feche rápido demais
echo "Scrcpy finalizado."
read -t 5 -p "Fechando em 5 segundos..."
