# Instrucciones Manuales para Desplegar las Reglas de Firestore

## Problema con Firebase CLI

Si Firebase CLI no se puede instalar o ejecutar correctamente, puedes desplegar las reglas manualmente desde la consola de Firebase.

## Pasos para desplegar manualmente:

### 1. Acceder a la Consola de Firebase

1. Ve a [https://console.firebase.google.com](https://console.firebase.google.com)
2. Inicia sesión con tu cuenta de Google
3. Selecciona el proyecto `agrodoctor-77245`

### 2. Ir a Firestore Database

1. En el menú lateral izquierdo, haz clic en **"Firestore Database"**
2. Haz clic en la pestaña **"Reglas"** (Rules)

### 3. Reemplazar las reglas existentes

Copia y pega el siguiente código en el editor de reglas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas básicas de seguridad para la aplicación AgroDoctor
    
    // Función para verificar si el usuario está autenticado
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Función para verificar si el documento pertenece al usuario actual
    function isOwner(resource) {
      return resource.data.userId == request.auth.uid;
    }
    
    // Función para verificar si los datos a escribir contienen el userId correcto
    function hasValidUserId() {
      return request.resource.data.userId == request.auth.uid;
    }
    
    // Regla para la colección de casos_diagnostico
    match /casos_diagnostico/{casoId} {
      // Permitir lectura si el usuario está autenticado y es el propietario
      allow read: if isAuthenticated() && isOwner(resource);
      
      // Permitir escritura si el usuario está autenticado y los datos contienen su userId
      allow create: if isAuthenticated() && hasValidUserId();
      
      // Permitir actualización si el usuario está autenticado y es el propietario
      allow update: if isAuthenticated() && isOwner(resource) && hasValidUserId();
      
      // Permitir eliminación si el usuario está autenticado y es el propietario
      allow delete: if isAuthenticated() && isOwner(resource);
      
      // Reglas para la subcolección de logs (si existe)
      match /logs/{logId} {
        allow read: if isAuthenticated() && get(/databases/$(database)/documents/casos_diagnostico/$(casoId)).data.userId == request.auth.uid;
        allow write: if isAuthenticated() && get(/databases/$(database)/documents/casos_diagnostico/$(casoId)).data.userId == request.auth.uid;
      }
    }
    
    // Regla para la colección de diagnosticos
    match /diagnosticos/{diagnosticoId} {
      // Permitir lectura si el usuario está autenticado y es el propietario
      allow read: if isAuthenticated() && isOwner(resource);
      
      // Permitir escritura si el usuario está autenticado y los datos contienen su userId
      allow create: if isAuthenticated() && hasValidUserId();
      
      // Permitir actualización si el usuario está autenticado y es el propietario
      allow update: if isAuthenticated() && isOwner(resource);
      
      // Permitir eliminación si el usuario está autenticado y es el propietario
      allow delete: if isAuthenticated() && isOwner(resource);
    }
    
    // Regla para la colección de users
    match /users/{userId} {
      // Permitir lectura si el usuario está autenticado y es el propietario
      allow read: if isAuthenticated() && (resource.data.uid == request.auth.uid || request.auth.uid == resource.data.uid);
      
      // Permitir escritura si el usuario está autenticado y es el propietario
      allow write: if isAuthenticated() && (request.resource.data.uid == request.auth.uid || request.auth.uid == request.resource.data.uid);
      
      // Permitir lectura para administradores (todos los usuarios autenticados pueden ver todos los usuarios)
      allow read: if isAuthenticated();
    }
    
    // Regla para la colección de test_connection (usada para pruebas)
    match /test_connection/{docId} {
      // Permitir operaciones si el usuario está autenticado
      allow read, write: if isAuthenticated();
    }
    
    // Denegar acceso a todas las demás colecciones por defecto
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 4. Publicar las reglas

1. Haz clic en el botón **"Publicar"** (Publish)
2. Espera a que se confirme que las reglas se han publicado correctamente

### 5. Verificar que las reglas se aplicaron

1. Ve a la pestaña **"Datos"** (Data) en Firestore
2. Verifica que puedas ver las colecciones existentes
3. Intenta crear un documento de prueba para verificar los permisos

## Verificación de la solución

Después de aplicar las reglas:

1. **Registra un nuevo usuario** en tu aplicación Flutter
2. **Verifica en Firestore** que el usuario aparezca en la colección `users`
3. **Accede al panel de administración** y verifica que los usuarios se muestren

## Estructura esperada de la colección `users`

Los usuarios deberían aparecer con esta estructura:

```json
{
  "uid": "user_id_from_auth",
  "displayName": "Nombre del usuario",
  "email": "usuario@ejemplo.com",
  "photoURL": "url_de_la_foto",
  "phoneNumber": "número_de_teléfono",
  "emailVerified": true/false,
  "createdAt": "timestamp",
  "lastSignIn": "timestamp"
}
```

## Solución de problemas

### Si las reglas no se aplican:
- Verifica que hayas copiado todo el código correctamente
- Asegúrate de hacer clic en "Publicar"
- Espera unos minutos para que los cambios se propaguen

### Si los usuarios aún no aparecen:
- Verifica que el código de autenticación se haya actualizado correctamente
- Revisa los logs en la consola del navegador (F12)
- Asegúrate de que el usuario esté autenticado antes de acceder al panel de admin

## Notas importantes

- Los usuarios existentes que se registraron antes de esta corrección no aparecerán hasta que inicien sesión nuevamente
- Los nuevos usuarios se guardarán automáticamente en Firestore
- El panel de administración ahora tendrá acceso completo a la colección `users`
