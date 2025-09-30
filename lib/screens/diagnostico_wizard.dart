import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../services/diagnostico_service.dart';
import '../services/caso_diagnostico_service.dart';
import 'caso_detail_page.dart';

class DiagnosticoWizard extends StatefulWidget {
  const DiagnosticoWizard({super.key});

  @override
  State<DiagnosticoWizard> createState() => _DiagnosticoWizardState();
}

class _DiagnosticoWizardState extends State<DiagnosticoWizard> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();
  Position? _currentPosition;
  String? _currentAddress;
  String? _selectedCropStage;
  
  // Para la animación de carga
  late AnimationController _animationController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _checkAndShowInfoMessage();
  }
  
  Future<void> _checkAndShowInfoMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final dontShow = prefs.getBool('dont_show_diagnostico_info') ?? false;
    
    debugPrint('Verificando si mostrar diálogo de información: dontShow = $dontShow');
    
    if (!dontShow && mounted) {
      // Esperar un poco para asegurar que el widget esté completamente construido
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        debugPrint('Mostrando diálogo de información del diagnóstico');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildInfoDialog(),
        );
      }
    } else {
      debugPrint('No se muestra el diálogo: dontShow = $dontShow, mounted = $mounted');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnóstico de Cultivo"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => _buildInfoDialog(),
              );
            },
            tooltip: 'Ver instrucciones',
          ),
        ],
      ),
      body: _isProcessing ? _buildLoadingAnimation() : Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () async {
          debugPrint('onStepContinue llamado, paso actual: $_currentStep');
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            debugPrint('Último paso, procesando diagnóstico...');
            // Enviar diagnóstico
            await _processDiagnosis();
            debugPrint('Diagnóstico procesado');
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          Step(
            title: const Text("Ubicación y Etapa"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "La ubicación y la etapa de la cosecha nos ayudan a proporcionar recomendaciones más precisas",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                
                // Ubicación
                const Text(
                  "Ubicación:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _currentPosition != null
                    ? Column(
                        children: [
                          Text(
                            "Ubicación actual: ${_currentAddress ?? 'Obteniendo dirección...'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId("current_location"),
                                  position: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                ),
                              },
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text("No se ha obtenido la ubicación"),
                        ),
                      ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _getCurrentPosition,
                  icon: const Icon(Icons.location_on),
                  label: const Text("Obtener Ubicación"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Etapa de la cosecha
                const Text(
                  "Etapa de la cosecha:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  value: _selectedCropStage,
                  hint: const Text("Selecciona la etapa de tu cultivo"),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCropStage = newValue;
                    });
                  },
                  items: <String>[
                    'Germinación',
                    'Crecimiento vegetativo',
                    'Floración',
                    'Fructificación',
                    'Maduración',
                    'Cosecha',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text("Fotografía y Descripción"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Toma una fotografía clara de la planta o cultivo que deseas diagnosticar",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _getImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Tomar Fotografía"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  "Describe los síntomas o problemas que has observado en tu cultivo",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Ej: Las hojas tienen manchas amarillas y están marchitándose...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text("Confirmar"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Revisa la información antes de enviar el diagnóstico",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Resumen de la información
                const Text("Ubicación:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_currentAddress ?? "No especificada"),
                
                const SizedBox(height: 10),
                const Text("Etapa del cultivo:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_selectedCropStage ?? "No especificada"),
                
                const SizedBox(height: 10),
                const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_descriptionController.text.isEmpty ? "No especificada" : _descriptionController.text),
                
                const SizedBox(height: 10),
                const Text("Imagen:", style: TextStyle(fontWeight: FontWeight.bold)),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : const Text("No se ha seleccionado imagen"),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 2) {
                      // Si no es el último paso, usar el comportamiento normal
                      details.onStepContinue?.call();
                    } else {
                      // Si es el último paso, procesar el diagnóstico directamente
                      debugPrint('Botón Finalizar presionado, procesando diagnóstico...');
                      _processDiagnosis();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep < 2 ? "Siguiente" : "Finalizar"),
                ),
                const SizedBox(width: 10),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Atrás"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _getImage() async {
    final File? image = await ImageService.takePicture();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _getCurrentPosition() async {
    final position = await LocationService.getCurrentPosition(context);
    
    if (position != null) {
      setState(() => _currentPosition = position);
      final address = await LocationService.getAddressFromLatLng(position);
      if (address != null) {
        setState(() {
          _currentAddress = address;
        });
      }
    }
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animación de carga
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Analizando imagen...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Nuestro sistema está procesando tu diagnóstico",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _processDiagnosis() async {
    debugPrint('Iniciando procesamiento del diagnóstico');
    
    // Activar la animación
    setState(() {
      _isProcessing = true;
    });
    _animationController.repeat();
    
    try {
      debugPrint('Obteniendo resultados del diagnóstico...');
      
      // Procesar el diagnóstico usando el servicio
      final results = await DiagnosticoService.processDiagnosis(
        image: _selectedImage,
        description: _descriptionController.text,
        location: _currentAddress,
        cropStage: _selectedCropStage,
      );
      
      debugPrint('Resultados obtenidos: ${results['disease']}');
      
      // Detener la animación
      _animationController.stop();
      setState(() {
        _isProcessing = false;
      });
      
      // Asegurarse de que el contexto sigue siendo válido
      if (!mounted) {
        debugPrint('Contexto no válido después de procesar');
        return;
      }
      
      debugPrint('Guardando diagnóstico y creando caso...');
      
      // Guardar el diagnóstico y crear caso automáticamente
      await _saveDiagnosisAndCreateCase(
        results,
        image: _selectedImage,
        description: _descriptionController.text,
        location: _currentAddress,
        cropStage: _selectedCropStage,
      );
      
    } catch (e) {
      debugPrint('Error en _processDiagnosis: $e');
      
      // En caso de error, detener la animación y mostrar mensaje
      _animationController.stop();
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el diagnóstico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Función para guardar diagnóstico y crear caso automáticamente
  Future<void> _saveDiagnosisAndCreateCase(
    Map<String, dynamic> results, {
    File? image,
    String? description,
    String? location,
    String? cropStage,
  }) async {
    try {
      debugPrint('🔄 Guardando diagnóstico y creando caso automáticamente...');
      
      // Primero guardar el diagnóstico
      final diagnosisId = await DiagnosticoService.saveDiagnosis(
        image: image,
        description: description,
        location: location,
        cropStage: cropStage,
        results: results,
      );
      
      if (diagnosisId != null) {
        debugPrint('✅ Diagnóstico guardado con ID: $diagnosisId');
        
        // Obtener el diagnóstico guardado
        final diagnostico = await DiagnosticoService.getDiagnosisById(diagnosisId);
        
        if (diagnostico != null) {
          debugPrint('📋 Creando caso automáticamente...');
          
          // Crear el caso automáticamente
          final caso = await CasoDiagnosticoService.crearCasoDesdeDignostico(
            diagnostico: diagnostico,
            nombre: 'Caso ${diagnostico.diseaseName}',
            contenidoLog: 'Caso creado automáticamente desde diagnóstico',
          );
          
          debugPrint('✅ Caso creado automáticamente con ID: ${caso.id}');
          
          // Navegar al detalle del caso recién creado
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CasoDetailPage(caso: caso),
              ),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Diagnóstico y caso creados exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          debugPrint('❌ No se pudo obtener el diagnóstico guardado');
        }
      } else {
        debugPrint('❌ No se pudo guardar el diagnóstico');
      }
    } catch (e) {
      debugPrint('❌ Error al guardar diagnóstico y crear caso: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el diagnóstico: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Widget _buildInfoDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.eco, color: AppColors.primaryColor, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '¡Bienvenido al Diagnóstico!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Te guiaremos paso a paso para diagnosticar tu cultivo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoStep('1. Ubicación y Etapa', 'Información del cultivo y ubicación geográfica'),
                _buildInfoStep('2. Fotografía', 'Toma una foto clara de la parte afectada'),
                _buildInfoStep('3. Análisis IA', 'Nuestro sistema analiza la imagen automáticamente'),
                _buildInfoStep('4. Resultado', 'Recibe el diagnóstico y recomendaciones'),
                _buildInfoStep('5. Seguimiento', 'Se crea un caso para monitorear el tratamiento'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'El caso se puede actualizar y cerrar cuando sea necesario.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {
                        setDialogState(() {
                          // El valor se manejará en los botones
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    const Expanded(
                      child: Text(
                        'No mostrar este mensaje nuevamente',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Comenzar Diagnóstico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildInfoStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
