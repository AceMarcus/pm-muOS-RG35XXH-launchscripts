#!/bin/bash
# PORTMASTER: sm64.zip, sm64.sh

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
 elif [ -d "/roms2/ports" ]; then
  controlfolder="/roms2/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

get_controls

GAMEDIR="/$directory/ports/sm64"

cd $GAMEDIR

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "sm64.us.f3dex2e" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./sm64.us.f3dex2e 2>&1 | tee ./log.txt
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
unset LD_LIBRARY_PATH
printf "\033c" >> /dev/tty1