#!/bin/bash

# ==================================================
# Script de Inicio Rápido
# Salón de Belleza - Sistema de Fidelidad
# ==================================================

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║        SISTEMA DE FIDELIDAD - SALÓN DE BELLEZA                ║
║                                                               ║
║              Instalación y Configuración Rápida               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Bienvenido a la instalación del Sistema de Fidelidad${NC}"
echo ""

# Función para verificar Docker
check_docker() {
    echo -e "${BLUE}[1/5]${NC} Verificando Docker..."
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker no está instalado${NC}"
        echo "Por favor, instala Docker desde: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker no está corriendo${NC}"
        echo "Por favor, inicia Docker Desktop o el servicio de Docker"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker está instalado y corriendo${NC}"
}

# Función para verificar Docker Compose
check_docker_compose() {
    echo -e "${BLUE}[2/5]${NC} Verificando Docker Compose..."
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose no está instalado${NC}"
        echo "Por favor, instala Docker Compose"
        exit 1
    fi
    echo -e "${GREEN}✅ Docker Compose está instalado${NC}"
}

# Función para crear archivo .env si no existe
create_env() {
    echo -e "${BLUE}[3/5]${NC} Configurando variables de entorno..."
    if [ ! -f ".env" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Archivo .env creado${NC}"
        echo -e "${YELLOW}⚠️  Por favor, revisa y ajusta el archivo .env según tus necesidades${NC}"
    else
        echo -e "${YELLOW}⚠️  El archivo .env ya existe, saltando...${NC}"
    fi
}

# Función para levantar contenedores
start_containers() {
    echo -e "${BLUE}[4/5]${NC} Iniciando contenedores..."
    echo "Esto puede tomar varios minutos la primera vez..."
    echo ""
    
    docker-compose up -d
    
    echo ""
    echo -e "${GREEN}✅ Contenedores iniciados${NC}"
}

# Función para esperar a Oracle
wait_oracle() {
    echo -e "${BLUE}[5/5]${NC} Esperando a que Oracle esté listo..."
    echo "Esto puede tomar 5-10 minutos la primera vez..."
    echo ""
    
    local max_attempts=120
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker logs oracle-salon-belleza 2>&1 | grep -q "DATABASE IS READY TO USE"; then
            echo ""
            echo -e "${GREEN}✅ Oracle está listo!${NC}"
            return 0
        fi
        echo -ne "Esperando... (${attempt}/${max_attempts})\r"
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo ""
    echo -e "${RED}❌ Timeout esperando a Oracle${NC}"
    return 1
}

# Función para inicializar la base de datos
init_database() {
    echo ""
    echo -e "${BLUE}Inicializando base de datos...${NC}"
    echo ""
    
    ./init_db.sh << EOF
1

EOF
}

# Función para mostrar información final
show_info() {
    echo ""
    echo -e "${GREEN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║                 ¡INSTALACIÓN COMPLETADA!                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${BLUE}📊 Información de Conexión:${NC}"
    echo ""
    echo "   Base de Datos Oracle:"
    echo "   ├─ Host: localhost"
    echo "   ├─ Puerto: 1521"
    echo "   ├─ SID: XE"
    echo "   ├─ Usuario: salon_user"
    echo "   └─ Password: salon_pass123"
    echo ""
    echo "   URL de Conexión:"
    echo "   └─ jdbc:oracle:thin:@localhost:1521:XE"
    echo ""
    
    echo -e "${BLUE}🔧 Comandos Útiles:${NC}"
    echo ""
    echo "   Ver logs de Oracle:"
    echo "   └─ docker logs oracle-salon-belleza -f"
    echo ""
    echo "   Conectarse a SQLPlus:"
    echo "   └─ docker exec -it oracle-salon-belleza sqlplus salon_user/salon_pass123@XE"
    echo ""
    echo "   Gestionar base de datos:"
    echo "   └─ ./init_db.sh"
    echo ""
    echo "   Detener contenedores:"
    echo "   └─ docker-compose down"
    echo ""
    echo "   Reiniciar contenedores:"
    echo "   └─ docker-compose restart"
    echo ""
    
    echo -e "${BLUE}📚 Documentación:${NC}"
    echo ""
    echo "   README.md              - Documentación general"
    echo "   DIAGRAMA_ER.md         - Diagrama de base de datos"
    echo "   GUIA_CONEXION.md       - Guías de conexión"
    echo "   queries_utiles.sql     - Consultas de ejemplo"
    echo ""
    
    echo -e "${BLUE}🎯 Próximos Pasos:${NC}"
    echo ""
    echo "   1. Revisa el archivo README.md"
    echo "   2. Conecta tu aplicación Angular al backend"
    echo "   3. Desarrolla los servicios REST API"
    echo "   4. Personaliza la configuración en .env"
    echo ""
    
    echo -e "${GREEN}¡Listo para comenzar a desarrollar! 🚀${NC}"
    echo ""
}

# Script principal
main() {
    check_docker
    check_docker_compose
    create_env
    start_containers
    wait_oracle
    
    echo ""
    read -p "¿Deseas inicializar la base de datos ahora? (S/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        init_database
    else
        echo -e "${YELLOW}Puedes inicializar la base de datos más tarde ejecutando: ./init_db.sh${NC}"
    fi
    
    show_info
}

# Ejecutar
main
