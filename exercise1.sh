#!/bin/bash

# Assign argument one and two to variables
FIRST_NAME="${1}"
LAST_NAME="${2}"

# Create a file named output.txt (opcional, >> lo crea automáticamente)
touch output.txt

# Write the current date using DD-MM-YYYY format 
# Corrección: %d es Día, %m es Mes (en minúscula) y %Y es Año
date +%d-%m-%Y >> output.txt

# Append first and last name to the file
echo "${FIRST_NAME} ${LAST_NAME}" >> output.txt

# Backup the output.txt file to a new backup.txt file
cp output.txt backup.txt

# --- AQUÍ APARECE TU NOMBRE EN LA TERMINAL ---
# Opción A: Imprime un mensaje directo usando las variables
echo "Ejecutado por: ${FIRST_NAME} ${LAST_NAME}"

# Opción B: Muestra todo el contenido actualizado del archivo
echo "--- Contenido de output.txt ---"
cat output.txt