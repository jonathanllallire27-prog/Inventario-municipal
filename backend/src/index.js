const express = require('express');
const cors = require('cors');
require('dotenv').config();

const initDatabase = require('./config/init');
const authRoutes = require('./routes/auth');
const equiposRoutes = require('./routes/equipos');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors({
    origin: '*', // En producción, especificar los orígenes permitidos
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logger middleware
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.path}`);
    next();
});

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/equipos', equiposRoutes);

// Ruta de salud
app.get('/api/health', (req, res) => {
    res.json({
        success: true,
        message: 'API del Sistema de Inventario Municipal funcionando correctamente',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        success: true,
        message: '🏛️ API del Sistema de Inventario Municipal',
        endpoints: {
            health: 'GET /api/health',
            auth: {
                login: 'POST /api/auth/login',
                register: 'POST /api/auth/register',
                verify: 'GET /api/auth/verify'
            },
            equipos: {
                list: 'GET /api/equipos',
                estadisticas: 'GET /api/equipos/estadisticas',
                oficinas: 'GET /api/equipos/oficinas',
                get: 'GET /api/equipos/:id',
                create: 'POST /api/equipos',
                update: 'PUT /api/equipos/:id',
                delete: 'DELETE /api/equipos/:id'
            }
        }
    });
});

// Manejo de rutas no encontradas
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Ruta no encontrada'
    });
});

// Manejo de errores global
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        success: false,
        message: 'Error interno del servidor'
    });
});

// Iniciar servidor
const startServer = async () => {
    try {
        // Inicializar base de datos
        await initDatabase();

        // Iniciar servidor en 0.0.0.0 para aceptar conexiones de red
        app.listen(PORT, '0.0.0.0', () => {
            console.log('━'.repeat(50));
            console.log('🏛️  SISTEMA DE INVENTARIO MUNICIPAL - API');
            console.log('━'.repeat(50));
            console.log(`✅ Servidor corriendo en puerto: ${PORT}`);
            console.log(`🌐 Acceso local: http://localhost:${PORT}`);
            console.log(`� Acceso red local: http://192.168.100.8:${PORT}`);
            console.log(`❤️  Health check: http://192.168.100.8:${PORT}/api/health`);
            console.log('━'.repeat(50));
        });
    } catch (error) {
        console.error('❌ Error iniciando el servidor:', error);
        process.exit(1);
    }
};

startServer();
