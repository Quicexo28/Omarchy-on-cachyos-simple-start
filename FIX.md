# Fix: regresión de rutas (commit 447034e, PR #47, 20-may-2026)

## Diagnóstico
El PR #47 añadió selección interactiva de versión vía fetch-omarchy.sh,
que clona Omarchy en $SCRIPT_DIR/../../omarchy (hermano del repo).
Pero install-omarchy-on-cachyos.sh no se actualizó:

- Línea 91: `cd ../omarchy` → apunta a omarchy-on-cachyos/omarchy,
  que ya no existe. El cd falla silenciosamente.
- Consecuencia: todos los sed/cp posteriores corren desde bin/ y
  fallan en cascada con "No such file or directory".
- Línea 105: `cp ../bin/nvidia.sh` asume la estructura vieja.

Reproducible en cualquier máquina desde el 20-may-2026.
No está relacionado con Hyprland ni Lua.

## Cambios aplicados
- Línea 91:  cd ../omarchy  →  cd "$OMARCHY_DIR"
- Línea 105: cp ../bin/nvidia.sh  →  cp "$SCRIPT_DIR/nvidia.sh"

Verificado por simulación de resolución de rutas.
Alternativa: git checkout 46aa3a3 (último commit antes del PR).
