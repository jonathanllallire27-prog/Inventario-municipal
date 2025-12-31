# 🏛️ Backend - Sistema de Inventario Municipal

Backend API REST para el Sistema de Inventario de la Municipalidad de San Juan Bautista.

## 🚀 Tecnologías

- **Node.js** - Runtime de JavaScript
- **Express.js** - Framework web
- **PostgreSQL** - Base de datos relacional
- **JWT** - Autenticación con tokens
- **bcryptjs** - Encriptación de contraseñas

## 📋 Requisitos Previos

1. **Node.js** (v18 o superior)
2. **PostgreSQL** (v14 o superior)
3. **npm** o **yarn**

## ⚙️ Instalación

### 1. Instalar dependencias

```bash
cd backend
npm install
```

### 2. Configurar la base de datos PostgreSQL

Crear la base de datos:

```sql
CREATE DATABASE inventario_municipal;
```

### 3. Configurar variables de entorno

Editar el archivo `.env` con tus credenciales:

```env
# Configuración del Servidor
PORT=3000
NODE_ENV=development

# Configuración de PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=inventario_municipal
DB_USER=postgres
DB_PASSWORD=tu_password_aqui

# JWT Secret Key
JWT_SECRET=tu_clave_secreta_muy_segura_aqui_123456
JWT_EXPIRES_IN=24h
```

### 4. Iniciar el servidor

**Modo desarrollo (con auto-reload):**

```bash
npm run dev
```

**Modo producción:**

```bash
npm start
```

El servidor iniciará en `http://localhost:3000`

## 📡 Endpoints de la API

### Autenticación

| Método | Endpoint             | Descripción       |
| ------ | -------------------- | ----------------- |
| POST   | `/api/auth/login`    | Iniciar sesión    |
| POST   | `/api/auth/register` | Registrar usuario |
| GET    | `/api/auth/verify`   | Verificar token   |

### Equipos

| Método | Endpoint                    | Descripción          | Auth     |
| ------ | --------------------------- | -------------------- | -------- |
| GET    | `/api/equipos`              | Listar equipos       | ❌       |
| GET    | `/api/equipos/estadisticas` | Obtener estadísticas | ❌       |
| GET    | `/api/equipos/oficinas`     | Listar oficinas      | ❌       |
| GET    | `/api/equipos/:id`          | Obtener equipo       | ❌       |
| POST   | `/api/equipos`              | Crear equipo         | ✅ Admin |
| PUT    | `/api/equipos/:id`          | Actualizar equipo    | ✅ Admin |
| DELETE | `/api/equipos/:id`          | Eliminar equipo      | ✅ Admin |

### Parámetros de consulta (GET /api/equipos)

- `oficina` - Filtrar por oficina
- `tipo` - Filtrar por tipo (PC, LAPTOP, SERVIDOR)
- `estado` - Filtrar por estado (BUENO, REGULAR, MALO)
- `search` - Búsqueda general

## 🔐 Autenticación

La API usa JWT (JSON Web Tokens). Para endpoints protegidos, incluir el token en el header:

```
Authorization: Bearer <tu_token>
```

### Usuario por defecto

```
Usuario: admin
Contraseña: admin123
Rol: admin
```

## 📊 Estructura del Proyecto

```
backend/
├── src/
│   ├── config/
│   │   ├── database.js    # Conexión PostgreSQL
│   │   └── init.js        # Inicialización de tablas
│   ├── middleware/
│   │   └── auth.js        # Middleware de autenticación
│   ├── routes/
│   │   ├── auth.js        # Rutas de autenticación
│   │   └── equipos.js     # Rutas de equipos
│   └── index.js           # Punto de entrada
├── .env                   # Variables de entorno
├── .gitignore
├── package.json
└── README.md
```

## 🔗 Conexión Flutter

Para conectar desde Flutter, usar el servicio `ApiService`:

```dart
import 'services/api_service.dart';

// Configurar la URL base según el entorno:
// - Emulador Android: 10.0.2.2:3000
// - Dispositivo físico: IP de tu PC (ej: 182.18.8.7:3000)
// - iOS Simulator: localhost:3000
```

## 📝 Ejemplos de Peticiones

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

### Obtener equipos

```bash
curl http://localhost:3000/api/equipos
```

### Crear equipo (requiere autenticación)

```bash
curl -X POST http://localhost:3000/api/equipos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <tu_token>" \
  -d '{
    "numero": "100",
    "oficina": "CATASTRO",
    "tipo": "PC",
    "microprocesador": "Intel Core i7",
    "sistema_operativo": "Windows 11",
    "marca": "HP",
    "memoria_ram": "16 GB",
    "disco_duro": "512 GB SSD",
    "estado": "BUENO",
    "monitor": "HP 24",
    "sede": "PRINCIPAL",
    "escaner": "NO",
    "impresoras": "",
    "ip": "192.168.1.100"
  }'
```

## 🛠️ Desarrollo

```bash
# Ejecutar en modo desarrollo
npm run dev

# Ver logs en tiempo real
# El servidor mostrará todos los requests en la consola
```

## 📄 Licencia

ISC

---

Desarrollado para la Municipalidad de San Juan Bautista 🏛️
