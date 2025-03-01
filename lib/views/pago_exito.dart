import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PagoExitosoScreen extends StatelessWidget {
  final double total;
  final String peliculatitulo;
  final String fechapelicula;
  final  String horapelicula;
  final  List<String> asientos;
  final String comprador;

  const PagoExitosoScreen({Key? key,
    required this.total,
    required this.peliculatitulo,
    required this.asientos,
    required this.comprador,
    required this.fechapelicula,
    required this.horapelicula}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear la cadena de datos que irá dentro del QR
    String datosQR = '''
      Película: $peliculatitulo
      Fecha: $fechapelicula
      Hora: $horapelicula
      Comprador: $comprador
      Asientos: $asientos
      PagoTotal:$total
    ''';
    return Scaffold(
      appBar: AppBar(title: Text("Pago Exitoso")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text("¡Pago realizado con éxito!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("Total pagado: \$${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // Código QR
            QrImageView(
              data: datosQR,
              version: QrVersions.auto,
              size: 200,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text("Volver al inicio"),
            ),
          ],
        ),
      ),
    );
  }
}
