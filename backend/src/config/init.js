const pool = require('./database');

const initDatabase = async () => {
    try {
        // Crear tabla de usuarios
        await pool.query(`
      CREATE TABLE IF NOT EXISTS usuarios (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        nombre_completo VARCHAR(100) NOT NULL,
        rol VARCHAR(20) DEFAULT 'usuario' CHECK (rol IN ('admin', 'usuario')),
        activo BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
        console.log('✅ Tabla usuarios creada/verificada');

        // Crear tabla de equipos
        await pool.query(`
      CREATE TABLE IF NOT EXISTS equipos (
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
    `);
        console.log('✅ Tabla equipos creada/verificada');

        // Insertar usuario admin por defecto si no existe
        const adminExists = await pool.query(
            "SELECT * FROM usuarios WHERE username = 'admin'"
        );

        if (adminExists.rows.length === 0) {
            const bcrypt = require('bcryptjs');
            const hashedPassword = await bcrypt.hash('admin123', 10);

            await pool.query(
                `INSERT INTO usuarios (username, password, nombre_completo, rol) 
         VALUES ($1, $2, $3, $4)`,
                ['admin', hashedPassword, 'Administrador del Sistema', 'admin']
            );
            console.log('✅ Usuario admin creado (admin/admin123)');
        }

        // Insertar equipos de ejemplo si la tabla está vacía
        const equiposCount = await pool.query('SELECT COUNT(*) FROM equipos');

        if (parseInt(equiposCount.rows[0].count) === 0) {
            const equiposEjemplo = [
                ['1', 'CATASTRO', 'PC', 'Intel® Core™ i9 -14900 3.2 GHz', 'Windows 11 Pro', 'FURY', '32 GB', '1 TB SSD', 'BUENO', 'Teros 27"', 'PRINCIPAL', 'NO', 'Multifuncional Epson EcoTank L5590', '182.18.8.44'],
                ['2', 'CATASTRO', 'PC', 'Intel® Core™ i7 -8700 3.2GHz', 'Windows 10 Pro', 'Antrix', '16 GB', '930 GB HDD', 'REGULAR', 'LG 24"', 'PRINCIPAL', 'NO', '', '182.18.8.204'],
                ['3', 'CATASTRO', 'PC', 'Intel® Core™ i7-13700 2.1GHz', 'Windows 11 Pro', 'ALLWIYA', '32 GB', '1.5 TB HDD', 'REGULAR', 'SAMSUNG 32"', 'PRINCIPAL', 'NO', 'Multifuncional Epson EcoTank L5590', '182.18.8.156'],
                ['35', 'INFRAESTRUCTURA', 'LAPTOP', 'Intel® Core™ i9-13900 2.00GHz', 'Windows 11 Pro', 'HP OMEN', '32 GB', '950 GB SSD', 'BUENO', 'LG 15.6"', 'PRINCIPAL', 'NO', 'XEROX 350', '182.18.8.120'],
                ['176', 'AREA DE INFORMATICA', 'SERVIDOR', 'Intel(R) xeon(R) Silver 4208 CPU@ 2.1 Ghz', 'Windows Server 2016', 'DELLEMC', '32 GB', '1 TB SAS', 'BUENO', 'SAMSUNG 22"', 'PRINCIPAL', 'NO', '', '8'],
            ];

            for (const equipo of equiposEjemplo) {
                await pool.query(
                    `INSERT INTO equipos (numero, oficina, tipo, microprocesador, sistema_operativo, marca, memoria_ram, disco_duro, estado, monitor, sede, escaner, impresoras, ip)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
                    equipo
                );
            }
            console.log('✅ Equipos de ejemplo insertados');
        }

        console.log('✅ Base de datos inicializada correctamente');

    } catch (error) {
        console.error('❌ Error inicializando la base de datos:', error);
        throw error;
    }
};

module.exports = initDatabase;
