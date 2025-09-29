# AgroDoctor

AgroDoctor es una aplicación móvil y web desarrollada con Flutter que ayuda a los agricultores a diagnosticar enfermedades en cultivos mediante inteligencia artificial, gestionar casos de diagnóstico y acceder a un marketplace de productos agrícolas.

![Logo AgroDoctor](assets/logo.png)

## Características Principales

- **Diagnóstico Inteligente**: Identifica enfermedades en cultivos mediante análisis de imágenes con IA
- **Gestión de Casos**: Sistema completo para crear, gestionar y hacer seguimiento de casos de diagnóstico
- **Marketplace Agrícola**: Plataforma para comprar productos agrícolas especializados
- **Mapas Georreferenciados**: Visualización de ubicaciones de cultivos y diagnósticos
- **Reportes y Estadísticas**: Seguimiento de diagnósticos y tratamientos
- **Autenticación Segura**: Registro y login con email/password o Google Sign-In
- **Panel de Administración**: Gestión completa de usuarios, casos y diagnósticos

## Funcionalidades Detalladas

### 🔬 Diagnóstico de Enfermedades
- **Proceso Guiado**: Wizard paso a paso para realizar diagnósticos
- **Análisis por IA**: Identificación automática de enfermedades comunes
- **Información Detallada**: Nivel de confianza, recomendaciones y tratamientos
- **Creación Automática de Casos**: Cada diagnóstico genera automáticamente un caso de seguimiento

### 📋 Gestión de Casos
- **Casos Activos**: Seguimiento de diagnósticos en curso
- **Historial Completo**: Acceso a todos los casos realizados
- **Detalles Completos**: Información del diagnóstico, imágenes, ubicación y recomendaciones
- **Estados de Caso**: Activo, cerrado, en proceso

### 🛒 Marketplace Agrícola
- **Productos Especializados**: Insecticidas, fertilizantes, herramientas, semillas
- **Búsqueda Avanzada**: Filtros por categoría, precio y disponibilidad
- **Información Detallada**: Descripciones, precios, disponibilidad y contactos

### 🗺️ Mapas y Geolocalización
- **Ubicación Automática**: Detección de ubicación para diagnósticos
- **Mapas Interactivos**: Visualización de cultivos y áreas afectadas
- **Estadísticas Regionales**: Análisis de enfermedades por zona geográfica

### 👤 Gestión de Usuarios
- **Autenticación Múltiple**: Email/password y Google Sign-In
- **Perfil de Usuario**: Información personal y configuración
- **Historial Personal**: Acceso a diagnósticos y casos propios

### 🔧 Panel de Administración
- **Gestión de Usuarios**: Lista completa de usuarios registrados
- **Administración de Casos**: Visualización y gestión de todos los casos
- **Estadísticas del Sistema**: Métricas de uso y diagnósticos

## Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión ^3.9.2)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli) (para configuración de Firebase)
- [Git](https://git-scm.com/downloads)
- Un IDE como [Visual Studio Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio)

## Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/usuario/AgroDoctor.git
cd AgroDoctor
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agrega aplicaciones (Android, iOS, Web) a tu proyecto Firebase
3. Descarga los archivos de configuración:
   - `google-services.json` para Android (colócalo en `android/app/`)
   - `GoogleService-Info.plist` para iOS (colócalo en `ios/Runner/`)
   - Configuración web (actualiza `lib/services/firebase_options.dart`)

4. Habilita los servicios necesarios en Firebase:
   - Authentication (Email/Password y Google)
   - Cloud Firestore
   - Storage

5. Configura las reglas de Firestore en `firestore.rules`
6. Crea los índices necesarios en `firestore.indexes.json`

### 4. Configurar API de Google Maps

1. Obtén una clave de API de Google Maps en [Google Cloud Console](https://console.cloud.google.com/)
2. Configura la clave en:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`
   - Web: Actualiza el script en `web/index.html`

### 5. Ejecutar la Aplicación

```bash
# Para ejecutar en modo debug
flutter run

# Para compilar para web
flutter build web

# Para compilar para Android
flutter build apk
```

## Estructura del Proyecto

```
lib/
├── constants/         # Constantes de la aplicación (colores, temas)
├── models/            # Modelos de datos (casos, diagnósticos, usuarios)
├── providers/         # Gestión de estado con Provider
├── screens/           # Pantallas de la aplicación
│   ├── diagnostico_wizard.dart      # Wizard de diagnóstico
│   ├── diagnostico_results_page.dart # Lista de casos
│   ├── caso_detail_page.dart        # Detalle de caso
│   ├── casos_page.dart              # Página de casos
│   ├── admin_panel_page.dart        # Panel de administración
│   └── ...
├── services/          # Servicios (Firebase, APIs)
│   ├── auth_service.dart            # Autenticación
│   ├── caso_diagnostico_service.dart # Gestión de casos
│   └── ...
├── utils/             # Utilidades y helpers
├── widgets/           # Widgets reutilizables
└── main.dart          # Punto de entrada de la aplicación
```

## Flujo de Uso

### Para Agricultores

1. **Registro/Login**: Crear cuenta o iniciar sesión
2. **Realizar Diagnóstico**: 
   - Tomar foto del cultivo
   - Proporcionar información adicional
   - Obtener diagnóstico automático
3. **Gestionar Casos**: 
   - Ver casos activos en la página principal
   - Acceder al detalle de cada caso
   - Seguir recomendaciones
4. **Comprar Productos**: 
   - Navegar por el marketplace
   - Buscar productos específicos
   - Contactar proveedores

### Para Administradores

1. **Acceso al Panel**: Ir a "Mi Perfil" → "Panel de Administración"
2. **Gestión de Usuarios**: Ver lista completa de usuarios registrados
3. **Administración de Casos**: Revisar todos los casos del sistema
4. **Estadísticas**: Analizar métricas de uso y diagnósticos

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Firebase**: Backend como servicio (Auth, Firestore, Storage)
- **Provider**: Gestión de estado
- **Google Maps**: Mapas y geolocalización
- **Inteligencia Artificial**: Modelo de diagnóstico de enfermedades

## Despliegue

### Web

La aplicación web puede desplegarse en Firebase Hosting:

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Iniciar sesión en Firebase
firebase login

# Inicializar el proyecto
firebase init

# Compilar la aplicación web
flutter build web

# Desplegar a Firebase Hosting
firebase deploy --only hosting
```

### Android

Para generar un APK firmado para distribución:

```bash
flutter build apk --release
```

El APK se generará en `build/app/outputs/flutter-apk/app-release.apk`

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Soporte

Para soporte técnico o consultas sobre el proyecto, puedes:
- Abrir un issue en el repositorio
- Contactar al equipo de desarrollo

---

**AgroDoctor** - Transformando la agricultura con tecnología e inteligencia artificial.