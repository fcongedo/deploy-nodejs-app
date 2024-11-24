#!/bin/bash

# Configuración
REPO_URL="https://github.com/fcongedo/deploy-nodejs-app.git"  # Cambia esto por la URL de tu repositorio
APP_DIR="/var/www/mi-aplicacion"  # Ruta donde se desplegará la aplicación
BRANCH="main"  # Rama del repositorio que se desplegará

# Verifica si Node.js está instalado
if ! which node > /dev/null; then
    echo "Node.js no está instalado. Instalando Node.js..."

    # Instalación de Node.js en Ubuntu/Debian
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs

    # Verifica que la instalación fue exitosa
    if ! which node > /dev/null; then
        echo "Error al instalar Node.js. Abortando."
        exit 1
    fi
else
    echo "Node.js está instalado."
fi

# Verifica si pm2 está instalado, si no, lo instala
if ! which pm2 > /dev/null; then
    echo "pm2 no está instalado. Instalando pm2..."
    npm install -g pm2
else
    echo "pm2 ya está instalado."
fi

# Verifica si git está instalado, si no, lo instala
if ! which git > /dev/null; then
    echo "git no está instalado. Instalando git..."
    sudo apt-get install -y git
else
    echo "git ya está instalado."
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