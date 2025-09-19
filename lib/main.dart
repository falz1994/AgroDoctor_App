import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const AgroDoctorApp());
}

class AgroDoctorApp extends StatelessWidget {
  const AgroDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroDoctor',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A7C1A), // Verde
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF4A7C1A),
          secondary: const Color(0xFFE57C23), // Naranja
        ),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroDoctor"),
        backgroundColor: const Color(0xFF4A7C1A),
        actions: [
          // Menú en la barra de navegación
          TextButton(
            onPressed: () {},
            child: const Text("Inicio", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Servicios", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Contacto", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              _showLoginModal(context);
            },
            child: const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner principal
            Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A7C1A), Color(0xFFE57C23)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo.jpg",
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "AgroDoctor",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Tu aliado en el diagnóstico y cuidado de cultivos",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar al wizard de diagnóstico
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DiagnosticoWizard()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Comenzar Ahora",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A7C1A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Sección de características
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nuestros Servicios",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C1A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          "Diagnóstico de Cultivos",
                          "Identifica enfermedades y plagas en tus cultivos con inteligencia artificial",
                          Icons.eco,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureCard(
                          "Recomendaciones",
                          "Recibe recomendaciones personalizadas para el tratamiento de tus cultivos",
                          Icons.lightbulb,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureCard(
                          "Seguimiento",
                          "Realiza un seguimiento del progreso y salud de tus cultivos",
                          Icons.trending_up,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Sección "Acerca de"
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Acerca de AgroDoctor",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A7C1A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "AgroDoctor es una aplicación diseñada para ayudar a agricultores y aficionados a la jardinería a diagnosticar y tratar problemas en sus cultivos. Utilizando tecnología de inteligencia artificial, podemos identificar enfermedades, plagas y deficiencias nutricionales para proporcionar soluciones efectivas y personalizadas.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF4A7C1A),
              child: const Column(
                children: [
                  Text(
                    "AgroDoctor © 2025",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Contacto: info@agrodoctor.com",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 50,
              color: const Color(0xFFE57C23),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar el modal de login
  void _showLoginModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const LoginModal(),
        );
      },
    );
  }
}

// Modal de Login
class LoginModal extends StatelessWidget {
  const LoginModal({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(
            "assets/logo.jpg",
            height: 100,
          ),
          const SizedBox(height: 10),

          // Email
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Correo",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 15),

          // Password
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Contraseña",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 20),

          // Botón de Login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C1A),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Aquí va la lógica de login
              },
              child: const Text(
                "Iniciar Sesión",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Botón de registro
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el modal
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: const Text(
              "¿No tienes cuenta? Regístrate",
              style: TextStyle(color: Color(0xFFE57C23)),
            ),
          ),
        ],
      ),
    );
  }
}

// Pantalla de registro
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: const Color(0xFF4A7C1A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Center(
              child: Image.asset(
                "assets/logo.jpg",
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            
            // Nombre
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            
            // Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            
            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 15),
            
            // Confirm Password
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirmar contraseña",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 25),
            
            // Botón de registro
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C1A),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Lógica de registro
              },
              child: const Text(
                "Registrarse",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            
            // Volver a login
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "¿Ya tienes cuenta? Inicia sesión",
                style: TextStyle(color: Color(0xFFE57C23)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wizard de diagnóstico
class DiagnosticoWizard extends StatefulWidget {
  const DiagnosticoWizard({super.key});

  @override
  State<DiagnosticoWizard> createState() => _DiagnosticoWizardState();
}

class _DiagnosticoWizardState extends State<DiagnosticoWizard> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();
  Position? _currentPosition;
  String? _currentAddress;
  String? _selectedCropStage;
  
  // Para la animación de carga
  late AnimationController _animationController;
  bool _isProcessing = false;
  
  Future<void> _getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }
  
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Los servicios de ubicación están desactivados. Por favor actívalos.')));
      return false;
    }
    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Los permisos de ubicación fueron denegados')));
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Los permisos de ubicación están permanentemente denegados')));
      return false;
    }
    
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    
    if (!hasPermission) return;
    
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    ).then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
      position.latitude, position.longitude
    ).then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

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
        backgroundColor: const Color(0xFF4A7C1A),
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
                    backgroundColor: const Color(0xFF4A7C1A),
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
                    backgroundColor: const Color(0xFF4A7C1A),
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
                    backgroundColor: const Color(0xFF4A7C1A),
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
                color: const Color(0xFF4A7C1A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE57C23).withOpacity(0.5),
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

  void _processDiagnosis() {
    // Activar la animación
    setState(() {
      _isProcessing = true;
    });
    _animationController.repeat();
    
    // Simular procesamiento (3 segundos)
    Future.delayed(const Duration(seconds: 3), () {
      _animationController.stop();
      setState(() {
        _isProcessing = false;
      });
      
      // Mostrar resultados
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Resultado del Diagnóstico"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enfermedad detectada: Roya del frijol",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "Nivel de confianza: 92%",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text(
                "Recomendaciones:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text("• Aplicar fungicida a base de cobre"),
              const Text("• Eliminar plantas infectadas"),
              const Text("• Mejorar la ventilación entre plantas"),
              const Text("• Evitar riego por aspersión"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Volver a la página principal
              },
              child: const Text("Aceptar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ver más detalles"),
            ),
          ],
        ),
      );
    });

  }
}