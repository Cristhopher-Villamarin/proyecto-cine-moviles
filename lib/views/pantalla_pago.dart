import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'pago_exito.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaPago extends StatefulWidget {
  final double totalPago;
  final String peliculaId;
  final String peliculaTitulo;
  final String fechaSeleccionada;
  final String horaSeleccionada;
  final List<String> asientosSeleccionados;

  const PantallaPago({
    Key? key,
    required this.totalPago,
    required this.peliculaId,
    required this.peliculaTitulo,
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
    required this.asientosSeleccionados,
  }) : super(key: key);

  @override
  _PantallaPagoState createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController nombreTitularController = TextEditingController();
  final TextEditingController numeroTarjetaController = TextEditingController();
  final TextEditingController fechaExpiracionController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool _isProcessing = false; // 🔹 Variable para manejar la carga

  // Función para validar el nombre del titular
  bool _validarNombreTitular(String nombre) {
    final RegExp regex = RegExp(r'^[a-zA-Z\s]+$');
    return regex.hasMatch(nombre);
  }

  // Función para validar el número de tarjeta
  bool _validarNumeroTarjeta(String numero) {
    final RegExp regex = RegExp(r'^\d{16}$');
    return regex.hasMatch(numero);
  }

  // Función para validar la fecha de expiración
  bool _validarFechaExpiracion(String fecha) {
    final RegExp regex = RegExp(r'^\d{2}/\d{2}$');
    if (!regex.hasMatch(fecha)) return false;

    final List<String> partes = fecha.split('/');
    final int mes = int.tryParse(partes[0]) ?? 0;
    final int anio = int.tryParse(partes[1]) ?? 0;

    if (mes < 1 || mes > 12) return false;

    final DateTime ahora = DateTime.now();
    final int anioActual = ahora.year % 100;
    final int mesActual = ahora.month;

    if (anio < anioActual || (anio == anioActual && mes < mesActual)) {
    return false; // Fecha vencida
    }

    return true;
  }

  // Función para validar el CVV
  bool _validarCVV(String cvv) {
    final RegExp regex = RegExp(r'^\d{3,4}$');
    return regex.hasMatch(cvv);
  }

  Future<void> _procesarPago() async {
    if (_isProcessing) return; // Evita múltiples clics
    setState(() => _isProcessing = true); // 🔹 Activa la animación de carga

    final User? user = FirebaseAuth.instance.currentUser;

    // Validaciones de campos
    if (nombreTitularController.text.isEmpty ||
        numeroTarjetaController.text.isEmpty ||
        fechaExpiracionController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (!_validarNombreTitular(nombreTitularController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nombre del titular no válido")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (!_validarNumeroTarjeta(numeroTarjetaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Número de tarjeta no válido")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (!_validarFechaExpiracion(fechaExpiracionController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fecha de expiración no válida o vencida")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (!_validarCVV(cvvController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CVV no válido")),
      );
      setState(() => _isProcessing = false);
      return;
    }

    try {
      DocumentReference pagoRef = await _firestore.collection("pagos").add({
        "total": widget.totalPago,
        "peliculaId": widget.peliculaId,
        "peliculaTitulo": widget.peliculaTitulo,
        "fecha_funcion": widget.fechaSeleccionada,
        "hora_funcion": widget.horaSeleccionada,
        "asientos": widget.asientosSeleccionados,
        "titular": nombreTitularController.text,
        "numero_tarjeta": numeroTarjetaController.text,
        "fecha_expiracion": fechaExpiracionController.text,
        "cvv": cvvController.text,
        "estado": "APROBADO",
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Pago registrado con ID: ${pagoRef.id}");

      for (String asiento in widget.asientosSeleccionados) {
        DocumentReference asientoRef = _firestore
            .collection("peliculas")
            .doc(widget.peliculaId)
            .collection("fechas_disponibles")
            .doc(widget.fechaSeleccionada)
            .collection("horarios")
            .doc(widget.horaSeleccionada)
            .collection("asientos")
            .doc(asiento);

        DocumentSnapshot asientoSnapshot = await asientoRef.get();
        if (asientoSnapshot.exists) {
          await asientoRef.update({"estado": "ocupado"});
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PagoExitosoScreen(
            total: widget.totalPago,
            peliculatitulo: widget.peliculaTitulo,
            fechapelicula: widget.fechaSeleccionada,
            horapelicula: widget.horaSeleccionada,
            asientos: widget.asientosSeleccionados,
            comprador: user?.displayName ?? user?.email ?? "Usuario Anónimo",
          ),
        ),
      );
    } catch (error) {
      print("❌ Error al procesar el pago: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al procesar el pago")),
      );
    } finally {
      setState(() => _isProcessing = false); // 🔹 Desactiva la animación
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El decoration debe estar dentro del body, no directamente en el Scaffold
      body: Container(
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
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/fondo.png', // Imagen de marca de agua
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.srcOver,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: 350, // Hacemos la tarjeta más pequeña y centrada
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Encabezado con título centrado
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF3533CD),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            ),
                            child: Center(
                              child: Text(
                                "Confirmación de Compra",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          Text(
                            "Completa los datos para finalizar tu compra",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),

                          SizedBox(height: 16),

                          /// Información del pago
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFC3E1FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoText("Película:", widget.peliculaTitulo, true),
                                _infoText("Asientos:", widget.asientosSeleccionados.join(", "), true),
                                _infoText("Total a pagar:", "\$${widget.totalPago.toStringAsFixed(2)}", true),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          /// Campos de pago
                          _buildTextField("Nombre del titular", Icons.person, nombreTitularController),
                          _buildTextField("Número de tarjeta", Icons.credit_card, numeroTarjetaController),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField("Fecha de expiración (MM/YY)", Icons.calendar_today, fechaExpiracionController),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField("CVV", Icons.lock, cvvController),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          /// Botón de pago
                          SizedBox(
                            width: double.infinity, // Hace el botón más largo
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _procesarPago,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF3533CD),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isProcessing
                                  ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : Text(
                                "Pagar \$${widget.totalPago.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Función para mostrar información del pago
  Widget _infoText(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF3533CD),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Función para construir campos de texto con íconos
  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}