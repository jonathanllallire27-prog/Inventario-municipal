# 🔄 Configuración de Servicios en Segundo Plano

## PostgreSQL (Base de Datos)

### ✅ Estado Actual

Tu PostgreSQL ya está configurado como servicio de Windows y se inicia automáticamente.

**Servicio**: `postgresql-x64-18`

### Comandos PowerShell

```powershell
# Ver estado
Get-Service -Name postgresql-x64-18

# Iniciar servicio
Start-Service -Name postgresql-x64-18

# Detener servicio
Stop-Service -Name postgresql-x64-18

# Reiniciar servicio
Restart-Service -Name postgresql-x64-18

# Configurar inicio automático
Set-Service -Name postgresql-x64-18 -StartupType Automatic
```

---

## Node.js Backend (Servidor API)

### Opción 1: PM2 (Recomendado)

PM2 es un gestor de procesos para Node.js que mantiene tu aplicación corriendo en segundo plano.

#### Instalación

```bash
npm install -g pm2
```

#### Uso Básico

```bash
# Iniciar el servidor
pm2 start src/index.js --name inventario-backend

# Ver procesos activos
pm2 list

# Ver logs en tiempo real
pm2 logs inventario-backend

# Detener el servidor
pm2 stop inventario-backend

# Reiniciar el servidor
pm2 restart inventario-backend

# Eliminar del PM2
pm2 delete inventario-backend
```

#### Uso con archivo de configuración (ecosystem.config.js)

```bash
# Iniciar con configuración
pm2 start ecosystem.config.js

# Guardar configuración para que se inicie automáticamente
pm2 save
```

#### Configurar inicio automático en Windows

**IMPORTANTE**: En Windows, `pm2 startup` NO funciona. Usa `pm2-windows-startup` en su lugar:

```bash
# 1. Instalar pm2-windows-startup
npm install -g pm2-windows-startup

# 2. Instalar el script de inicio
pm2-startup install

# 3. Verificar que PM2 se inicie automáticamente
# Reinicia tu PC y ejecuta:
pm2 list
```

**Desinstalar el inicio automático** (si lo necesitas):

```bash
pm2-startup uninstall
```

#### Comandos útiles de PM2

```bash
# Ver estado detallado
pm2 status

# Monitorear recursos
pm2 monit

# Ver logs
pm2 logs

# Limpiar logs
pm2 flush

# Recargar sin downtime
pm2 reload inventario-backend
```

### Opción 2: NSSM (Non-Sucking Service Manager)

Convierte tu aplicación Node.js en un servicio de Windows nativo.

#### Instalación

1. Descarga NSSM desde: https://nssm.cc/download
2. Extrae el archivo ZIP
3. Copia `nssm.exe` a una carpeta en tu PATH (ej: `C:\Windows\System32`)

#### Crear el servicio

```powershell
# Abrir el instalador GUI
nssm install InventarioBackend

# O crear desde línea de comandos
nssm install InventarioBackend "C:\Program Files\nodejs\node.exe" "D:\Jonathan\UNSCH\Practicas_pre_profesionales\APP\backend\src\index.js"
nssm set InventarioBackend AppDirectory "D:\Jonathan\UNSCH\Practicas_pre_profesionales\APP\backend"
nssm set InventarioBackend AppEnvironmentExtra NODE_ENV=production
```

#### Gestionar el servicio

```powershell
# Iniciar
nssm start InventarioBackend

# Detener
nssm stop InventarioBackend

# Reiniciar
nssm restart InventarioBackend

# Eliminar
nssm remove InventarioBackend confirm
```

### Opción 3: Windows Task Scheduler

Crear una tarea programada que inicie el servidor al arrancar Windows.

1. Abre el Programador de tareas (`taskschd.msc`)
2. Crear tarea básica
3. Nombre: "Inventario Backend"
4. Desencadenador: "Al iniciar el equipo"
5. Acción: "Iniciar un programa"
6. Programa: `C:\Program Files\nodejs\node.exe`
7. Argumentos: `src\index.js`
8. Directorio: `D:\Jonathan\UNSCH\Practicas_pre_profesionales\APP\backend`

---

## 🎯 Recomendación

Para tu caso, te recomiendo usar **PM2** porque:

- ✅ Fácil de instalar y usar
- ✅ Auto-reinicio si la app falla
- ✅ Gestión de logs integrada
- ✅ Monitoreo de recursos
- ✅ Puede ejecutar múltiples instancias
- ✅ Compatible con desarrollo y producción

### Pasos rápidos con PM2 (Windows):

```bash
# 1. Instalar PM2 globalmente
npm install -g pm2

# 2. Instalar pm2-windows-startup
npm install -g pm2-windows-startup

# 3. Ir al directorio del backend
cd backend

# 4. Iniciar con el archivo de configuración
pm2 start ecosystem.config.js

# 5. Guardar la configuración
pm2 save

# 6. Configurar inicio automático con Windows
pm2-startup install

# 7. Verificar que está corriendo
pm2 list
```

¡Listo! Ahora tanto PostgreSQL como tu backend estarán corriendo automáticamente en segundo plano.
