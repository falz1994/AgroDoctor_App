# Solución de problemas de conexión con Firebase

Este documento proporciona instrucciones para solucionar problemas comunes de conexión con Firebase en la aplicación AgroDoctor.

## Verificación de la conexión

Hemos añadido un botón "Probar conexión con Firebase" en la pantalla de casos cuando no hay casos guardados. Este botón te permitirá verificar si la aplicación puede conectarse correctamente a Firebase.

## Problemas comunes y soluciones

### 1. Los casos no se guardan en Firebase

Si los diagnósticos se realizan correctamente pero los casos no se guardan en Firebase, verifica lo siguiente:

#### Autenticación

- Asegúrate de que estás autenticado en la aplicación.
- Verifica que el usuario tiene un ID válido (el botón de prueba de conexión mostrará esta información).
- Cierra sesión y vuelve a iniciar sesión para refrescar el token de autenticación.

#### Reglas de seguridad de Firestore

Las reglas de seguridad de Firestore deben permitir la escritura en la colección `casos_diagnostico`. Verifica que las reglas de seguridad en la consola de Firebase sean similares a las proporcionadas en el archivo `firestore.rules` en este proyecto.

#### Estructura de datos

- La colección `casos_diagnostico` debe existir en Firestore.
- Cada documento en esta colección debe tener un campo `userId` que coincida con el ID del usuario autenticado.

### 2. Errores en la consola del navegador

Si estás ejecutando la aplicación en modo web, verifica la consola del navegador para detectar errores relacionados con Firebase:

- Errores de CORS: Asegúrate de que el dominio desde el que accedes a la aplicación esté permitido en la configuración de Firebase.
- Errores de autenticación: Verifica que las credenciales de Firebase estén correctamente configuradas.

### 3. Problemas de inicialización de Firebase

Verifica que Firebase se inicialice correctamente:

```dart
// En main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AgroDoctorApp());
}
```

### 4. Logs de depuración

Hemos añadido logs de depuración extensivos en las funciones relacionadas con Firebase. Para ver estos logs:

- En web: Abre la consola del navegador (F12 > Consola).
- En Android: Ejecuta `flutter run --verbose` y observa los logs en la terminal.
- En iOS: Usa Xcode para ver los logs de la aplicación.

### 5. Verificación de la configuración de Firebase

Asegúrate de que los archivos de configuración de Firebase estén correctamente configurados:

- `firebase_options.dart`: Debe contener las credenciales correctas para cada plataforma.
- `google-services.json`: Para Android, debe estar en la carpeta `android/app/`.
- `GoogleService-Info.plist`: Para iOS, debe estar en la carpeta `ios/Runner/`.
- Para web, la configuración debe estar correctamente establecida en `index.html`.

## Pasos para subir las reglas de seguridad a Firebase

1. Asegúrate de tener instalado Firebase CLI: `npm install -g firebase-tools`
2. Inicia sesión en Firebase: `firebase login`
3. Selecciona tu proyecto: `firebase use --add` y sigue las instrucciones
4. Sube las reglas: `firebase deploy --only firestore:rules`

## Contacto para soporte

Si continúas experimentando problemas después de seguir estas instrucciones, contacta al equipo de desarrollo para obtener asistencia adicional.
