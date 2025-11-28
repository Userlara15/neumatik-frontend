import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/publicacion_service.dart';

// RUTA ASIGNADA: '/' (Ruta inicial)
// FUNCIÓN: Muestra el catálogo principal de autopartes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Usamos el servicio de publicaciones correcto.
  final PublicacionService _publicacionService = PublicacionService();
  late Future<List<PublicacionAutoparte>> _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    _publicacionesFuture = _publicacionService.getPublicacionesActivas();
  }

  // Función para recargar los datos con RefreshIndicator
  Future<void> _reloadData() async {
    setState(() {
      _publicacionesFuture = _publicacionService.getPublicacionesActivas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neumatik: Autopartes en Venta'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/perfil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Reconocimiento por IA',
            onPressed: () {
              Navigator.pushNamed(context, '/ia-reconocimiento');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Carrito de Compras',
            onPressed: () {
              Navigator.pushNamed(context, '/carrito');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadData,
        color: Colors.teal,
        child: FutureBuilder<List<PublicacionAutoparte>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error al cargar publicaciones: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay publicaciones disponibles.'),
              );
            }

            final publicaciones = snapshot.data!;
            return ListView.builder(
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                final publicacion = publicaciones[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/publicacion',
                      arguments: publicacion.publicacionId,
                    );
                  },
                  child: AutoparteCard(publicacion: publicacion),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Widget para el diseño de cada tarjeta de autoparte
class AutoparteCard extends StatelessWidget {
  final PublicacionAutoparte publicacion;

  const AutoparteCard({Key? key, required this.publicacion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: SizedBox(
            width: 80,
            height: 80,
            child: Image.network(
              publicacion.fotoPrincipalUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.car_crash, color: Colors.grey);
              },
            ),
          ),
          title: Text(
            publicacion.nombreParte,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${publicacion.precio.toStringAsFixed(2)} - ${publicacion.condicion}',
              ),
              Text(
                'Vendido por: ${publicacion.vendedorNombreCompleto}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: publicacion.iaVerificado
              ? const Icon(Icons.verified, color: Colors.blue)
              : null,
          isThreeLine: true,
        ),
      ),
    );
  }
}
