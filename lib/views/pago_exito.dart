import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'pantalla_cine.dart';

class PagoExitosoScreen extends StatelessWidget {
  final double total;
  final String peliculatitulo;
  final String fechapelicula;
  final String horapelicula;
  final List<String> asientos;
  final String comprador;

  const PagoExitosoScreen({
    Key? key,
    required this.total,
    required this.peliculatitulo,
    required this.asientos,
    required this.comprador,
    required this.fechapelicula,
    required this.horapelicula,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear el JSON estructurado para el QR
    Map<String, dynamic> datosQR = {
      "Película": peliculatitulo,
      "Fecha": fechapelicula,
      "Hora": horapelicula,
      "Comprador": comprador,
      "Asientos": asientos,
      "PagoTotal": total.toStringAsFixed(2),
    };

    String qrData = jsonEncode(datosQR); // Convertir el mapa a JSON

    return Scaffold(
      appBar: AppBar(title: const Text("Pago Exitoso")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "¡Pago realizado con éxito!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Total pagado: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Código QR con diseño personalizado
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.blue,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Botón para ver los detalles de la compra
            ElevatedButton(
              onPressed: () {
                _mostrarDetallesQR(context, datosQR);
              },
              child: const Text("Ver detalles"),
            ),

            const SizedBox(height: 10),

            // Botón para volver al inicio
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaCine(),
                  ),
                );
              },
              child: const Text("Volver al inicio"),
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar el contenido del QR de manera ordenada
  void _mostrarDetallesQR(BuildContext context, Map<String, dynamic> datosQR) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Detalles de la compra"),
          content: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent("  ").convert(datosQR),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}
