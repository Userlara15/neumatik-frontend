import 'package:flutter/material.dart';
import '../services/auth_service.dart'; //servicio de autenticación
import '../models/usuario_autenticado.dart'; // Importa el modelo si es necesario para tipado

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Estado del formulario
  bool _isLoading = false;
  bool _esVendedor = false; // Permite al usuario registrarse como vendedor

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String nombre = _nombreController.text.trim();
      final String apellido = _apellidoController.text.trim();
      final String correo = _correoController.text.trim();
      final String contrasena = _contrasenaController.text;
      final String telefono = _telefonoController.text.trim();

      try {
        // Ahora se espera que registerUser devuelva un objeto (UsuarioAutenticado) en éxito o null en fallo.
        final result = await _authService.registerUser(
          nombre: nombre,
          apellido: apellido,
          correo: correo,
          contrasena: contrasena,
          telefono: telefono,
          esVendedor: _esVendedor,
        );

        if (mounted) {
          if (result != null) {
            // Si retorna un objeto (que no es null) se asume éxito
            // Registro exitoso, redirige al Home (el AuthService ya guardó el token)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🎉 ¡Registro y Sesión Iniciada! Bienvenido a Neumatik.',
                ),
                backgroundColor: Colors.teal, // Color consistente con el éxito
              ),
            );
            // Reemplazar la pila de navegación para ir a la ruta principal ('/home')
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false);
          } else {
            // El backend/servicio debe devolver null si falla lógicamente (ej. "correo ya existe")
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚠️ Fallo en el registro. Verifica los datos o intenta con otro correo.',
                ),
                backgroundColor: Colors.orange, // Color de advertencia
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          // Captura errores de red o excepciones del servicio (fallo técnico)
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al registrar: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal, // Consistente con el LoginScreen
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Crea tu Cuenta Neumatik',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Campo Nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'El nombre es obligatorio.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo Apellido
                  TextFormField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'El apellido es obligatorio.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo Correo
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'El correo es obligatorio.';
                      if (!value.contains('@'))
                        return 'Ingresa un correo válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Contraseña
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.length < 6
                        ? 'La contraseña debe tener al menos 6 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo Teléfono (Opcional en el backend, pero lo pedimos)
                  TextFormField(
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (Opcional)',
                      prefixIcon: Icon(Icons.phone, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkbox para Vendedor
                  Row(
                    children: [
                      Checkbox(
                        value: _esVendedor,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _esVendedor = newValue ?? false;
                          });
                        },
                        activeColor: Colors.teal,
                      ),
                      const Text('Quiero registrarme como Vendedor'),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Botón de Registro
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 15),

                  // Enlace a Login
                  TextButton(
                    onPressed: () {
                      // Simplemente regresa a la pantalla de login (que está debajo)
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia Sesión',
                      style: TextStyle(color: Colors.teal), // Color consistente
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
