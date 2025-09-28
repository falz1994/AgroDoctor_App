import os
import sys
from pathlib import Path

def get_size_in_mb(file_path):
    """Retorna el tamaño del archivo en MB"""
    size_bytes = os.path.getsize(file_path)
    size_mb = size_bytes / (1024 * 1024)
    return size_mb

def find_large_files(directory, min_size_mb=1):
    """Encuentra archivos más grandes que min_size_mb en el directorio especificado"""
    large_files = []
    
    # Convertir a objeto Path para manejar rutas correctamente
    dir_path = Path(directory)
    
    # Verificar que el directorio existe
    if not dir_path.exists() or not dir_path.is_dir():
        print(f"El directorio {directory} no existe o no es un directorio")
        return []
    
    # Recorrer todos los archivos en el directorio y subdirectorios
    for root, _, files in os.walk(dir_path):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                size_mb = get_size_in_mb(file_path)
                if size_mb >= min_size_mb:
                    large_files.append((file_path, size_mb))
            except Exception as e:
                print(f"Error al procesar {file_path}: {e}")
    
    # Ordenar por tamaño (de mayor a menor)
    large_files.sort(key=lambda x: x[1], reverse=True)
    return large_files

def main():
    # Directorio a escanear (por defecto '.' - directorio actual)
    directory = '.'
    if len(sys.argv) > 1:
        directory = sys.argv[1]
    
    # Tamaño mínimo en MB (por defecto 1MB)
    min_size = 1
    if len(sys.argv) > 2:
        min_size = float(sys.argv[2])
    
    print(f"Buscando archivos mayores a {min_size} MB en {directory}...")
    large_files = find_large_files(directory, min_size)
    
    if not large_files:
        print(f"No se encontraron archivos mayores a {min_size} MB")
        return
    
    print(f"\nArchivos encontrados: {len(large_files)}")
    print("\nRuta del archivo                                    | Tamaño (MB)")
    print("-" * 70)
    
    for file_path, size in large_files:
        print(f"{file_path:<50} | {size:.2f} MB")
    
    # Generar contenido para .gitignore
    print("\n\nAgregar al .gitignore:")
    print("-" * 30)
    for file_path, _ in large_files:
        # Convertir a ruta relativa
        rel_path = os.path.relpath(file_path)
        print(f"{rel_path}")

if __name__ == "__main__":
    main()
