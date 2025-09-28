import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/reporte_model.dart';

class GeoJsonService {
  // Cargar el archivo GeoJSON de Nicaragua (nivel 2: municipios)
  static Future<List<MunicipioData>> cargarMunicipiosNicaragua() async {
    try {
      // Leer el archivo GeoJSON
      final String geoJsonString = await rootBundle.loadString('assets/gadm41_NIC_2.json');
      final Map<String, dynamic> geoJson = json.decode(geoJsonString);
      
      // Lista para almacenar los municipios
      final List<MunicipioData> municipios = [];
      
      // Procesar las características (features) del GeoJSON
      final List<dynamic> features = geoJson['features'];
      
      for (var feature in features) {
        final properties = feature['properties'];
        final geometry = feature['geometry'];
        
        // Obtener el nombre del municipio y departamento
        final String municipioId = properties['GID_2'] ?? '';
        final String municipioNombre = properties['NAME_2'] ?? '';
        final String departamentoNombre = properties['NAME_1'] ?? '';
        final String departamentoId = properties['GID_1'] ?? '';
        
        // Procesar la geometría para obtener el polígono
        final List<List<Offset>> poligonos = [];
        
        if (geometry['type'] == 'MultiPolygon') {
          final List<dynamic> multiPolygon = geometry['coordinates'];
          
          for (var polygon in multiPolygon) {
            for (var ring in polygon) {
              final List<Offset> poligono = [];
              
              for (var coord in ring) {
                // Las coordenadas están en formato [longitud, latitud]
                final double lon = (coord[0] as double);
                final double lat = (coord[1] as double);
                
                // Convertir coordenadas geográficas a coordenadas relativas para dibujar
                // Este es un cálculo simplificado, se puede mejorar con una proyección adecuada
                final double x = (lon + 88) / 10; // Normalizar longitud a [0,1]
                final double y = (17 - lat) / 10; // Normalizar latitud a [0,1]
                
                poligono.add(Offset(x, y));
              }
              
              if (poligono.isNotEmpty) {
                poligonos.add(poligono);
              }
            }
          }
        }
        
        // Calcular el centro aproximado del municipio (promedio de coordenadas)
        Offset centro = Offset.zero;
        int totalPuntos = 0;
        
        for (var poligono in poligonos) {
          for (var punto in poligono) {
            centro += punto;
            totalPuntos++;
          }
        }
        
        if (totalPuntos > 0) {
          centro = Offset(centro.dx / totalPuntos, centro.dy / totalPuntos);
        } else {
          // Centro predeterminado si no hay puntos
          centro = const Offset(0.5, 0.5);
        }
        
        // Crear el objeto MunicipioData
        final municipio = MunicipioData(
          id: municipioId,
          nombre: municipioNombre,
          departamento: departamentoNombre,
          departamentoId: departamentoId,
          poligonos: poligonos,
          centro: centro,
        );
        
        municipios.add(municipio);
      }
      
      return municipios;
    } catch (e) {
      debugPrint('Error al cargar el GeoJSON: $e');
      return [];
    }
  }
  
  // Agrupar municipios por departamento
  static Future<List<DepartamentoGeoData>> cargarDepartamentosNicaragua() async {
    try {
      // Obtener todos los municipios
      final municipios = await cargarMunicipiosNicaragua();
      
      // Mapa para agrupar municipios por departamento
      final Map<String, List<MunicipioData>> municipiosPorDepartamento = {};
      
      // Lista para almacenar elementos especiales (lagos, etc.)
      final List<MunicipioData> elementosEspeciales = [];
      
      // Agrupar municipios por departamento y separar elementos especiales
      for (var municipio in municipios) {
        // Verificar si es un lago u otro elemento especial
        if (municipio.nombre.toLowerCase().contains('lago') || 
            municipio.nombre.toLowerCase().contains('laguna') || 
            municipio.nombre.toLowerCase().contains('water')) {
          elementosEspeciales.add(municipio);
        } else {
          if (!municipiosPorDepartamento.containsKey(municipio.departamentoId)) {
            municipiosPorDepartamento[municipio.departamentoId] = [];
          }
          municipiosPorDepartamento[municipio.departamentoId]!.add(municipio);
        }
      }
      
      // Crear lista de departamentos
      final List<DepartamentoGeoData> departamentos = [];
      
      // Procesar cada departamento
      municipiosPorDepartamento.forEach((departamentoId, municipiosDelDepartamento) {
        if (municipiosDelDepartamento.isEmpty) return;
        
        // Obtener nombre del departamento del primer municipio
        final departamentoNombre = municipiosDelDepartamento.first.departamento;
        
        // Unir todos los polígonos de los municipios
        final List<List<Offset>> todosLosPoligonos = [];
        for (var municipio in municipiosDelDepartamento) {
          todosLosPoligonos.addAll(municipio.poligonos);
        }
        
        // Calcular el centro aproximado del departamento (promedio de centros de municipios)
        Offset centro = Offset.zero;
        for (var municipio in municipiosDelDepartamento) {
          centro += municipio.centro;
        }
        centro = Offset(
          centro.dx / municipiosDelDepartamento.length,
          centro.dy / municipiosDelDepartamento.length,
        );
        
        // Crear objeto DepartamentoGeoData
        final departamento = DepartamentoGeoData(
          id: departamentoId,
          nombre: departamentoNombre,
          poligonos: todosLosPoligonos,
          centro: centro,
          municipios: municipiosDelDepartamento,
          esElementoEspecial: false,
        );
        
        departamentos.add(departamento);
      });
      
      // Agregar elementos especiales como lagos
      for (var elemento in elementosEspeciales) {
        final departamento = DepartamentoGeoData(
          id: elemento.id,
          nombre: elemento.nombre,
          poligonos: elemento.poligonos,
          centro: elemento.centro,
          municipios: [elemento],
          esElementoEspecial: true,
        );
        
        departamentos.add(departamento);
      }
      
      return departamentos;
    } catch (e) {
      debugPrint('Error al agrupar departamentos: $e');
      return [];
    }
  }
}