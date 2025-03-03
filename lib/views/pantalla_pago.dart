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
  bool _isProcessing = false;

  Future<void> _procesarPago() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final User? user = FirebaseAuth.instance.currentUser;

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

    try {
      // 🔹 Registrar el pago en la colección "pagos"
      DocumentReference pagoRef = await _firestore.collection("pagos").add({
        "total": widget.totalPago,
        "peliculaId": widget.peliculaId,
        "peliculaTitulo": widget.peliculaTitulo,
        "fecha_funcion": widget.fechaSeleccionada,
        "hora_funcion": widget.horaSeleccionada,
        "asientos": widget.asientosSeleccionados,
        "titular": nombreTitularController.text,
        "numero_tarjeta": numeroTarjetaController.text.replaceAll(" ", ""),
        "fecha_expiracion": fechaExpiracionController.text,
        "cvv": cvvController.text,
        "estado": "APROBADO",
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Pago registrado con ID: ${pagoRef.id}");

      // 🔹 Actualizar el estado de los asientos a "ocupado"
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
          print("🔄 Asiento $asiento actualizado como ocupado");
        } else {
          print("⚠️ Advertencia: El asiento $asiento no existe en Firestore");
        }
      }

      // 🔹 Redirigir a la pantalla de pago exitoso
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
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF3533CD)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/fondo.png',
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
                      width: 350,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          _infoText("Película:", widget.peliculaTitulo, true),
                          _infoText("Asientos:", widget.asientosSeleccionados.join(", "), true),
                          _infoText("Total a pagar:", "\$${widget.totalPago.toStringAsFixed(2)}", true),
                          SizedBox(height: 20),
                          _buildTextField("Nombre del titular", Icons.person,
                              nombreTitularController, TextInputType.text, [
                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$'))
                          ]),
                          _buildTextField("Número de tarjeta", Icons.credit_card,
                              numeroTarjetaController, TextInputType.number, [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(19),
                          ], onChanged: (value) {
                            value = value.replaceAll(RegExp(r'\s'), '');
                            if (value.length > 16) value = value.substring(0, 16);
                            String formatted = '';
                            for (int i = 0; i < value.length; i++) {
                              if (i % 4 == 0 && i != 0) formatted += ' ';
                              formatted += value[i];
                            }
                            numeroTarjetaController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField("Fecha Exp. (MM/YY)", Icons.calendar_today,
                                    fechaExpiracionController, TextInputType.number, [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(5),
                                ], onChanged: (value) {
                                  value = value.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (value.length > 4) value = value.substring(0, 4);
                                  if (value.length >= 2 && !value.contains('/')) {
                                    value = value.substring(0, 2) + '/' + value.substring(2);
                                  }
                                  fechaExpiracionController.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.collapsed(offset: value.length),
                                  );
                                }),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField("CVV", Icons.lock, cvvController,
                                    TextInputType.number, [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ]),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
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

  Widget _infoText(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Color(0xFF3533CD), fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller , TextInputType keyboardType,
      List<TextInputFormatter> formatters, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType, // Adaptado según el campo
        inputFormatters: formatters,
        onChanged: onChanged,
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
