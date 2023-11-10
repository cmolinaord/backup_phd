# Define la ruta al script
SCRIPT=/proyectos/scripts/backup_phd/backup_phd.sh

# Crea el objetivo de instalación
install:
	install -m 755 $(SCRIPT) /proyectos/bin/backup_phd

# Define la regla predeterminada
.PHONY: all install
all: install
