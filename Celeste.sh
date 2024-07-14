#!/bin/bash
# PORTMASTER: celeste.zip, Celeste.sh

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports/"
GAMEDIR="${PORTDIR}/celeste"
gameassembly="Celeste.exe"
cd "$GAMEDIR/gamedata"

# Grab text output...
$ESUDO chmod 666 $CUR_TTY
printf "\033c" > $CUR_TTY
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
$ESUDO rm -rf ~/.local/share/Celeste
mkdir -p ~/.local/share
ln -sfv "$GAMEDIR/savedata" ~/.local/share/Celeste

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll
cp $GAMEDIR/libs/Celeste.exe.config $GAMEDIR/gamedata

# Setup path and other environment variables
export FNA_PATCH="$GAMEDIR/dlls/CelestePatches.dll"
export MONO_PATH="$GAMEDIR/dlls"
export LD_LIBRARY_PATH="$GAMEDIR/libs":"${monodir}/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

# Compress all textures with ASTC codec, bringing massive vram gains
if [[ ! -f "$GAMEDIR/.astc_done" ]]; then
	echo "Optimizing textures..." >> /dev/tty0
	"$GAMEDIR/celeste-repacker" "$GAMEDIR/gamedata/Content/Graphics/" --install >> /dev/tty0
	if [ $? -eq 0 ]; then
		touch "$GAMEDIR/.astc_done"
	fi
fi

# first_time_setup
$GPTOKEYB "mono" &
$TASKSET mono Celeste.exe
$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1
