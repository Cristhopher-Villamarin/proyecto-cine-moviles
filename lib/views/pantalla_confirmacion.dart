import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'pantalla_cine.dart'; // Para volver a la pantalla principal.

class PantallaConfirmacion extends StatelessWidget {
  final String peliculaTitulo;
  final List<String> asientos;

  const PantallaConfirmacion({Key? key, required this.peliculaTitulo, required this.asientos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String qrData = "Película: $peliculaTitulo\nAsientos: ${asientos.join(", ")}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Reserva Confirmada"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                "¡Reserva Confirmada!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Película: $peliculaTitulo",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Asientos: ${asientos.join(", ")}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => PantallaCine()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Volver al Inicio", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
