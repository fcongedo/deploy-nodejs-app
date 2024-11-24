#!/bin/bash

# Configuración
REPO_URL="https://github.com/tu-usuario/tu-repo.git"  # Cambia esto por la URL de tu repositorio
APP_DIR="/var/www/mi-aplicacion"  # Ruta donde se desplegará la aplicación
BRANCH="main"  # Rama del repositorio que se desplegará

# Verifica si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "Node.js no está instalado. Por favor, instálalo antes de continuar."
    exit 1
fi

# Verifica si pm2 está instalado, si no, lo instala
if ! command -v pm2 &> /dev/null; then
    echo "pm2 no está instalado. Instalándolo..."
    npm install -g pm2
fi

# Clonar o actualizar el repositorio
if [ -d "$APP_DIR" ]; then
    echo "Repositorio existente. Haciendo pull..."
    cd "$APP_DIR"
    git reset --hard  # Asegura que no haya conflictos
    git pull origin "$BRANCH"
else
    echo "Clonando el repositorio..."
    git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

# Instalar dependencias del proyecto
if [ -f package.json ]; then
    echo "Instalando dependencias..."
    npm install
else
    echo "No se encontró package.json. Abortando."
    exit 1
fi

# Desplegar la aplicación con pm2
echo "Desplegando la aplicación con pm2..."
pm2 stop "mi-aplicacion" || true  # Detiene la app si ya está corriendo
pm2 start index.js --name "mi-aplicacion" --watch

echo "¡Despliegue completo! La aplicación está corriendo."