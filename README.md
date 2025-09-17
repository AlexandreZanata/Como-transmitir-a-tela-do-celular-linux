-----

-----

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
