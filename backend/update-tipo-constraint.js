const pool = require('./src/config/database');

async function updateConstraint() {
    try {
        // Eliminar el constraint actual
        await pool.query('ALTER TABLE equipos DROP CONSTRAINT IF EXISTS equipos_tipo_check');
        console.log('Constraint anterior eliminado');
        
        // Agregar el nuevo constraint con IMPRESORA
        await pool.query("ALTER TABLE equipos ADD CONSTRAINT equipos_tipo_check CHECK (tipo IN ('PC', 'LAPTOP', 'SERVIDOR', 'IMPRESORA'))");
        console.log('Nuevo constraint agregado con IMPRESORA');
        
        console.log('✅ Constraint actualizado exitosamente');
    } catch (error) {
        console.error('Error:', error.message);
    } finally {
        pool.end();
    }
}

updateConstraint();
