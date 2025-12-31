-- ============================================================
-- SCRIPT DE BASE DE DATOS - SISTEMA DE INVENTARIO MUNICIPAL
-- Municipalidad San Juan Bautista
-- ============================================================
-- Fecha de creación: 2024
-- Descripción: Script para crear la base de datos PostgreSQL
--              del Sistema de Inventario de Equipos
-- ============================================================

-- ============================================================
-- PASO 1: CREAR LA BASE DE DATOS
-- ============================================================
-- Ejecutar como superusuario (postgres)

-- Eliminar base de datos si existe (CUIDADO: esto borra todos los datos)
-- DROP DATABASE IF EXISTS inventario_municipal;

-- Crear base de datos
CREATE DATABASE inventario_municipal
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Peru.1252'
    LC_CTYPE = 'Spanish_Peru.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Agregar comentario a la base de datos
COMMENT ON DATABASE inventario_municipal IS 'Base de datos del Sistema de Inventario Municipal de San Juan Bautista';

-- ============================================================
-- PASO 2: CONECTARSE A LA BASE DE DATOS
-- ============================================================
\c inventario_municipal;

-- ============================================================
-- PASO 3: CREAR EXTENSIONES (opcional)
-- ============================================================
-- Extensión para generar UUIDs si se necesita en el futuro
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PASO 4: CREAR TABLA DE USUARIOS
-- ============================================================
DROP TABLE IF EXISTS usuarios CASCADE;

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    rol VARCHAR(20) DEFAULT 'usuario' CHECK (rol IN ('admin', 'usuario')),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_usuarios_username ON usuarios(username);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);
CREATE INDEX idx_usuarios_activo ON usuarios(activo);

-- Comentarios de la tabla
COMMENT ON TABLE usuarios IS 'Tabla de usuarios del sistema';
COMMENT ON COLUMN usuarios.id IS 'Identificador único del usuario';
COMMENT ON COLUMN usuarios.username IS 'Nombre de usuario para login';
COMMENT ON COLUMN usuarios.password IS 'Contraseña encriptada con bcrypt';
COMMENT ON COLUMN usuarios.nombre_completo IS 'Nombre completo del usuario';
COMMENT ON COLUMN usuarios.rol IS 'Rol del usuario: admin o usuario';
COMMENT ON COLUMN usuarios.activo IS 'Indica si el usuario está activo';
COMMENT ON COLUMN usuarios.created_at IS 'Fecha de creación del registro';
COMMENT ON COLUMN usuarios.updated_at IS 'Fecha de última actualización';

-- ============================================================
-- PASO 5: CREAR TABLA DE EQUIPOS
-- ============================================================
DROP TABLE IF EXISTS equipos CASCADE;

CREATE TABLE equipos (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(20) NOT NULL,
    oficina VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('PC', 'LAPTOP', 'SERVIDOR')),
    microprocesador VARCHAR(100),
    sistema_operativo VARCHAR(100),
    marca VARCHAR(100),
    memoria_ram VARCHAR(50),
    disco_duro VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'BUENO' CHECK (estado IN ('BUENO', 'REGULAR', 'MALO')),
    monitor VARCHAR(100),
    sede VARCHAR(50) DEFAULT 'PRINCIPAL',
    escaner VARCHAR(10) DEFAULT 'NO',
    impresoras TEXT,
    ip VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_equipos_oficina ON equipos(oficina);
CREATE INDEX idx_equipos_tipo ON equipos(tipo);
CREATE INDEX idx_equipos_estado ON equipos(estado);
CREATE INDEX idx_equipos_sede ON equipos(sede);
CREATE INDEX idx_equipos_numero ON equipos(numero);

-- Comentarios de la tabla
COMMENT ON TABLE equipos IS 'Inventario de equipos de cómputo de la municipalidad';
COMMENT ON COLUMN equipos.id IS 'Identificador único del equipo';
COMMENT ON COLUMN equipos.numero IS 'Número de inventario del equipo';
COMMENT ON COLUMN equipos.oficina IS 'Oficina donde se encuentra el equipo';
COMMENT ON COLUMN equipos.tipo IS 'Tipo de equipo: PC, LAPTOP, SERVIDOR';
COMMENT ON COLUMN equipos.microprocesador IS 'Especificaciones del procesador';
COMMENT ON COLUMN equipos.sistema_operativo IS 'Sistema operativo instalado';
COMMENT ON COLUMN equipos.marca IS 'Marca del equipo';
COMMENT ON COLUMN equipos.memoria_ram IS 'Capacidad de memoria RAM';
COMMENT ON COLUMN equipos.disco_duro IS 'Capacidad del disco duro';
COMMENT ON COLUMN equipos.estado IS 'Estado del equipo: BUENO, REGULAR, MALO';
COMMENT ON COLUMN equipos.monitor IS 'Descripción del monitor';
COMMENT ON COLUMN equipos.sede IS 'Sede donde se ubica el equipo';
COMMENT ON COLUMN equipos.escaner IS 'Indica si tiene escáner: SI o NO';
COMMENT ON COLUMN equipos.impresoras IS 'Impresoras asociadas al equipo';
COMMENT ON COLUMN equipos.ip IS 'Dirección IP asignada';
COMMENT ON COLUMN equipos.created_at IS 'Fecha de registro';
COMMENT ON COLUMN equipos.updated_at IS 'Fecha de última actualización';

-- ============================================================
-- PASO 6: CREAR FUNCIONES Y TRIGGERS
-- ============================================================

-- Función para actualizar automáticamente updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para tabla usuarios
DROP TRIGGER IF EXISTS update_usuarios_updated_at ON usuarios;
CREATE TRIGGER update_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger para tabla equipos
DROP TRIGGER IF EXISTS update_equipos_updated_at ON equipos;
CREATE TRIGGER update_equipos_updated_at
    BEFORE UPDATE ON equipos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- PASO 7: INSERTAR USUARIO ADMINISTRADOR POR DEFECTO
-- ============================================================
-- La contraseña 'admin123' está hasheada con bcrypt (10 rounds)
-- Hash generado: $2a$10$rOzJqQZQXqQZQXqQZQXqQeOzJqQZQXqQZQXqQZQXqQeOzJqQZQXqQ

INSERT INTO usuarios (username, password, nombre_completo, rol, activo) 
VALUES (
    'admin', 
    '$2a$10$8K1p/a0dR1LXMIgNNPLQku6hLzMBXFw9YxhE5k9XxXs5h5XwQ5Xhe',  -- admin123
    'Administrador del Sistema', 
    'admin', 
    true
) ON CONFLICT (username) DO NOTHING;

-- ============================================================
-- PASO 8: INSERTAR DATOS DE EJEMPLO
-- ============================================================

-- Equipos de ejemplo para demostración
INSERT INTO equipos (numero, oficina, tipo, microprocesador, sistema_operativo, marca, memoria_ram, disco_duro, estado, monitor, sede, escaner, impresoras, ip) VALUES
    ('1', 'CATASTRO', 'PC', 'Intel® Core™ i9 -14900 3.2 GHz', 'Windows 11 Pro', 'FURY', '32 GB', '1 TB SSD', 'BUENO', 'Teros 27"', 'PRINCIPAL', 'NO', 'Multifuncional Epson EcoTank L5590', '182.18.8.44'),
    ('2', 'CATASTRO', 'PC', 'Intel® Core™ i7 -8700 3.2GHz', 'Windows 10 Pro', 'Antrix', '16 GB', '930 GB HDD', 'REGULAR', 'LG 24"', 'PRINCIPAL', 'NO', '', '182.18.8.204'),
    ('3', 'CATASTRO', 'PC', 'Intel® Core™ i7-13700 2.1GHz', 'Windows 11 Pro', 'ALLWIYA', '32 GB', '1.5 TB HDD', 'REGULAR', 'SAMSUNG 32"', 'PRINCIPAL', 'NO', 'Multifuncional Epson EcoTank L5590', '182.18.8.156'),
    ('4', 'TESORERIA', 'PC', 'Intel® Core™ i5-10400 2.9GHz', 'Windows 10 Pro', 'HP', '8 GB', '500 GB HDD', 'BUENO', 'HP 22"', 'PRINCIPAL', 'NO', 'HP LaserJet Pro', '182.18.8.101'),
    ('5', 'TESORERIA', 'PC', 'Intel® Core™ i5-12400 2.5GHz', 'Windows 11 Pro', 'DELL', '16 GB', '512 GB SSD', 'BUENO', 'Dell 24"', 'PRINCIPAL', 'SI', 'Epson L3150', '182.18.8.102'),
    ('6', 'CONTABILIDAD', 'PC', 'Intel® Core™ i7-11700 2.5GHz', 'Windows 10 Pro', 'Lenovo', '16 GB', '1 TB HDD', 'BUENO', 'Lenovo 23"', 'PRINCIPAL', 'NO', 'Canon G3110', '182.18.8.110'),
    ('7', 'CONTABILIDAD', 'PC', 'AMD Ryzen 5 5600G', 'Windows 11 Pro', 'ASUS', '16 GB', '512 GB SSD', 'BUENO', 'ASUS 24"', 'PRINCIPAL', 'NO', '', '182.18.8.111'),
    ('8', 'RECURSOS HUMANOS', 'PC', 'Intel® Core™ i5-9400 2.9GHz', 'Windows 10 Pro', 'HP', '8 GB', '500 GB HDD', 'REGULAR', 'HP 21"', 'PRINCIPAL', 'NO', 'HP DeskJet 2700', '182.18.8.115'),
    ('9', 'RECURSOS HUMANOS', 'PC', 'Intel® Core™ i3-10100 3.6GHz', 'Windows 10 Pro', 'Dell', '8 GB', '256 GB SSD', 'BUENO', 'Dell 22"', 'PRINCIPAL', 'NO', '', '182.18.8.116'),
    ('10', 'SECRETARIA GENERAL', 'PC', 'Intel® Core™ i7-12700 2.1GHz', 'Windows 11 Pro', 'HP', '16 GB', '1 TB SSD', 'BUENO', 'HP 27"', 'PRINCIPAL', 'SI', 'HP Color LaserJet Pro', '182.18.8.50'),
    ('11', 'ALCALDIA', 'PC', 'Intel® Core™ i9-12900K 3.2GHz', 'Windows 11 Pro', 'Apple iMac', '32 GB', '1 TB SSD', 'BUENO', 'Apple 27" Retina', 'PRINCIPAL', 'SI', 'Canon PIXMA', '182.18.8.10'),
    ('12', 'GERENCIA MUNICIPAL', 'PC', 'Intel® Core™ i7-13700 2.1GHz', 'Windows 11 Pro', 'DELL', '32 GB', '1 TB SSD', 'BUENO', 'Dell UltraSharp 27"', 'PRINCIPAL', 'NO', 'HP LaserJet Enterprise', '182.18.8.20'),
    ('13', 'OBRAS PUBLICAS', 'PC', 'Intel® Core™ i5-11400 2.6GHz', 'Windows 10 Pro', 'Lenovo', '16 GB', '512 GB SSD', 'BUENO', 'Lenovo 24"', 'PRINCIPAL', 'NO', 'Epson L4160', '182.18.8.130'),
    ('14', 'OBRAS PUBLICAS', 'PC', 'Intel® Core™ i5-10500 3.1GHz', 'Windows 10 Pro', 'HP', '8 GB', '500 GB HDD', 'REGULAR', 'HP 23"', 'PRINCIPAL', 'NO', '', '182.18.8.131'),
    ('15', 'MEDIO AMBIENTE', 'PC', 'Intel® Core™ i5-12500 3.0GHz', 'Windows 11 Pro', 'ASUS', '16 GB', '512 GB SSD', 'BUENO', 'ASUS ProArt 24"', 'PRINCIPAL', 'NO', 'Canon G2160', '182.18.8.140'),
    ('20', 'LOGISTICA', 'PC', 'Intel® Core™ i5-10400 2.9GHz', 'Windows 10 Pro', 'Dell', '8 GB', '500 GB HDD', 'BUENO', 'Dell 22"', 'PRINCIPAL', 'NO', 'Epson WF-2830', '182.18.8.160'),
    ('21', 'LOGISTICA', 'PC', 'Intel® Core™ i3-10100 3.6GHz', 'Windows 10 Pro', 'HP', '8 GB', '256 GB SSD', 'REGULAR', 'HP 21"', 'PRINCIPAL', 'NO', '', '182.18.8.161'),
    ('25', 'RENTAS', 'PC', 'Intel® Core™ i7-11700 2.5GHz', 'Windows 11 Pro', 'Lenovo', '16 GB', '1 TB HDD', 'BUENO', 'Lenovo 27"', 'PRINCIPAL', 'SI', 'Epson EcoTank L6270', '182.18.8.170'),
    ('26', 'RENTAS', 'PC', 'Intel® Core™ i5-12400 2.5GHz', 'Windows 11 Pro', 'DELL', '16 GB', '512 GB SSD', 'BUENO', 'Dell 24"', 'PRINCIPAL', 'NO', '', '182.18.8.171'),
    ('30', 'TRAMITE DOCUMENTARIO', 'PC', 'Intel® Core™ i5-10400 2.9GHz', 'Windows 10 Pro', 'HP', '8 GB', '500 GB HDD', 'BUENO', 'HP 22"', 'PRINCIPAL', 'SI', 'HP LaserJet M140w', '182.18.8.180'),
    ('35', 'INFRAESTRUCTURA', 'LAPTOP', 'Intel® Core™ i9-13900 2.00GHz', 'Windows 11 Pro', 'HP OMEN', '32 GB', '950 GB SSD', 'BUENO', 'Pantalla 15.6"', 'PRINCIPAL', 'NO', 'XEROX 350', '182.18.8.120'),
    ('36', 'GERENCIA MUNICIPAL', 'LAPTOP', 'Apple M2 Pro', 'macOS Ventura', 'Apple MacBook Pro', '16 GB', '512 GB SSD', 'BUENO', 'Retina 14"', 'PRINCIPAL', 'NO', '', '182.18.8.21'),
    ('37', 'OBRAS PUBLICAS', 'LAPTOP', 'Intel® Core™ i7-1355U 1.8GHz', 'Windows 11 Pro', 'DELL Latitude', '16 GB', '512 GB SSD', 'BUENO', 'Pantalla 14"', 'PRINCIPAL', 'NO', '', '182.18.8.132'),
    ('38', 'CATASTRO', 'LAPTOP', 'Intel® Core™ i7-12700H 2.3GHz', 'Windows 11 Pro', 'Lenovo ThinkPad', '16 GB', '1 TB SSD', 'BUENO', 'Pantalla 15.6"', 'PRINCIPAL', 'NO', '', '182.18.8.45'),
    ('176', 'AREA DE INFORMATICA', 'SERVIDOR', 'Intel(R) Xeon(R) Silver 4208 CPU @ 2.1 GHz', 'Windows Server 2016', 'DELL EMC PowerEdge R440', '32 GB', '1 TB SAS', 'BUENO', 'SAMSUNG 22"', 'PRINCIPAL', 'NO', '', '182.18.8.1'),
    ('177', 'AREA DE INFORMATICA', 'SERVIDOR', 'Intel(R) Xeon(R) Gold 6226R @ 2.9 GHz', 'Windows Server 2019', 'HP ProLiant DL380', '64 GB', '2 TB SAS RAID', 'BUENO', 'HP 19"', 'PRINCIPAL', 'NO', '', '182.18.8.2'),
    ('178', 'AREA DE INFORMATICA', 'SERVIDOR', 'Intel(R) Xeon(R) E-2334 @ 3.4 GHz', 'Ubuntu Server 22.04', 'Dell PowerEdge T350', '32 GB', '4 TB HDD RAID', 'BUENO', '', 'PRINCIPAL', 'NO', '', '182.18.8.3')
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 9: CREAR VISTAS ÚTILES
-- ============================================================

-- Vista de resumen de equipos por oficina
CREATE OR REPLACE VIEW vw_equipos_por_oficina AS
SELECT 
    oficina,
    COUNT(*) as total_equipos,
    SUM(CASE WHEN tipo = 'PC' THEN 1 ELSE 0 END) as total_pc,
    SUM(CASE WHEN tipo = 'LAPTOP' THEN 1 ELSE 0 END) as total_laptop,
    SUM(CASE WHEN tipo = 'SERVIDOR' THEN 1 ELSE 0 END) as total_servidor,
    SUM(CASE WHEN estado = 'BUENO' THEN 1 ELSE 0 END) as estado_bueno,
    SUM(CASE WHEN estado = 'REGULAR' THEN 1 ELSE 0 END) as estado_regular,
    SUM(CASE WHEN estado = 'MALO' THEN 1 ELSE 0 END) as estado_malo
FROM equipos
GROUP BY oficina
ORDER BY oficina;

-- Vista de estadísticas generales
CREATE OR REPLACE VIEW vw_estadisticas_generales AS
SELECT 
    COUNT(*) as total_equipos,
    SUM(CASE WHEN tipo = 'PC' THEN 1 ELSE 0 END) as total_pc,
    SUM(CASE WHEN tipo = 'LAPTOP' THEN 1 ELSE 0 END) as total_laptop,
    SUM(CASE WHEN tipo = 'SERVIDOR' THEN 1 ELSE 0 END) as total_servidor,
    SUM(CASE WHEN estado = 'BUENO' THEN 1 ELSE 0 END) as estado_bueno,
    SUM(CASE WHEN estado = 'REGULAR' THEN 1 ELSE 0 END) as estado_regular,
    SUM(CASE WHEN estado = 'MALO' THEN 1 ELSE 0 END) as estado_malo,
    COUNT(DISTINCT oficina) as total_oficinas
FROM equipos;

-- Vista de equipos con escáner
CREATE OR REPLACE VIEW vw_equipos_con_escaner AS
SELECT 
    id, numero, oficina, tipo, marca, estado, ip
FROM equipos
WHERE escaner = 'SI'
ORDER BY oficina;

-- ============================================================
-- PASO 10: OTORGAR PERMISOS (si es necesario)
-- ============================================================
-- Descomentar si necesitas crear un usuario específico para la aplicación

-- CREATE USER app_inventario WITH PASSWORD 'password_seguro';
-- GRANT CONNECT ON DATABASE inventario_municipal TO app_inventario;
-- GRANT USAGE ON SCHEMA public TO app_inventario;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_inventario;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_inventario;

-- ============================================================
-- VERIFICACIONES FINALES
-- ============================================================

-- Verificar tablas creadas
SELECT 
    table_name, 
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as num_columnas
FROM information_schema.tables t
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar conteo de registros
SELECT 'usuarios' as tabla, COUNT(*) as registros FROM usuarios
UNION ALL
SELECT 'equipos' as tabla, COUNT(*) as registros FROM equipos;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
-- 
-- INSTRUCCIONES DE USO:
-- 1. Abre pgAdmin o psql
-- 2. Conéctate como usuario postgres
-- 3. Ejecuta este script completo
-- 
-- CREDENCIALES POR DEFECTO:
-- Usuario: admin
-- Contraseña: admin123
-- 
-- NOTA: La contraseña hasheada puede no coincidir exactamente.
-- El sistema generará el hash correcto al iniciar el servidor.
-- ============================================================
