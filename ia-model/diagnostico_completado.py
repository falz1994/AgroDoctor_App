import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np

import os

# Obtener la ruta del directorio donde está este script
dir_actual = os.path.dirname(os.path.abspath(__file__))

# Rutas absolutas a los modelos
ruta_modelo_partes = os.path.join(dir_actual, 'modelo_final_partes_planta_v20.h5')
ruta_modelo_diagnostico = os.path.join(dir_actual, 'modelo_diagnostico_v35.h5')

modelo_partes = tf.keras.models.load_model(ruta_modelo_partes)
modelo_diagnostico = tf.keras.models.load_model(ruta_modelo_diagnostico)

clases_partes = ['fondo no necesario', 'hoja', 'tallo y planta', 'vaina']

clases_diagnostico = [
    'antracnosis hoja',
    'antracnosis tallo y planta',
    'antracnosis vaina',
    'mancha angular hoja',
    'pudricion tallo y planta',
    'roya hoja',
    'saludable hoja',
    'sana vaina',
    'sano tallo y planta'
]
mapeo_diagnostico = {
    'hoja': [
        'antracnosis hoja', 
        'mancha angular hoja', 
        'roya hoja', 
        'saludable hoja'
    ],
    'tallo y planta': [
        'antracnosis tallo y planta', 
        'pudricion tallo y planta', 
        'sano tallo y planta'
    ],
    'vaina': [
        'antracnosis vaina', 
        'sana vaina'
    ]
}


def diagnosticar_frijol(ruta_de_imagen):
    img = image.load_img(ruta_de_imagen, target_size=(256, 256))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = img_array / 255.0

    prediccion_partes = modelo_partes.predict(img_array)
    indice_parte = np.argmax(prediccion_partes)
    nombre_parte = clases_partes[indice_parte]
    
    print(f"Paso 1: La IA de Partes reconoce una: '{nombre_parte}'")

    if nombre_parte == 'fondo no necesario':
        print("Diagnóstico: La imagen es fondo. No se puede analizar.")
        return

    
    prediccion_diagnostico = modelo_diagnostico.predict(img_array)
    
    enfermedades_relevantes = mapeo_diagnostico[nombre_parte]
    
    
    predicciones_filtradas = np.zeros_like(prediccion_diagnostico[0])
    
    indices_relevantes = [clases_diagnostico.index(cls) for cls in enfermedades_relevantes]
    
    predicciones_filtradas[indices_relevantes] = prediccion_diagnostico[0, indices_relevantes]

    indice_diagnostico_final = np.argmax(predicciones_filtradas)
    nombre_diagnostico_final = clases_diagnostico[indice_diagnostico_final]
    confianza_diagnostico = np.max(predicciones_filtradas) * 100

    print("\n-------------------------------------------------")
    print(f"Diagnóstico Final: '{nombre_parte}' con '{nombre_diagnostico_final}'")
    print(f"Confianza del diagnóstico: {confianza_diagnostico:.2f}%")
    print("-------------------------------------------------")


# aqui se cambia la ruta de la imagen
ruta_imagen_prueba = r'C:\Users\DevNI\Desktop\Flutter_Proyecto\flutter_application_1\ia-model\perro.png'
diagnosticar_frijol(ruta_imagen_prueba)