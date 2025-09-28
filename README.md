# AgroDoctor

AgroDoctor es una aplicación móvil y web desarrollada con Flutter que ayuda a los agricultores a diagnosticar enfermedades en cultivos, acceder a un marketplace de productos agrícolas, y gestionar información sobre sus cultivos.

![Logo AgroDoctor](assets/logo.png)

## Características Principales

- **Diagnóstico de Enfermedades**: Identifica enfermedades en cultivos mediante análisis de imágenes con IA
- **Marketplace Agrícola**: Plataforma para comprar y vender productos agrícolas
- **Mapas Georreferenciados**: Visualización de cultivos y áreas afectadas
- **Reportes y Estadísticas**: Seguimiento de diagnósticos y tratamientos
- **Autenticación de Usuarios**: Registro y login con email o cuenta de Google

## Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versión ^3.9.2)
- [Dart SDK](https://dart.dev/get-dart) (incluido con Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli) (para configuración de Firebase)
- [Git](https://git-scm.com/downloads)
- Un IDE como [Visual Studio Code](https://code.visualstudio.com/) o [Android Studio](https://developer.android.com/studio)

## Instalación

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/agrodoctor.git
cd agrodoctor
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
├── models/            # Modelos de datos
├── providers/         # Gestión de estado con Provider
├── screens/           # Pantallas de la aplicación
├── services/          # Servicios (Firebase, APIs)
├── utils/             # Utilidades y helpers
├── widgets/           # Widgets reutilizables
└── main.dart          # Punto de entrada de la aplicación
```

## Características Principales en Detalle

### Diagnóstico de Enfermedades

La aplicación permite a los usuarios tomar o seleccionar fotos de sus cultivos para analizar y diagnosticar posibles enfermedades. Utiliza un modelo de IA entrenado específicamente para identificar enfermedades comunes en cultivos de la región centroamericana.

### Marketplace Agrícola

Plataforma donde agricultores y proveedores pueden publicar y buscar productos relacionados con la agricultura, como:
- Insecticidas
- Fertilizantes
- Herramientas
- Semillas
- Maquinaria

### Mapas y Geolocalización

Visualización de mapas con datos georreferenciados de:
- Ubicación de cultivos
- Áreas afectadas por enfermedades
- Estadísticas regionales

## Despliegue

### Web

La aplicación web puede desplegarse en Firebase Hosting:

```bash
# Instalar Firebase CLI si aún no está instalado
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

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo LICENSE para más detalles.

## Contacto

Para preguntas o soporte, contacta a [tu-email@ejemplo.com](mailto:tu-email@ejemplo.com)