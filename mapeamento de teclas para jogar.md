# Configuração Completa com Mapeamento Integrado

Vou criar um sistema completo onde o mapeamento de teclas é integrado diretamente ao script principal do scrcpy. Aqui está a solução:

## 1. Script Principal Aprimorado com Mapeamento

```bash
#!/bin/bash
cat > ~/bin/scrcpy_gaming.sh << 'EOF'
#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
DEVICE_MODEL="POCO X6 Pro"
MAX_SIZE=1920
VIDEO_BITRATE=12M
MAX_FPS=120
AUDIO_CODEC=opus
VIDEO_CODEC=h264
ROTATION=0

# --- DETECÇÃO DE JOGO ---
echo "Selecione o perfil de mapeamento:"
echo "1) Teamfight Tactics (TFT)"
echo "2) MOBA (Wild Rift)"  
echo "3) FPS (CoD Mobile, Free Fire)"
echo "4) Modo Padrão (Sem mapeamento)"
read -p "Opção (1-4): " GAME_CHOICE

# Configurações específicas por jogo
case $GAME_CHOICE in
    1)
        GAME_NAME="TFT"
        ROTATION=1  # Landscape para TFT
        ;;
    2)
        GAME_NAME="MOBA"
        ROTATION=1  # Landscape para MOBA
        ;;
    3)
        GAME_NAME="FPS"
        ROTATION=1  # Landscape para FPS
        ;;
    *)
        GAME_NAME="Default"
        ;;
esac

# --- DETECÇÃO AUTOMÁTICA DE RESOLUÇÃO ---
MONITOR_RES=$(xrandr | awk '/\*/{print $1; exit}')
MON_WIDTH=$(echo $MONITOR_RES | cut -d'x' -f1)
MON_HEIGHT=$(echo $MONITOR_RES | cut -d'x' -f2)

DEVICE_RES=$(adb shell wm size | awk -F": " '{print $2}')
DEVICE_WIDTH=$(echo $DEVICE_RES | cut -d'x' -f1)
DEVICE_HEIGHT=$(echo $DEVICE_RES | cut -d'x' -f2)

# Calcular crop
MON_RATIO=$(echo "scale=2; $MON_WIDTH/$MON_HEIGHT" | bc)
DEV_RATIO=$(echo "scale=2; $DEVICE_WIDTH/$DEVICE_HEIGHT" | bc)

if [ $(echo "$MON_RATIO > $DEV_RATIO" | bc) -eq 1 ]; then
    NEW_HEIGHT=$DEVICE_HEIGHT
    NEW_WIDTH=$(echo "$NEW_HEIGHT * $MON_RATIO" | bc)
    X_OFFSET=$(( ($DEVICE_WIDTH - ${NEW_WIDTH%.*}) / 2 ))
    Y_OFFSET=0
else
    NEW_WIDTH=$DEVICE_WIDTH
    NEW_HEIGHT=$(echo "$NEW_WIDTH / $MON_RATIO" | bc)
    X_OFFSET=0
    Y_OFFSET=$(( ($DEVICE_HEIGHT - ${NEW_HEIGHT%.*}) / 2 ))
fi

CROP="${NEW_WIDTH%.*}x${NEW_HEIGHT%.*}+${X_OFFSET}+${Y_OFFSET}"

# --- FUNÇÃO DE MAPEAMENTO ---
setup_key_mapping() {
    case $GAME_CHOICE in
        1)  # TFT
            echo "Configurando mapeamento para TFT..."
            # Mapeamento de teclas para TFT (1080x2400)
            declare -gA KEY_MAPPINGS=(
                # Loja
                ["F1"]="input tap 250 2300"      # Comprar XP
                ["F2"]="input tap 850 2300"      # Refresh
                ["F3"]="input tap 1000 2300"     # Bloquear/Desbloquear loja
                
                # Tabuleiro
                ["1"]="input tap 200 1200"       # Tabuleiro 1
                ["2"]="input tap 540 1200"       # Tabuleiro 2
                ["3"]="input tap 880 1200"       # Tabuleiro 3
                
                # Unidades
                ["Q"]="input tap 150 500"        # Mover unidade
                ["W"]="input tap 150 600"        # Vender unidade
                ["E"]="input tap 150 700"        # Reposicionar
                
                # Itens
                ["R"]="input tap 900 500"        # Combinar itens
                ["T"]="input tap 900 600"        # Equipar item
                
                # Interface
                ["TAB"]="input tap 1000 100"     # Alternar entre jogadores
                ["SPACE"]="input tap 540 2200"   # Próxima rodada
            )
            ;;
            
        2)  # MOBA
            echo "Configurando mapeamento para MOBA..."
            # Mapeamento para Wild Rift (1080x2400)
            declare -gA KEY_MAPPINGS=(
                # Habilidades
                ["Q"]="input tap 200 2000"       # Habilidade Q
                ["W"]="input tap 400 2000"       # Habilidade W
                ["E"]="input tap 600 2000"       # Habilidade E
                ["R"]="input tap 800 2000"       # Habilidade Ultimate
                
                # Itens Ativos
                ["1"]="input tap 900 1800"       # Item 1
                ["2"]="input tap 1000 1800"      # Item 2
                ["3"]="input tap 1100 1800"      # Item 3
                
                # Ações
                ["SPACE"]="input tap 540 2200"   # Ataque ao turvo
                ["F"]="input tap 100 2200"       # Flash
                ["D"]="input tap 200 2200"       # Feitiço secundário
                
                # Movimento (via swipes)
                ["UP"]="input swipe 200 1800 200 1700 100"
                ["DOWN"]="input swipe 200 1800 200 1900 100"
                ["LEFT"]="input swipe 200 1800 100 1800 100"
                ["RIGHT"]="input swipe 200 1800 300 1800 100"
            )
            ;;
            
        3)  # FPS
            echo "Configurando mapeamento para FPS..."
            # Mapeamento para jogos FPS (1080x2400)
            declare -gA KEY_MAPPINGS=(
                # Movimento
                ["W"]="input swipe 200 1800 200 1700 100"     # Frente
                ["S"]="input swipe 200 1800 200 1900 100"     # Trás
                ["A"]="input swipe 200 1800 100 1800 100"     # Esquerda
                ["D"]="input swipe 200 1800 300 1800 100"     # Direita
                
                # Ações
                ["CTRL"]="input tap 1000 2200"               # Agachar
                ["SPACE"]="input tap 900 2200"               # Pular
                ["SHIFT"]="input tap 1100 2200"              # Correr
                
                # Armas e Disparo
                ["MOUSE1"]="input tap 900 1800"              # Disparar
                ["MOUSE2"]="input tap 800 1800"              # Mira
                ["R"]="input tap 1000 1800"                  # Recarregar
                
                # Utilidades
                ["Q"]="input tap 1200 1800"                  # Granada
                ["E"]="input tap 1200 2000"                  # Habilidade
                ["F"]="input tap 1100 2000"                  # Interagir
            )
            ;;
            
        *)  # Modo padrão
            declare -gA KEY_MAPPINGS=()
            ;;
    esac
}

# --- CONFIGURAR MAPEAMENTO ---
setup_key_mapping

# --- EXECUÇÃO DO SCRCPY ---
echo "Iniciando scrcpy para $DEVICE_MODEL - Modo $GAME_NAME"
echo "Monitor: ${MON_WIDTH}x${MON_HEIGHT} (Ratio: ${MON_RATIO})"
echo "Dispositivo: ${DEVICE_WIDTH}x${DEVICE_HEIGHT} (Ratio: ${DEV_RATIO})"
echo "Usando crop: ${CROP}"

# Função para executar comandos ADB
execute_adb() {
    adb shell "$1"
}

# Iniciar scrcpy em background
scrcpy \
    --max-size=$MAX_SIZE \
    --video-bit-rate=$VIDEO_BITRATE \
    --max-fps=$MAX_FPS \
    --audio-codec=$AUDIO_CODEC \
    --video-codec=$VIDEO_CODEC \
    --orientation=$ROTATION \
    --turn-screen-off \
    --disable-screensaver \
    --shortcut-mod=lctrl \
    --window-title="GameStream - $DEVICE_MODEL - $GAME_NAME" \
    --render-driver=opengl \
    --crop="$CROP" \
    --prefer-text \
    --power-off-on-close &

SCRCPY_PID=$!

# --- LOOP DE CAPTURA DE TECLADO ---
if [ ${#KEY_MAPPINGS[@]} -gt 0 ]; then
    echo "Mapeamento de teclas ativo. Pressione as teclas configuradas."
    echo "Pressione 'ESC' para sair."
    
    # Usar xinput para capturar teclas
    while true; do
        # Capturar tecla pressionada (simplificado)
        read -rsn1 -t 0.1 key
        
        if [ ! -z "$key" ]; then
            case "$key" in
                $'\x1b')  # ESC
                    echo "Saindo..."
                    kill $SCRCPY_PID
                    exit 0
                    ;;
                *)
                    # Converter para uppercase para matching
                    upper_key=$(echo "$key" | tr '[:lower:]' '[:upper:]')
                    
                    # Executar comando mapeado se existir
                    if [ -n "${KEY_MAPPINGS[$upper_key]}" ]; then
                        execute_adb "${KEY_MAPPINGS[$upper_key]}" &
                    fi
                    ;;
            esac
        fi
        
        # Verificar se scrcpy ainda está rodando
        if ! kill -0 $SCRCPY_PID 2>/dev/null; then
            echo "Scrcpy terminou. Saindo."
            exit 0
        fi
    done
else
    # Modo sem mapeamento, apenas esperar scrcpy terminar
    wait $SCRCPY_PID
fi
EOF

chmod +x ~/bin/scrcpy_gaming.sh
```

## 2. Script de Instalação e Configuração

```bash
#!/bin/bash
cat > ~/bin/setup_gaming.sh << 'EOF'
#!/bin/bash
echo "=== CONFIGURAÇÃO DO SISTEMA DE GAMING ==="

# Instalar dependências
echo "Instalando dependências..."
sudo apt update
sudo apt install -y \
    android-tools-adb \
    android-tools-fastboot \
    ffmpeg \
    libsdl2-2.0-0 \
    libusb-1.0-0 \
    xinput

# Instalar scrcpy se necessário
if ! command -v scrcpy &> /dev/null; then
    echo "Instalando scrcpy..."
    sudo snap install scrcpy || \
    if ! command -v snap &> /dev/null; then
        echo "Snap não disponível, instalando via apt..."
        sudo apt install -y scrcpy
    fi
fi

# Configurar regras ADB para Xiaomi
echo "Configurando regras ADB..."
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2717", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules

# Criar diretório se não existir
mkdir -p ~/bin

# Dar permissões
chmod +x ~/bin/scrcpy_gaming.sh
chmod +x ~/bin/setup_gaming.sh

echo "Configuração concluída!"
echo ""
echo "Para usar:"
echo "1. Conecte seu POCO X6 Pro via USB"
echo "2. Ative a depuração USB no dispositivo"
echo "3. Execute: ~/bin/scrcpy_gaming.sh"
echo "4. Escolha o perfil de jogo desejado"
EOF

chmod +x ~/bin/setup_gaming.sh
```

## 3. Script de Calibração para Ajustar Coordenadas

```bash
#!/bin/bash
cat > ~/bin/calibrate_screen.sh << 'EOF'
#!/bin/bash
echo "=== CALIBRAÇÃO DE COORDENADAS ==="
echo "Este script ajuda a encontrar as coordenadas corretas para seu dispositivo"

# Verificar se o dispositivo está conectado
if ! adb devices | grep -q "device$"; then
    echo "Conecte o dispositivo via USB e ative a depuração USB"
    exit 1
fi

echo "Toque na tela do dispositivo onde deseja mapear uma tecla"
echo "As coordenadas serão mostradas aqui"
echo "Pressione Ctrl+C para parar"

adb shell getevent -l | grep --line-buffered -e "ABS_MT_POSITION_X" -e "ABS_MT_POSITION_Y" | while read line; do
    if [[ $line == *"ABS_MT_POSITION_X"* ]]; then
        x_hex=$(echo $line | awk '{print $NF}')
        x_dec=$((16#$x_hex))
    elif [[ $line == *"ABS_MT_POSITION_Y"* ]]; then
        y_hex=$(echo $line | awk '{print $NF}')
        y_dec=$((16#$y_hex))
        echo "Coordenadas: X=$x_dec, Y=$y_dec"
    fi
done
EOF

chmod +x ~/bin/calibrate_screen.sh
```

## 4. Como Usar o Sistema

1. **Primeira configuração**:
   ```bash
   ~/bin/setup_gaming.sh
   ```

2. **Calibrar coordenadas (opcional)**:
   ```bash
   ~/bin/calibrate_screen.sh
   # Toque na tela para ver as coordenadas
   ```

3. **Executar o sistema principal**:
   ```bash
   ~/bin/scrcpy_gaming.sh
   ```

4. **Seguir as instruções na tela**:
   - Escolher o tipo de jogo
   - Usar as teclas mapeadas durante o jogo
   - Pressionar ESC para sair

## 5. Personalização Avançada

Se precisar ajustar as coordenadas para seu dispositivo específico:

1. Execute o script de calibração
2. Anote as coordenadas dos botões que você precisa
3. Edite o arquivo `~/bin/scrcpy_gaming.sh`
4. Modifique os valores nas arrays `KEY_MAPPINGS` para cada jogo

Este sistema integra completamente o mapeamento de teclas com o scrcpy, permitindo que você use o teclado do computador para controlar jogos mobile diretamente, com perfis específicos para cada tipo de jogo.
