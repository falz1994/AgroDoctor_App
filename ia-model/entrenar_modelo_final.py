import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
import os


RESOLUCION = 256
NUMERO_EPOCH = 20

# Esta es la ruta a tu carpeta principal de imágenes
ruta_base = 'E:/entrenamiento de doctor de cultivo de frijol/partes del frijol'


datagen = ImageDataGenerator(
    rescale=1./255,            
    validation_split=0.2       
)

print("Cargando imágenes de entrenamiento...")
generador_entrenamiento = datagen.flow_from_directory(
    ruta_base,
    target_size=(RESOLUCION, RESOLUCION),
    batch_size=32,
    class_mode='categorical',
    subset='training'
)

print("Cargando imágenes de validación...")
generador_validacion = datagen.flow_from_directory(
    ruta_base,
    target_size=(RESOLUCION, RESOLUCION),
    batch_size=32,
    class_mode='categorical',
    subset='validation'
)
modelo = Sequential([
    Conv2D(32, (3, 3), activation='relu', input_shape=(RESOLUCION, RESOLUCION, 3)),
    MaxPooling2D((2, 2)),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Conv2D(128, (3, 3), activation='relu'),
    MaxPooling2D((2, 2)),
    Flatten(),
    Dense(128, activation='relu'),
    Dense(generador_entrenamiento.num_classes, activation='softmax')
])

modelo.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)
print("\nIniciando entrenamiento. Esto puede tardar un poco...")
historial = modelo.fit(
    generador_entrenamiento,
    epochs=NUMERO_EPOCH,
    validation_data=generador_validacion
)
nombre_archivo_modelo = f'modelo_final_partes_planta_v{NUMERO_EPOCH}.h5'
modelo.save(nombre_archivo_modelo)
print(f"\nModelo guardado exitosamente como {nombre_archivo_modelo}")