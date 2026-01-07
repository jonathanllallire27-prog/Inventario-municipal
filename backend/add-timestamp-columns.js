const pool = require('./src/config/database');

async function addUpdatedAtColumn() {
    try {
        // Agregar columna updated_at si no existe
        await pool.query(`
            ALTER TABLE equipos 
            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        `);
        console.log('✅ Columna updated_at agregada');
        
        // Agregar columna created_at si no existe
        await pool.query(`
            ALTER TABLE equipos 
            ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        `);
        console.log('✅ Columna created_at agregada');
        
        console.log('✅ Columnas de timestamp agregadas exitosamente');
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        pool.end();
    }
}

addUpdatedAtColumn();
