-----

-----

TIPOS DE COMANDOS

| Atalho       | Função                         |
| ------------ | ------------------------------ |
| **Ctrl + F** | Tela cheia                     |
| **Ctrl + O** | Liga/desliga tela do celular   |
| **Ctrl + R** | Rotacionar                     |
| **Ctrl + T** | Mostrar toques                 |
| **Ctrl + H** | Home                           |
| **Ctrl + B** | Voltar                         |
| **Ctrl + M** | Menu                           |
| **F11**      | Tela cheia (atalho do sistema) |







# **English Version**

# Advanced `scrcpy` Fullscreen Script

This script provides a simple way to mirror your Android device to a Linux PC in a clean, fullscreen window with audio forwarding. It automatically calculates the correct aspect ratio to crop the video stream, removing the black bars (letterboxing) when mirroring in portrait mode.

## Features

  * **Fullscreen by Default:** Launches directly into an immersive, fullscreen mode.
  * **Audio Forwarding:** Forwards your device's audio to the PC (requires Android 11+).
  * **Automatic Cropping:** Intelligently removes black bars in portrait mode by cropping the video to match your monitor's aspect ratio.
  * **Borderless Window:** The window is clean, without any title bar or borders.
  * **Always on Top:** Keeps the device window above all others.
  * **Easy Configuration:** Easily change the screen rotation by editing a single variable in the script.

## 1\. Prerequisites

### Hardware

  * A computer running a Debian-based Linux distribution (like Ubuntu, Mint, etc.).
  * An Android device running **Android 11 or newer** for audio forwarding.
  * A USB cable.

### Software Dependencies

  * **`scrcpy`** (version 2.0 or newer)
  * **`adb`** (Android Debug Bridge)
  * `xrandr` and `awk` (usually pre-installed on most Linux systems)

You can install the main dependencies on Ubuntu/Debian with a single command:

```bash
sudo apt update && sudo apt install scrcpy adb -y
```

## 2\. Installation

### Step 1: Enable USB Debugging on Your Android Device

1.  **Enable Developer Options:**
      * Go to `Settings -> About phone`.
      * Tap on `Build number` 7 times until you see a message saying "You are now a developer\!".
2.  **Enable USB Debugging:**
      * Go to `Settings -> System -> Developer options`.
      * Find and enable the **`USB debugging`** toggle.

### Step 2: Create the Script on Your Linux PC

1.  Open a terminal on your PC.
2.  Run the following command to create and save the script. This version is corrected and improved to work reliably.

<!-- end list -->

```bash
# Creates the script in your local binaries folder
cat > ~/bin/scrcpy-advanced << 'EOF'
#!/bin/bash
set -e

# --- CONFIGURATION ---
# 0   -> Landscape mode
# 90  -> Portrait mode
# 270 -> Portrait mode (flipped)
SCRCPY_ROT="0"

# --- AUTOMATIC EXECUTION ---
echo "Starting scrcpy with audio and rotation of ${SCRCPY_ROT} degrees..."

# This parameter will hold the crop values
CROP_PARAM=""

# Only calculate and apply crop if in portrait mode
if [ "$SCRCPY_ROT" != "0" ]; then
  MON_RES=$(xrandr | awk '/\*/{print $1; exit}')
  MON_W=$(echo $MON_RES | cut -d'x' -f1)
  MON_H=$(echo $MON_RES | cut -d'x' -f2)
  DEV_INFO=$(adb shell wm size)
  DEV_WH=$(echo "$DEV_INFO" | awk -F': ' '{print $2}')
  DEV_W=$(echo $DEV_WH | cut -d'x' -f1)
  DEV_H=$(echo $DEV_WH | cut -d'x' -f2)

  # Ensure dimensions are in portrait for calculation
  if [ "$DEV_W" -gt "$DEV_H" ]; then
    tmp=$DEV_W; DEV_W=$DEV_H; DEV_H=$tmp
  fi

  CROP_H=$(awk -v dev_w="$DEV_W" -v mon_w="$MON_W" -v mon_h="$MON_H" 'BEGIN{printf("%d", dev_w * mon_w / mon_h)}')
  if [ "$CROP_H" -gt "$DEV_H" ]; then
    CROP_H=$DEV_H
  fi
  Y_OFF=$(( (DEV_H - CROP_H) / 2 ))
  
  # Set the crop parameter to be used by the final command
  CROP_PARAM="--crop=${DEV_W}:${CROP_H}:0:${Y_OFF}"
  
  echo "Portrait mode: Cropping to remove black bars."
fi

exec scrcpy \
  --audio-codec=opus \
  --window-title="Android Mirror" \
  $CROP_PARAM \
  --orientation="$SCRCPY_ROT" \
  --fullscreen \
  --window-borderless \
  --always-on-top \
  --shortcut-mod=lctrl
EOF
```

### Step 3: Make the Script Executable

In the terminal, run:

```bash
chmod +x ~/bin/scrcpy-advanced
```

## 3\. Usage

1.  Connect your Android device to your PC using the USB cable.
2.  A pop-up **"Allow USB debugging?"** will appear on your phone screen. Check the "Always allow from this computer" box and tap **"Allow"**.
3.  Open a terminal on your PC and run the script:
    ```bash
    ~/bin/scrcpy-advanced
    ```
4.  The first time you run it with audio, a new pop-up will appear on your phone asking for permission to record audio. You **must accept** this for the sound to work.

The device screen should now appear on your monitor in fullscreen.

## 4\. Customization

The main setting you might want to change is the screen rotation.

  * Edit the script: `gedit ~/bin/scrcpy-advanced`
  * Find the line `SCRCPY_ROT="0"`.
  * Change the value according to your needs:
      * `SCRCPY_ROT="0"` for landscape mode (holding the phone sideways).
      * `SCRCPY_ROT="90"` for portrait mode (holding the phone upright).

-----

-----

# **Versão em Português**

# Script Avançado de `scrcpy` em Tela Cheia

Este script fornece uma maneira simples de espelhar seu dispositivo Android em um PC Linux em uma janela limpa e em tela cheia, com encaminhamento de áudio. Ele calcula automaticamente a proporção de tela correta para cortar o fluxo de vídeo, removendo as barras pretas (letterboxing) ao espelhar no modo retrato.

## Funcionalidades

  * **Tela Cheia por Padrão:** Inicia diretamente em um modo imersivo de tela cheia.
  * **Encaminhamento de Áudio:** Encaminha o áudio do seu dispositivo para o PC (requer Android 11+).
  * **Corte Automático:** Remove inteligentemente as barras pretas no modo retrato, cortando o vídeo para corresponder à proporção de tela do seu monitor.
  * **Janela Sem Bordas:** A janela é limpa, sem barra de título ou bordas.
  * **Sempre no Topo:** Mantém a janela do dispositivo acima de todas as outras.
  * **Configuração Fácil:** Altere facilmente a rotação da tela editando uma única variável no script.

## 1\. Pré-requisitos

### Hardware

  * Um computador com uma distribuição Linux baseada em Debian (como Ubuntu, Mint, etc.).
  * Um dispositivo Android com **Android 11 ou superior** para o encaminhamento de áudio.
  * Um cabo USB.

### Dependências de Software

  * **`scrcpy`** (versão 2.0 ou superior)
  * **`adb`** (Android Debug Bridge)
  * `xrandr` e `awk` (geralmente pré-instalados na maioria dos sistemas Linux)

Você pode instalar as principais dependências no Ubuntu/Debian com um único comando:

```bash
sudo apt update && sudo apt install scrcpy adb -y
```

## 2\. Instalação

### Passo 1: Habilite a Depuração USB no seu Dispositivo Android

1.  **Habilite as Opções do Desenvolvedor:**
      * Vá para `Configurações -> Sobre o telefone`.
      * Toque em `Número da versão` 7 vezes até ver uma mensagem dizendo "Você agora é um desenvolvedor\!".
2.  **Habilite a Depuração USB:**
      * Vá para `Configurações -> Sistema -> Opções do desenvolvedor`.
      * Encontre e habilite a opção **`Depuração USB`**.

### Passo 2: Crie o Script no seu PC Linux

1.  Abra um terminal no seu PC.
2.  Execute o seguinte comando para criar e salvar o script. Esta versão está corrigida e aprimorada para funcionar de forma confiável.

<!-- end list -->

```bash
# Cria o script na sua pasta local de binários
cat > ~/bin/scrcpy-advanced << 'EOF'
#!/bin/bash
set -e

# --- CONFIGURAÇÃO ---
# 0   -> Modo paisagem (deitado)
# 90  -> Modo retrato (em pé)
# 270 -> Modo retrato (em pé, invertido)
SCRCPY_ROT="0"

# --- EXECUÇÃO AUTOMÁTICA ---
echo "Iniciando scrcpy com áudio e rotação de ${SCRCPY_ROT} graus..."

# Este parâmetro guardará os valores de corte
CROP_PARAM=""

# Apenas calcula e aplica o corte se estiver em modo retrato
if [ "$SCRCPY_ROT" != "0" ]; then
  MON_RES=$(xrandr | awk '/\*/{print $1; exit}')
  MON_W=$(echo $MON_RES | cut -d'x' -f1)
  MON_H=$(echo $MON_RES | cut -d'x' -f2)
  DEV_INFO=$(adb shell wm size)
  DEV_WH=$(echo "$DEV_INFO" | awk -F': ' '{print $2}')
  DEV_W=$(echo $DEV_WH | cut -d'x' -f1)
  DEV_H=$(echo $DEV_WH | cut -d'x' -f2)

  # Garante que as dimensões estejam em modo retrato para o cálculo
  if [ "$DEV_W" -gt "$DEV_H" ]; then
    tmp=$DEV_W; DEV_W=$DEV_H; DEV_H=$tmp
  fi

  CROP_H=$(awk -v dev_w="$DEV_W" -v mon_w="$MON_W" -v mon_h="$MON_H" 'BEGIN{printf("%d", dev_w * mon_w / mon_h)}')
  if [ "$CROP_H" -gt "$DEV_H" ]; then
    CROP_H=$DEV_H
  fi
  Y_OFF=$(( (DEV_H - CROP_H) / 2 ))
  
  # Define o parâmetro de corte para ser usado no comando final
  CROP_PARAM="--crop=${DEV_W}:${CROP_H}:0:${Y_OFF}"
  
  echo "Modo Retrato: Cortando para remover barras pretas."
fi

exec scrcpy \
  --audio-codec=opus \
  --window-title="Espelho do Android" \
  $CROP_PARAM \
  --orientation="$SCRCPY_ROT" \
  --fullscreen \
  --window-borderless \
  --always-on-top \
  --shortcut-mod=lctrl
EOF
```

### Passo 3: Torne o Script Executável

No terminal, execute:

```bash
chmod +x ~/bin/scrcpy-advanced
```

## 3\. Como Usar

1.  Conecte seu dispositivo Android ao seu PC usando o cabo USB.
2.  Uma janela **"Permitir depuração USB?"** aparecerá na tela do seu celular. Marque a caixa "Sempre permitir deste computador" e toque em **"Permitir"**.
3.  Abra um terminal no seu PC e execute o script:
    ```bash
    ~/bin/scrcpy-advanced
    ```
4.  Na primeira vez que você executar com áudio, uma nova janela aparecerá no seu celular pedindo permissão para gravar áudio. Você **precisa aceitar** para que o som funcione.

A tela do dispositivo deve agora aparecer no seu monitor em tela cheia.

## 4\. Customização

A principal configuração que você pode querer alterar é a rotação da tela.

  * Edite o script: `gedit ~/bin/scrcpy-advanced`
  * Encontre a linha `SCRCPY_ROT="0"`.
  * Altere o valor de acordo com suas necessidades:
      * `SCRCPY_ROT="0"` para o modo paisagem (celular deitado).
      * `SCRCPY_ROT="90"` para o modo retrato (celular em pé).



# Corrigindo o mapeamento de teclas para TFT Mobile

Vou ajudar você a ajustar o script para que o mapeamento de teclas funcione corretamente com o TFT Mobile. O problema provavelmente está nas coordenadas ou na forma como o mapeamento está sendo aplicado.

## Script corrigido com mapeamento de teclas

```bash
cat > ~/bin/scrcpy_final.sh << 'EOF'
#!/bin/bash
set -e

# --- CONFIGURAÇÕES ---
SCRCPY_ROT="0" # Rotação inicial (0 para retrato)
KEYMAP_FILE="$HOME/.config/scrcpy/scrcpy-keymap.yml"

# --- EXECUÇÃO AUTOMÁTICA ---
echo "Iniciando scrcpy com áudio (método final)..."

# Verificar se o arquivo de mapeamento existe
if [ -f "$KEYMAP_FILE" ]; then
    echo "Usando mapeamento de teclas personalizado: $KEYMAP_FILE"
    KEYMAP_OPTION="--key-map=$KEYMAP_FILE"
else
    echo "Arquivo de mapeamento não encontrado: $KEYMAP_FILE"
    echo "Continuando sem mapeamento personalizado."
    KEYMAP_OPTION=""
fi

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

exec scrcpy \
  --audio-codec=opus \
  --window-title="POCO X6 Pro (Áudio Interno)" \
  $CROP_PARAM \
  --orientation="$SCRCPY_ROT" \
  --fullscreen \
  --always-on-top \
  --shortcut-mod=lctrl \
  --max-fps=120 \
  --video-bit-rate=8M \
  --render-driver=opengl \
  --max-size=1920 \
  --turn-screen-off \
  --disable-screensaver \
  --video-codec=h264 \
  --keyboard=uhid \
  $KEYMAP_OPTION
EOF

chmod +x ~/bin/scrcpy_final.sh
```

## Como descobrir as coordenadas corretas para o TFT Mobile

Para que o mapeamento de teclas funcione, você precisa usar as coordenadas corretas para o TFT Mobile. Siga estes passos:

1. **Habilite as opções de desenvolvedor** no seu celular
2. **Ative a visualização de toques**:
   ```bash
   adb shell settings put system show_touches 1
   ```

3. **Use este script para descobrir coordenadas**:
   ```bash
   cat > ~/bin/find_coordinates.sh << 'EOF'
   #!/bin/bash
   echo "Toque na tela do dispositivo para descobrir as coordenadas..."
   echo "Pressione Ctrl+C para parar"
   adb shell getevent -l | grep --line-buffered -E "ABS_MT_POSITION_X|ABS_MT_POSITION_Y" | awk '
   /ABS_MT_POSITION_X/ {x=strtonum("0x" $NF); printf "X: %d, ", x}
   /ABS_MT_POSITION_Y/ {y=strtonum("0x" $NF); printf "Y: %d\n", y}
   '
   EOF
   chmod +x ~/bin/find_coordinates.sh
   ```

4. **Execute o script e toque nas áreas do TFT**:
   ```bash
   ~/bin/find_coordinates.sh
   ```

## Exemplo de arquivo de mapeamento para TFT Mobile

Com base nas coordenadas descobertas, atualize seu arquivo de mapeamento:

```bash
mkdir -p ~/.config/scrcpy
cat > ~/.config/scrcpy/scrcpy-keymap.yml << 'EOF'
# Mapeamento para TFT Mobile
# Ajuste as coordenadas conforme necessário para seu dispositivo

# Tecla F para refresh da loja (ajuste as coordenadas)
KEY_F:
  - command: tap 500 1800
    press: true
    release: true

# Tecla R para comprar XP (ajuste as coordenadas)
KEY_R:
  - command: tap 900 1800
    press: true
    release: true

# Tecla E para colocar unit no tabuleiro (ajuste as coordenadas)
KEY_E:
  - command: tap 300 1000
    press: true
    release: true

# Teclas 1-8 para selecionar unidades (ajuste as coordenadas)
KEY_1:
  - command: tap 200 400
    press: true
    release: true

KEY_2:
  - command: tap 400 400
    press: true
    release: true

KEY_3:
  - command: tap 600 400
    press: true
    release: true

KEY_4:
  - command: tap 800 400
    press: true
    release: true

KEY_5:
  - command: tap 1000 400
    press: true
    release: true

# Tecla Espaço para centro da tela (ajuste as coordenadas)
KEY_SPACE:
  - command: tap 540 960
    press: true
    release: true

# Tecla Q para vender unidade (ajuste as coordenadas)
KEY_Q:
  - command: tap 100 1800
    press: true
    release: true
EOF
```

## Dicas adicionais

1. **Verifique a versão do scrcpy**:
   ```bash
   scrcpy --version
   ```
   Certifique-se de que está usando a versão 1.21 ou superior para suporte completo a mapeamento de teclas.

2. **Teste o mapeamento**:
   ```bash
   scrcpy --key-map=~/.config/scrcpy/scrcpy-keymap.yml --no-audio
   ```

3. **Se ainda não funcionar**, tente usar o modo de depuração:
   ```bash
   scrcpy --key-map=~/.config/scrcpy/scrcpy-keymap.yml --log-level=debug
   ```

4. **Para dispositivos com resoluções diferentes**, você pode precisar ajustar as coordenadas proporcionalmente.

Com essas correções, seu mapeamento de teclas deve funcionar corretamente com o TFT Mobile. Lembre-se de ajustar as coordenadas com base no que você descobrir usando o script de descoberta de coordenadas.
