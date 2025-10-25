#!/bin/bash

# ==================================================
# Script de Inicialización de Base de Datos
# Salón de Belleza - Sistema de Fidelidad
# ==================================================

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
CONTAINER_NAME="oracle-salon-belleza"
ORACLE_USER="system"
ORACLE_PASS="oracle"
ORACLE_SID="XE"
APP_USER="salon_user"

# Función para imprimir mensajes
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para verificar si Docker está corriendo
check_docker() {
    print_message "Verificando Docker..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker no está corriendo. Por favor, inicia Docker y vuelve a intentar."
        exit 1
    fi
    print_success "Docker está corriendo"
}

# Función para verificar si el contenedor existe
check_container() {
    print_message "Verificando contenedor..."
    if ! docker ps -a | grep -q $CONTAINER_NAME; then
        print_error "El contenedor $CONTAINER_NAME no existe."
        print_message "Ejecuta 'docker-compose up -d' primero."
        exit 1
    fi
    print_success "Contenedor encontrado"
}

# Función para esperar a que Oracle esté listo
wait_for_oracle() {
    print_message "Esperando a que Oracle esté listo..."
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker logs $CONTAINER_NAME 2>&1 | grep -q "DATABASE IS READY TO USE"; then
            print_success "Oracle está listo!"
            return 0
        fi
        echo -ne "Intento $attempt/$max_attempts...\r"
        sleep 5
        attempt=$((attempt + 1))
    done
    
    print_error "Timeout esperando a Oracle"
    return 1
}

# Función para ejecutar SQL en el contenedor
execute_sql() {
    local sql_command=$1
    docker exec -i $CONTAINER_NAME bash -c "echo \"$sql_command\" | sqlplus -s $ORACLE_USER/$ORACLE_PASS@$ORACLE_SID"
}

# Función para ejecutar archivo SQL
execute_sql_file() {
    local sql_file=$1
    local user=$2
    local pass=$3
    
    print_message "Ejecutando $sql_file..."
    docker exec -i $CONTAINER_NAME sqlplus -s $user/$pass@$ORACLE_SID < "$sql_file"
}

# Función para verificar si el usuario ya existe
check_user_exists() {
    local result=$(execute_sql "SELECT COUNT(*) FROM dba_users WHERE username = '$APP_USER';")
    if echo "$result" | grep -q "1"; then
        return 0  # Usuario existe
    else
        return 1  # Usuario no existe
    fi
}

# Función para verificar si las tablas existen
check_tables_exist() {
    local result=$(execute_sql "SELECT COUNT(*) FROM dba_tables WHERE owner = UPPER('$APP_USER');")
    local count=$(echo "$result" | grep -o '[0-9]*' | head -1)
    if [ "$count" -gt 0 ]; then
        return 0  # Tablas existen
    else
        return 1  # No hay tablas
    fi
}

# Función principal de inicialización
initialize_database() {
    print_message "=========================================="
    print_message "Inicializando Base de Datos"
    print_message "=========================================="
    
    # Verificar si el usuario ya existe
    if check_user_exists; then
        print_warning "El usuario $APP_USER ya existe."
        read -p "¿Deseas recrear la base de datos? Esto eliminará todos los datos existentes. (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            print_message "Operación cancelada."
            exit 0
        fi
        
        print_message "Eliminando usuario y datos existentes..."
        execute_sql "DROP USER $APP_USER CASCADE;"
        print_success "Usuario eliminado"
    fi
    
    # Crear usuario
    print_message "Creando usuario $APP_USER..."
    execute_sql_file "database/init/01_create_user.sql" "$ORACLE_USER" "$ORACLE_PASS"
    print_success "Usuario creado"
    
    # Crear tablas
    print_message "Creando tablas..."
    execute_sql_file "database/init/02_create_tables.sql" "$APP_USER" "salon_pass123"
    print_success "Tablas creadas"
    
    # Crear triggers
    print_message "Creando triggers y procedimientos..."
    execute_sql_file "database/init/03_create_triggers.sql" "$APP_USER" "salon_pass123"
    print_success "Triggers y procedimientos creados"
    
    # Insertar datos iniciales
    print_message "Insertando datos de ejemplo..."
    execute_sql_file "database/init/04_insert_data.sql" "$APP_USER" "salon_pass123"
    print_success "Datos insertados"
    
    print_success "=========================================="
    print_success "Base de datos inicializada exitosamente!"
    print_success "=========================================="
}

# Función para mostrar estadísticas
show_stats() {
    print_message "=========================================="
    print_message "Estadísticas de la Base de Datos"
    print_message "=========================================="
    
    execute_sql "
    SET PAGESIZE 50
    SET LINESIZE 100
    COLUMN descripcion FORMAT A30
    COLUMN cantidad FORMAT 999999
    
    SELECT 'Administradores' as descripcion, COUNT(*) as cantidad FROM salon_user.administradores
    UNION ALL
    SELECT 'Clientes', COUNT(*) FROM salon_user.clientes
    UNION ALL
    SELECT 'Servicios', COUNT(*) FROM salon_user.servicios
    UNION ALL
    SELECT 'Productos', COUNT(*) FROM salon_user.productos
    UNION ALL
    SELECT 'Recompensas', COUNT(*) FROM salon_user.recompensas
    UNION ALL
    SELECT 'Transacciones', COUNT(*) FROM salon_user.transacciones_puntos
    UNION ALL
    SELECT 'Canjes', COUNT(*) FROM salon_user.canjes_recompensas
    UNION ALL
    SELECT 'Testimonios', COUNT(*) FROM salon_user.testimonios;
    "
}

# Función para backup de la base de datos
backup_database() {
    local backup_dir="backups"
    local backup_file="$backup_dir/salon_belleza_$(date +%Y%m%d_%H%M%S).dmp"
    
    print_message "Creando backup..."
    mkdir -p $backup_dir
    
    docker exec $CONTAINER_NAME bash -c "exp $APP_USER/salon_pass123 file=/tmp/backup.dmp" > /dev/null 2>&1
    docker cp $CONTAINER_NAME:/tmp/backup.dmp $backup_file
    
    print_success "Backup creado: $backup_file"
}

# Función para mostrar menú
show_menu() {
    echo ""
    echo "=========================================="
    echo "Gestión de Base de Datos - Salón Belleza"
    echo "=========================================="
    echo "1. Inicializar/Reinicializar base de datos"
    echo "2. Mostrar estadísticas"
    echo "3. Crear backup"
    echo "4. Verificar estado del contenedor"
    echo "5. Ver logs de Oracle"
    echo "6. Conectarse a SQLPlus"
    echo "7. Salir"
    echo "=========================================="
    read -p "Selecciona una opción: " choice
    
    case $choice in
        1)
            check_docker
            check_container
            wait_for_oracle
            initialize_database
            show_stats
            ;;
        2)
            check_docker
            check_container
            show_stats
            ;;
        3)
            check_docker
            check_container
            backup_database
            ;;
        4)
            docker ps -a | grep $CONTAINER_NAME
            ;;
        5)
            docker logs $CONTAINER_NAME --tail 50 -f
            ;;
        6)
            print_message "Conectándose a SQLPlus como $APP_USER..."
            docker exec -it $CONTAINER_NAME sqlplus $APP_USER/salon_pass123@$ORACLE_SID
            ;;
        7)
            print_message "¡Hasta luego!"
            exit 0
            ;;
        *)
            print_error "Opción inválida"
            ;;
    esac
}

# Script principal
main() {
    clear
    
    # Verificar que estemos en el directorio correcto
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
        exit 1
    fi
    
    # Mostrar menú
    while true; do
        show_menu
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Ejecutar script principal
main
