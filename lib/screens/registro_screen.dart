import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario_autenticado.dart';

class RegistroScreen extends StatefulWidget {
  // Simulación de navegación: cuando el registro es exitoso, ir a la pantalla principal
  final VoidCallback onSuccessfulRegistration;

  const RegistroScreen({Key? key, required this.onSuccessfulRegistration})
    : super(key: key);

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _esVendedor = false;

  // Controladores de texto para los campos del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.registerUser(
          nombre: _nombreController.text,
          apellido: _apellidoController.text,
          correo: _correoController.text,
          contrasena: _contrasenaController.text,
          telefono: _telefonoController.text,
          esVendedor: _esVendedor,
        );

        // Registro exitoso: navega a la siguiente pantalla
        widget.onSuccessfulRegistration();
      } catch (e) {
        // Mostrar error en un Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
            ), // Muestra el mensaje de error del AuthService
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crea tu cuenta Neumatik',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _nombreController,
                'Nombre',
                validator: (v) => v!.isEmpty ? 'Ingresa tu nombre' : null,
              ),
              _buildTextField(_apellidoController, 'Apellido'),
              _buildTextField(
                _correoController,
                'Correo Electrónico',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty || !v.contains('@')
                    ? 'Ingresa un correo válido'
                    : null,
              ),
              _buildTextField(
                _contrasenaController,
                'Contraseña',
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              _buildTextField(
                _telefonoController,
                'Teléfono',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 10),
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
                  const Text('Quiero registrarme como vendedor'),
                ],
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.teal),
                    )
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Registrar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Simular navegación a Login (solo para demostración)
                  Navigator.of(context).pop();
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator ?? (value) => null,
      ),
    );
  }
}
