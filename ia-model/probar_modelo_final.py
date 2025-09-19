import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
import os

# Cargar el modelo
nombre_modelo = 'modelo_final_partes_planta_v20.h5'
modelo_cargado = tf.keras.models.load_model(nombre_modelo)

# Nombres de las categorías
nombres_clases = ['fondo no necesario', 'hoja', 'tallo y planta', 'vaina']

# Cargar una imagen de prueba
ruta_de_imagen = 'una-hoja-de-frijol-verde-fresco-venado-al-sol-toma-cierre-181823976.webp'

img = image.load_img(ruta_de_imagen, target_size=(256, 256))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0) 
img_array = img_array / 255.0 


predicciones = modelo_cargado.predict(img_array)

indice_prediccion = np.argmax(predicciones)
nombre_clase_predicha = nombres_clases[indice_prediccion]
confianza = np.max(predicciones) * 100

print("Resultados de la predicción:")
for i, clase in enumerate(nombres_clases):
    print(f"  {clase}: {predicciones[0][i]*100:.2f}%")

print(f"\nLa IA predice que esta imagen es de: {nombre_clase_predicha}")
print(f"Confianza: {confianza:.2f}%")