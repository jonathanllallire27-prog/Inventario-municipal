const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');

// GET /api/equipos - Obtener todos los equipos
router.get('/', async (req, res) => {
    try {
        const { oficina, tipo, estado, search } = req.query;

        let query = 'SELECT * FROM equipos WHERE 1=1';
        const params = [];
        let paramIndex = 1;

        // Filtros opcionales
        if (oficina && oficina !== 'Todas') {
            query += ` AND oficina = $${paramIndex}`;
            params.push(oficina);
            paramIndex++;
        }

        if (tipo) {
            query += ` AND tipo = $${paramIndex}`;
            params.push(tipo);
            paramIndex++;
        }

        if (estado) {
            query += ` AND estado = $${paramIndex}`;
            params.push(estado);
            paramIndex++;
        }

        if (search) {
            query += ` AND (
        LOWER(oficina) LIKE LOWER($${paramIndex}) OR 
        LOWER(tipo) LIKE LOWER($${paramIndex}) OR 
        LOWER(microprocesador) LIKE LOWER($${paramIndex}) OR
        LOWER(marca) LIKE LOWER($${paramIndex})
      )`;
            params.push(`%${search}%`);
            paramIndex++;
        }

        query += ' ORDER BY id ASC';

        const result = await pool.query(query, params);

        res.json({
            success: true,
            message: 'Equipos obtenidos exitosamente',
            data: result.rows,
            total: result.rows.length
        });

    } catch (error) {
        console.error('Error obteniendo equipos:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// GET /api/equipos/estadisticas - Obtener estadísticas
router.get('/estadisticas', async (req, res) => {
    try {
        const totalResult = await pool.query('SELECT COUNT(*) FROM equipos');
        const pcResult = await pool.query("SELECT COUNT(*) FROM equipos WHERE LOWER(tipo) LIKE '%pc%'");
        const laptopResult = await pool.query("SELECT COUNT(*) FROM equipos WHERE LOWER(tipo) LIKE '%laptop%'");
        const servidorResult = await pool.query("SELECT COUNT(*) FROM equipos WHERE LOWER(tipo) LIKE '%servidor%'");
        const buenoResult = await pool.query("SELECT COUNT(*) FROM equipos WHERE LOWER(estado) LIKE '%bueno%'");
        const regularResult = await pool.query("SELECT COUNT(*) FROM equipos WHERE LOWER(estado) LIKE '%regular%'");
        const maloResult = await pool.query("SELECT COUNT(*) FROM equipos WHERE LOWER(estado) LIKE '%malo%'");

        res.json({
            success: true,
            data: {
                total: parseInt(totalResult.rows[0].count),
                pc: parseInt(pcResult.rows[0].count),
                laptop: parseInt(laptopResult.rows[0].count),
                servidor: parseInt(servidorResult.rows[0].count),
                bueno: parseInt(buenoResult.rows[0].count),
                regular: parseInt(regularResult.rows[0].count),
                malo: parseInt(maloResult.rows[0].count)
            }
        });

    } catch (error) {
        console.error('Error obteniendo estadísticas:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// GET /api/equipos/oficinas - Obtener lista de oficinas
router.get('/oficinas', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT DISTINCT oficina FROM equipos ORDER BY oficina'
        );

        res.json({
            success: true,
            data: result.rows.map(row => row.oficina)
        });

    } catch (error) {
        console.error('Error obteniendo oficinas:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// GET /api/equipos/siguiente-numero - Obtener el siguiente número de inventario
router.get('/siguiente-numero', async (req, res) => {
    try {
        // Obtener el número más alto y sumarle 1
        const result = await pool.query(`
            SELECT COALESCE(MAX(CAST(numero AS INTEGER)), 0) + 1 as siguiente
            FROM equipos 
            WHERE numero ~ '^[0-9]+$'
        `);

        const siguienteNumero = result.rows[0].siguiente || 1;

        res.json({
            success: true,
            data: { numero: siguienteNumero.toString() }
        });

    } catch (error) {
        console.error('Error obteniendo siguiente número:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// GET /api/equipos/:id - Obtener un equipo por ID
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'SELECT * FROM equipos WHERE id = $1',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Equipo no encontrado'
            });
        }

        res.json({
            success: true,
            data: result.rows[0]
        });

    } catch (error) {
        console.error('Error obteniendo equipo:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// POST /api/equipos - Crear nuevo equipo (requiere autenticación admin)
router.post('/', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const {
            numero,
            oficina,
            tipo,
            microprocesador,
            sistema_operativo,
            marca,
            memoria_ram,
            disco_duro,
            estado,
            monitor,
            sede,
            escaner,
            impresoras,
            ip
        } = req.body;

        // Validar campos requeridos
        if (!numero || !oficina || !tipo) {
            return res.status(400).json({
                success: false,
                message: 'Número, oficina y tipo son requeridos'
            });
        }

        const result = await pool.query(
            `INSERT INTO equipos (
        numero, oficina, tipo, microprocesador, sistema_operativo, 
        marca, memoria_ram, disco_duro, estado, monitor, 
        sede, escaner, impresoras, ip
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING *`,
            [
                numero, oficina, tipo, microprocesador || '', sistema_operativo || '',
                marca || '', memoria_ram || '', disco_duro || '', estado || 'BUENO', monitor || '',
                sede || 'PRINCIPAL', escaner || 'NO', impresoras || '', ip || ''
            ]
        );

        res.status(201).json({
            success: true,
            message: 'Equipo creado exitosamente',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('Error creando equipo:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

// PUT /api/equipos/:id - Actualizar equipo (requiere autenticación admin)
router.put('/:id', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        console.log('PUT /api/equipos/:id - Datos recibidos:', req.body);
        
        const {
            numero,
            oficina,
            tipo,
            microprocesador,
            sistema_operativo,
            marca,
            memoria_ram,
            disco_duro,
            estado,
            monitor,
            sede,
            escaner,
            impresoras,
            ip
        } = req.body;

        // Verificar si el equipo existe
        const equipoExists = await pool.query(
            'SELECT * FROM equipos WHERE id = $1',
            [id]
        );

        if (equipoExists.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Equipo no encontrado'
            });
        }

        const result = await pool.query(
            `UPDATE equipos SET
        numero = COALESCE($1, numero),
        oficina = COALESCE($2, oficina),
        tipo = COALESCE($3, tipo),
        microprocesador = COALESCE($4, microprocesador),
        sistema_operativo = COALESCE($5, sistema_operativo),
        marca = COALESCE($6, marca),
        memoria_ram = COALESCE($7, memoria_ram),
        disco_duro = COALESCE($8, disco_duro),
        estado = COALESCE($9, estado),
        monitor = COALESCE($10, monitor),
        sede = COALESCE($11, sede),
        escaner = COALESCE($12, escaner),
        impresoras = COALESCE($13, impresoras),
        ip = COALESCE($14, ip),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $15
      RETURNING *`,
            [
                numero, oficina, tipo, microprocesador, sistema_operativo,
                marca, memoria_ram, disco_duro, estado, monitor,
                sede, escaner, impresoras, ip, id
            ]
        );

        res.json({
            success: true,
            message: 'Equipo actualizado exitosamente',
            data: result.rows[0]
        });

    } catch (error) {
        console.error('Error actualizando equipo:', error);
        console.error('Detalle:', error.message);
        console.error('Código:', error.code);
        res.status(500).json({
            success: false,
            message: `Error: ${error.message || 'Error interno del servidor'}`,
            code: error.code
        });
    }
});

// DELETE /api/equipos/:id - Eliminar equipo (requiere autenticación admin)
router.delete('/:id', authMiddleware, adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;

        // Verificar si el equipo existe
        const equipoExists = await pool.query(
            'SELECT * FROM equipos WHERE id = $1',
            [id]
        );

        if (equipoExists.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Equipo no encontrado'
            });
        }

        await pool.query('DELETE FROM equipos WHERE id = $1', [id]);

        res.json({
            success: true,
            message: 'Equipo eliminado exitosamente'
        });

    } catch (error) {
        console.error('Error eliminando equipo:', error);
        res.status(500).json({
            success: false,
            message: 'Error interno del servidor'
        });
    }
});

module.exports = router;
