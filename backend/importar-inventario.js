/**
 * Script para importar datos del inventario CPU 2025
 * Ejecutar con: node importar-inventario.js
 */

const xlsx = require('xlsx');
const pool = require('./src/config/database');
const path = require('path');

const importarInventario = async () => {
    console.log('📊 Iniciando importación del Inventario CPU 2025...\n');

    try {
        // Leer archivo Excel
        const rutaExcel = path.join(__dirname, 'INVENTARIO CPU 2025.xlsx');
        console.log(`📁 Leyendo archivo: ${rutaExcel}`);
        
        const workbook = xlsx.readFile(rutaExcel);
        const sheetName = workbook.SheetNames[0];
        const sheet = workbook.Sheets[sheetName];
        
        // Convertir a JSON
        const datos = xlsx.utils.sheet_to_json(sheet, { header: 1 });
        
        console.log(`📋 Hoja: ${sheetName}`);
        console.log(`📝 Total de filas: ${datos.length}`);
        
        // Mostrar encabezados
        const headers = datos[0];
        console.log('\n📌 Columnas encontradas:');
        headers.forEach((h, i) => {
            if (h) console.log(`   ${i}: ${h}`);
        });
        
        // Limpiar tabla de equipos existentes
        console.log('\n🗑️  Limpiando equipos existentes...');
        await pool.query('DELETE FROM equipos');
        
        /**
         * Mapeo de columnas según el Excel:
         * 0: N°
         * 1: OFICINA
         * 2: PC/LAPTOP (tipo)
         * 3: MICROPROCESADOR
         * 4: SISTEMA OPERATIVO
         * 5: Marca
         * 6: MEMORIA RAM
         * 7: DISCO DURO/SSD
         * 8: ESTADO
         * 9: MONITOR(marca/modelo)
         * 10: SEDE (si existe)
         * 11: ESCANER (si existe)
         * 12: IMPRESORAS (si existe)
         * 13: IP
         */
        
        let insertados = 0;
        let errores = 0;
        
        // Empezar desde fila 1 (saltando encabezados)
        for (let i = 1; i < datos.length; i++) {
            const fila = datos[i];
            
            // Saltar filas vacías
            if (!fila || !fila[0] || !fila[1]) continue;
            
            // Saltar si el número no es válido
            const numero = String(fila[0] || '').trim();
            if (!numero || numero === '' || numero.toLowerCase() === 'n°') continue;
            
            try {
                // Extraer datos de la fila
                const equipo = {
                    numero: numero,
                    oficina: normalzarOficina(String(fila[1] || '').trim()),
                    tipo: normalizarTipo(String(fila[2] || 'PC').trim()),
                    microprocesador: String(fila[3] || '').trim(),
                    sistema_operativo: String(fila[4] || '').trim(),
                    marca: String(fila[5] || '').trim(),
                    memoria_ram: normalizarRAM(String(fila[6] || '').trim()),
                    disco_duro: String(fila[7] || '').trim(),
                    estado: normalizarEstado(String(fila[8] || 'BUENO').trim()),
                    monitor: String(fila[9] || '').trim(),
                    sede: 'PRINCIPAL', // Por defecto
                    escaner: 'NO', // Por defecto
                    impresoras: '',
                    ip: String(fila[13] || '').trim()
                };
                
                // Insertar en la base de datos
                await pool.query(
                    `INSERT INTO equipos 
                    (numero, oficina, tipo, microprocesador, sistema_operativo, marca, 
                     memoria_ram, disco_duro, estado, monitor, sede, escaner, impresoras, ip)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
                    [
                        equipo.numero,
                        equipo.oficina,
                        equipo.tipo,
                        equipo.microprocesador,
                        equipo.sistema_operativo,
                        equipo.marca,
                        equipo.memoria_ram,
                        equipo.disco_duro,
                        equipo.estado,
                        equipo.monitor,
                        equipo.sede,
                        equipo.escaner,
                        equipo.impresoras,
                        equipo.ip
                    ]
                );
                
                insertados++;
                
                // Mostrar progreso cada 20 registros
                if (insertados % 20 === 0) {
                    console.log(`   ✅ ${insertados} equipos importados...`);
                }
                
            } catch (err) {
                errores++;
                console.log(`   ❌ Error en fila ${i + 1}: ${err.message}`);
            }
        }
        
        console.log('\n' + '='.repeat(50));
        console.log('📊 RESUMEN DE IMPORTACIÓN');
        console.log('='.repeat(50));
        console.log(`✅ Equipos importados: ${insertados}`);
        console.log(`❌ Errores: ${errores}`);
        
        // Mostrar estadísticas
        const stats = await pool.query(`
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN tipo = 'PC' THEN 1 ELSE 0 END) as pc,
                SUM(CASE WHEN tipo = 'LAPTOP' THEN 1 ELSE 0 END) as laptop,
                SUM(CASE WHEN tipo = 'SERVIDOR' THEN 1 ELSE 0 END) as servidor
            FROM equipos
        `);
        
        console.log('\n📈 ESTADÍSTICAS:');
        console.log(`   Total de equipos: ${stats.rows[0].total}`);
        console.log(`   PCs: ${stats.rows[0].pc}`);
        console.log(`   Laptops: ${stats.rows[0].laptop}`);
        console.log(`   Servidores: ${stats.rows[0].servidor}`);
        
        // Mostrar oficinas
        const oficinas = await pool.query(`
            SELECT oficina, COUNT(*) as cantidad 
            FROM equipos 
            GROUP BY oficina 
            ORDER BY cantidad DESC
            LIMIT 10
        `);
        
        console.log('\n🏢 TOP 10 OFICINAS:');
        oficinas.rows.forEach(o => {
            console.log(`   ${o.oficina}: ${o.cantidad} equipos`);
        });
        
        console.log('\n✅ Importación completada exitosamente!\n');
        
    } catch (error) {
        console.error('❌ Error durante la importación:', error);
    } finally {
        // Cerrar conexión
        await pool.end();
    }
};

// Funciones de normalización
function normalizarTipo(tipo) {
    const tipoUpper = tipo.toUpperCase();
    if (tipoUpper.includes('LAPTOP') || tipoUpper.includes('PORTATIL') || tipoUpper.includes('LAP')) return 'LAPTOP';
    if (tipoUpper.includes('SERVIDOR') || tipoUpper.includes('SERVER')) return 'SERVIDOR';
    return 'PC';
}

function normalizarEstado(estado) {
    const estadoUpper = estado.toUpperCase();
    if (estadoUpper.includes('BUEN') || estadoUpper === 'B') return 'BUENO';
    if (estadoUpper.includes('REG') || estadoUpper === 'R') return 'REGULAR';
    if (estadoUpper.includes('MAL') || estadoUpper === 'M') return 'MALO';
    return 'BUENO';
}

function normalizarRAM(ram) {
    if (!ram) return '';
    // Extraer número y añadir GB si no está
    const match = ram.match(/(\d+)/);
    if (match) {
        const valor = parseInt(match[1]);
        if (!ram.toUpperCase().includes('GB')) {
            return `${valor} GB`;
        }
    }
    return ram;
}

function normalzarOficina(oficina) {
    // Mapear nombres de oficina a los definidos en el sistema
    const oficinaUpper = oficina.toUpperCase();
    
    const mapeo = {
        'ABASTECIMIENTO': 'Abastecimiento',
        'ALCALDIA': 'Alcaldía',
        'ALCALDÍA': 'Alcaldía',
        'ATM': 'ATM (Área Técnica Municipal)',
        'AREA TECNICA': 'ATM (Área Técnica Municipal)',
        'CAJA': 'Caja',
        'CONTABILIDAD': 'Contabilidad',
        'DEMUNA': 'DEMUNA',
        'DESARROLLO URBANO': 'Desarrollo Urbano',
        'GERENCIA': 'Gerencia Municipal',
        'GERENCIA MUNICIPAL': 'Gerencia Municipal',
        'IMAGEN': 'Imagen Institucional',
        'IMAGEN INSTITUCIONAL': 'Imagen Institucional',
        'INFORMATICA': 'Informática',
        'INFORMÁTICA': 'Informática',
        'AREA DE INFORMATICA': 'Informática',
        'INFRAESTRUCTURA': 'Infraestructura',
        'MANTENIMIENTO': 'Mantenimiento de Maquinaria',
        'MAQUINARIA': 'Mantenimiento de Maquinaria',
        'MESA DE PARTES': 'Mesa de Partes',
        'MESA PARTES': 'Mesa de Partes',
        'OBRAS': 'Obras',
        'OBRAS PUBLICAS': 'Obras',
        'ENLACE': 'Oficina de Enlace',
        'PLANIFICACION': 'Planificación y Presupuesto',
        'PRESUPUESTO': 'Planificación y Presupuesto',
        'PROGRAMAS SOCIALES': 'Programas Sociales (PVL)',
        'PVL': 'Programas Sociales (PVL)',
        'VASO DE LECHE': 'Programas Sociales (PVL)',
        'REGISTRO CIVIL': 'Registro Civil',
        'REGISTRO': 'Registro Civil',
        'SECRETARIA': 'Secretaría General',
        'SECRETARIA GENERAL': 'Secretaría General',
        'SECRETARÍA': 'Secretaría General',
        'TESORERIA': 'Tesorería',
        'TESORERÍA': 'Tesorería',
        'UNIDAD FORMULADORA': 'Unidad Formuladora',
        'FORMULADORA': 'Unidad Formuladora',
        'CATASTRO': 'Desarrollo Urbano',
        'RECURSOS HUMANOS': 'Abastecimiento',
        'RENTAS': 'Tesorería',
        'TRAMITE': 'Mesa de Partes',
        'TRAMITE DOCUMENTARIO': 'Mesa de Partes',
        'MEDIO AMBIENTE': 'Desarrollo Urbano',
        'LOGISTICA': 'Abastecimiento'
    };
    
    // Buscar coincidencia
    for (const [key, value] of Object.entries(mapeo)) {
        if (oficinaUpper.includes(key)) {
            return value;
        }
    }
    
    // Si no hay coincidencia, retornar el original capitalizado
    return oficina.charAt(0).toUpperCase() + oficina.slice(1).toLowerCase();
}

// Ejecutar
importarInventario();
