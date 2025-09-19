import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../services/diagnostico_service.dart';

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
      ),
      body: _isProcessing ? _buildLoadingAnimation() : Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // Enviar diagnóstico
            _processDiagnosis();
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
                  onPressed: details.onStepContinue,
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

  void _processDiagnosis() async {
    // Activar la animación
    setState(() {
      _isProcessing = true;
    });
    _animationController.repeat();
    
    // Procesar el diagnóstico usando el servicio
    final results = await DiagnosticoService.processDiagnosis(
      image: _selectedImage,
      description: _descriptionController.text,
      location: _currentAddress,
      cropStage: _selectedCropStage,
    );
    
    // Detener la animación
    _animationController.stop();
    setState(() {
      _isProcessing = false;
    });
    
    // Mostrar los resultados
    DiagnosticoService.showDiagnosisResults(context, results);
  }
}
