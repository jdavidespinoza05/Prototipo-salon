-- Script de inicialización de PostgreSQL para el Sistema de Salón de Belleza
-- La base de datos ya es creada por Docker, solo configuramos extensiones

-- Asegurar que tenemos la extensión para UUID si la necesitamos en el futuro
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
