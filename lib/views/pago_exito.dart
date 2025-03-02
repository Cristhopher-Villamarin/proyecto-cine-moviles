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

    String qrData = """
    📽️ Película: ${peliculatitulo}
    📅 Fecha: ${fechapelicula}
    🕒 Hora: ${horapelicula}
    👤 Comprador: ${comprador}
    🎟️ Asientos: ${asientos.join(", ")}
    💰 Pago Total: \$${total.toStringAsFixed(2)}
    """;

    return Scaffold(
      body: Stack(
        children: [
          /// **Fondo degradado**
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black, // Negro en la parte superior
                  Color(0xFF3533CD), // Azul oscuro en la parte inferior
                ],
              ),
            ),
          ),

          /// **Imagen de marca de agua**
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.png',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.srcOver,
            ),
          ),

          /// **Tarjeta con la información del pago**
          Center(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: 350, // Se hace más pequeña y centrada
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// **Encabezado "Pago Exitoso"**
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFF3533CD), // Color de encabezado
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          "Pago Exitoso",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    /// **Mensaje de éxito**
                    Text(
                      "¡Pago realizado con éxito!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10),

                    /// **Total pagado**
                    Text(
                      "Total pagado: \$${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3533CD), // Color especificado
                      ),
                    ),

                    SizedBox(height: 20),

                    /// **Código QR con diseño personalizado**
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF3533CD), // Color del borde del QR
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black, // Color de los módulos del QR
                      ),
                    ),

                    SizedBox(height: 20),

                    /// **Botón para ver detalles del QR**
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _mostrarDetallesQR(context, datosQR);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC3E1FF), // Color del botón
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Ver detalles",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    /// **Botón para volver al inicio**
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaCine(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC3E1FF), // Color del botón
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Volver al inicio",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para mostrar el contenido del QR de manera ordenada
  void _mostrarDetallesQR(BuildContext context, Map<String, dynamic> datosQR) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Detalles de la compra"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Película", datosQR["Película"]),
                _buildDetailRow("Fecha", datosQR["Fecha"]),
                _buildDetailRow("Hora", datosQR["Hora"]),
                _buildDetailRow("Comprador", datosQR["Comprador"]),
                _buildDetailRow("Asientos", datosQR["Asientos"].join(", ")),
                _buildDetailRow("Total Pagado", "\$${datosQR["PagoTotal"]}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  // Función para construir una fila de detalles
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}