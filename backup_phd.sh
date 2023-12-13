#!/bin/bash

echo "Haciendo copia de seguridad del PhD. Buscando dispositivos para backup..."

# Comprueba si la raspi esta disponible
if ping -c 1 raspi > /dev/null; then
  raspi_UP=true
else
  raspi_UP=false
fi

# Comprueba si el HDD esta montado
if mount | grep -q "/media/$USER/WD_CMOLINA"; then
  hdd_UP=true
else
  hdd_UP=false
fi

# Pregunta cual usar
if [ "$raspi_UP" = true ] && [ "$hdd_UP" = true ]; then
  echo "Elija en que dispositivo: Raspi (1), WD_CMOLINA (2), Abortar (x)"
  read dev
else
  # Si solo uno de ellos esta disponible
  if [ "$raspi_UP" = false ]; then
    echo "Elija en que dispositivo: HDD (2), Abortar (x)"
    read dev
  elif [ "$hdd_UP" = false ]; then
    echo "Elija en que dispositivo: Raspi (1), Abortar (x)"
    read dev
  else
    echo "No se encuentran ni el disco duro ni la raspberry en LAN. Abortando"
  fi
fi

# Comprueba respuesta
if [ "$dev" != "1" ] && [ "$dev" != "2" ] && [ "$dev" != "x" ]; then
  echo "La respuesta debe ser '1', '2' o 'x'."
  exit 1
fi

LIST="/proyectos/scripts/backup_phd/backup_list.txt"
OPTS="-azhrRe ssh --progress --update --stats --files-from=$LIST"
EXCLUDES="{'*.git','*.nc'}" # Not working

# Lanza rsync
if [ "$dev" == "1" ]; then
  echo "Enviando a Raspi"
  rsync -n $OPTS --exclude={'*.git','*.nc'} /proyectos/phd/ cmolina@raspi:/home/data/backups/phd
  echo "Recibiendo desde Raspi"
  rsync -n $OPTS --exclude={'*.git','*.nc'} cmolina@raspi:/home/data/backups/phd /proyectos/phd/

elif [ "$dev" == "2" ]; then
  echo "Enviando a HDD"
  rsync $OPTS --exclude={'*.git','*.nc'} /proyectos/phd/ /media/$USER/WD_CMOLINA/phd
  echo "Recibiendo desde HDD"
  rsync $OPTS --exclude={'*.git','*.nc'} /media/$USER/WD_CMOLINA/phd /proyectos/phd/
else
  echo "No se hace nada"
  exit 1
fi



