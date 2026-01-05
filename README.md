# 🏛️ Sistema de Inventario Municipal - San Juan Bautista

Un sistema integral de gestión de inventario desarrollado para la **Municipalidad de San Juan Bautista**, que combina una potente API Backend con una aplicación móvil moderna y eficiente.

---

## 📱 Vista General

Este proyecto permite la gestión, seguimiento y auditoría de equipos informáticos (PCs, Laptops, Servidores, equipos de red, etc.) dentro de las diferentes sedes y oficinas de la municipalidad. El sistema ha sido diseñado para centralizar la información técnica y facilitar la toma de decisiones basada en el estado real del hardware.

### Componentes del Sistema:

1.  **Backend API**: Robusta API REST desarrollada con Node.js y PostgreSQL para la gestión centralizada de datos y autenticación segura.
2.  **App Móvil**: Aplicación multiplataforma profesional desarrollada en Flutter para el personal técnico, permitiendo la consulta y edición de equipos en campo.

---

## 🛠️ Tecnologías Utilizadas

### Backend

- **Entorno:** [Node.js](https://nodejs.org/)
- **Framework:** [Express.js](https://expressjs.com/)
- **Base de Datos:** [PostgreSQL](https://www.postgresql.org/) (Relacional)
- **Autenticación:** JSON Web Tokens (JWT) y bcryptjs para seguridad de contraseñas.
- **Gestión de Archivos:** Librería `xlsx` para la importación/exportación de reportes de inventario.

### Mobile App (Flutter)

- **Framework:** [Flutter SDK](https://flutter.dev/)
- **Lenguaje:** Dart
- **Gestión de Estado:** [Provider](https://pub.dev/packages/provider) para una arquitectura limpia.
- **Networking:** [HTTP](https://pub.dev/packages/http) para comunicación con la API.
- **Almacenamiento Local:** [Shared Preferences](https://pub.dev/packages/shared_preferences) para persistencia de sesión.

---

## 🚀 Características Principales

- 🔐 **Autenticación Multi-rol**: Inicio de sesión seguro con diferentes niveles de acceso (Admin/Usuario).
- 📊 **Dashboard de Control**: Visualización de estadísticas generales sobre el estado y tipo de equipos.
- 🔍 **Búsqueda y Filtrado Inteligente**: Filtra equipos por oficina, tipo de hardware, estado de conservación o búsqueda por texto libre.
- 📝 **Gestión de Equipos (CRUD)**: Creación, lectura, actualización y eliminación de registros detallados (Microprocesador, RAM, Disco, SO, IP, etc.).
- 📁 **Importación de Datos**: Scripts especializados para cargar inventarios existentes desde archivos Excel.
- 🎯 **Diseño Adaptativo**: UI/UX moderna optimizada para dispositivos móviles con soporte para modo claro y temas personalizados.

---

## ⚙️ Configuración e Instalación

### 1. Requisitos Previos

- [Node.js](https://nodejs.org/) (v18 o superior)
- [PostgreSQL](https://www.postgresql.org/) (v14 o superior)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Un IDE como [VS Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio)

### 2. Configuración del Backend

1. Entrar al directorio del backend:
   ```bash
   cd backend
   ```
2. Instalar las dependencias:
   ```bash
   npm install
   ```
3. Configurar variables de entorno:
   - Copia el archivo `.env.example` a un nuevo archivo llamado `.env`.
   - Completa tus credenciales de PostgreSQL y la clave secreta para JWT.
4. Inicializar la base de datos:
   - Usa el archivo `backend/database_script.sql` para crear las tablas necesarias en tu servidor PostgreSQL.
5. Iniciar el servidor:
   ```bash
   npm run dev
   ```

### 3. Configuración de la App Móvil

1. Entrar al directorio del proyecto Flutter:
   ```bash
   cd sistema_movil_inventariado
   ```
2. Instalar dependencias de Flutter:
   ```bash
   flutter pub get
   ```
3. Configurar la URL de conexión:
   - Abre `lib/services/api_service.dart`.
   - Actualiza la variable `baseUrl` con la dirección IP de tu servidor backend (ej. `http://182.18.8.176:3000/api`).
4. Ejecutar la aplicación:
   ```bash
   flutter run
   ```

---

## 📂 Estructura del Repositorio

```text
APP/
├── backend/                    # Servidor REST API (Node.js/Express)
│   ├── src/                    # Lógica de negocio, rutas y middleware
│   ├── database_script.sql     # Esquema de la base de datos
│   └── README.md               # Documentación específica del backend
├── sistema_movil_inventariado/ # Aplicación Móvil (Flutter)
│   ├── lib/                    # Pantallas, modelos, widgets y servicios
│   ├── assets/                 # Recursos visuales
│   └── pubspec.yaml            # Configuración de dependencias
└── README.md                   # Esta guía general
```

---

## 👤 Desarrollador

- **Jonathan** - _Desarrollo Full Stack_ - [Perfil de GitHub](https://github.com/tu-usuario)

## 📄 Licencia

Este proyecto es software privado desarrollado para la Municipalidad de San Juan Bautista. El uso está regido por la licencia ISC.
