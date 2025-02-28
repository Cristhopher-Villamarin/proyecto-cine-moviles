import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarPeliculas() async {
    List<Map<String, dynamic>> peliculas = [
      {
        "titulo": "Avatar 2",
        "imagen": "https://upload.wikimedia.org/wikipedia/en/b/b0/Avatar_The_Way_of_Water_poster.jpg",
        "sinopsis": "Jake Sully y Ney'tiri han formado una familia y hacen todo lo posible por permanecer juntos. Sin embargo, deben abandonar su hogar y explorar las regiones de Pandora cuando una antigua amenaza reaparece.",
        "precio": 8.50,
        "duracion": "2h 30min",
        "clasificacion": "PG-13",
        "sala": "Sala 1",
        "fechas_disponibles": [
          {
            "dia_letras": "Viernes",
            "dia_numero": 15,
            "mes": "Marzo",
            "horarios": ["15:00", "18:00", "21:00"]
          },
          {
            "dia_letras": "Sábado",
            "dia_numero": 16,
            "mes": "Marzo",
            "horarios": ["14:00", "17:00", "20:00"]
          }
        ]
      },
      {
        "titulo": "Spider-Man: No Way Home",
        "imagen": "https://upload.wikimedia.org/wikipedia/en/0/00/Spider-Man_No_Way_Home_poster.jpg",
        "sinopsis": "Spider-Man, nuestro héroe, vecino y amigo es desenmascarado y por tanto ya no es capaz de separar su vida normal de los enormes riesgos que conlleva ser un Súper Héroe. Cuando pide ayuda a Doctor Strange, los riesgos pasan a ser aún más peligrosos, obligándole a descubrir lo que realmente significa ser Spider-Man.",
        "precio": 9.00,
        "duracion": "2h 28min",
        "clasificacion": "PG-13",
        "sala": "Sala 2",
        "fechas_disponibles": [
          {
            "dia_letras": "Sábado",
            "dia_numero": 16,
            "mes": "Marzo",
            "horarios": ["12:00", "16:00", "19:00"]
          },
          {
            "dia_letras": "Domingo",
            "dia_numero": 17,
            "mes": "Marzo",
            "horarios": ["13:00", "18:00", "21:30"]
          }
        ]
      },
      {
        "titulo": "Avengers: End Game",
        "imagen": "https://ruta-imagen.com/spiderman.jpg",
        "sinopsis": "Después de los eventos devastadores de Avengers: Infinity War, el universo está en ruinas debido a las acciones de Thanos, el Titán Loco. Con la ayuda de los aliados que quedaron, los Vengadores deberán reunirse una vez más para intentar detenerlo y restaurar el orden en el universo de una vez por todas.",
        "precio": 4.00,
        "duracion": "3h 02min",
        "clasificacion": "PG-15",
        "sala": "Sala 3",
        "fechas_disponibles": [
          {
            "dia_letras": "Miércoles",
            "dia_numero": 12,
            "mes": "Marzo",
            "horarios": ["10:00", "13:00", "15:00"]
          },
          {
            "dia_letras": "Domingo",
            "dia_numero": 16,
            "mes": "Marzo",
            "horarios": ["13:00", "17:00", "22:00"]
          }
        ]
      },
      {
        "titulo": "The Batman",
        "imagen": "https://ruta-imagen.com/spiderman.jpg",
        "sinopsis": "En su segundo año luchando contra el crimen, Batman explora la corrupción existente en la ciudad de Gotham y el vínculo de esta con su propia familia. Además, entrará en conflicto con un asesino en serie conocido como el Acertijo.",
        "precio": 9.00,
        "duracion": "2h 15min",
        "clasificacion": "PG-18",
        "sala": "Sala 1",
        "fechas_disponibles": [
          {
            "dia_letras": "Lunes",
            "dia_numero": 17,
            "mes": "Marzo",
            "horarios": ["12:00", "16:00", "19:00"]
          },
          {
            "dia_letras": "Jueves",
            "dia_numero": 20,
            "mes": "Marzo",
            "horarios": ["13:00", "18:00", "21:30"]
          }
        ]
      },
      {
        "titulo": "X-Men: Origins",
        "imagen": "https://ruta-imagen.com/spiderman.jpg",
        "sinopsis": "Nacido como mutante en 1845, Lobezno y su hermano huyen de su pueblo para inscribirse en el ejército, luchando en cada gran batalla americana. Un día son reclutados por el coronel Stryker para formar un ejército especial de mutantes. Lobezno acaba escapando e intenta seguir con una vida normal. Sin embargo, cuando descubre que Stryker le persigue se prepara para atacar de nuevo.",
        "precio": 5.00,
        "duracion": "2h 32min",
        "clasificacion": "PG-18",
        "sala": "Sala 2",
        "fechas_disponibles": [
          {
            "dia_letras": "Martes",
            "dia_numero": 18,
            "mes": "Marzo",
            "horarios": ["16:00", "18:00", "22:00"]
          },
          {
            "dia_letras": "Viernes",
            "dia_numero": 21,
            "mes": "Marzo",
            "horarios": ["11:00", "18:00", "21:30"]
          }
        ]
      },
      {
        "titulo": "El Rey Arturo",
        "imagen": "https://es.web.img3.acsta.net/pictures/17/07/04/10/44/351218.jpg",
        "sinopsis": "Arturo quiere abandonar Bretaña para volver a Roma. Pero antes, una última misión le hace comprender tanto a él como a los caballeros de la Mesa Redonda que lo que Bretaña necesita es un rey que la defienda de la amenaza de la invasión sajona.",
        "precio": 7.00,
        "duracion": "1h 53min",
        "clasificacion": "PG-14",
        "sala": "Sala 1",
        "fechas_disponibles": [
          {
            "dia_letras": "Sabado",
            "dia_numero": 15,
            "mes": "Marzo",
            "horarios": ["17:00", "21:00", "22:30"]
          },
          {
            "dia_letras": "Viernes",
            "dia_numero": 16,
            "mes": "Marzo",
            "horarios": ["13:00", "15:00", "20:30"]
          }
        ]
      }
    ];
    WriteBatch batch = _firestore.batch();

    for (var pelicula in peliculas) {
      DocumentReference peliculaRef = _firestore.collection("peliculas").doc();

      batch.set(peliculaRef, {
        "titulo": pelicula["titulo"],
        "imagen": pelicula["imagen"],
        "sinopsis": pelicula["sinopsis"],
        "precio": pelicula["precio"],
        "duracion": pelicula["duracion"],
        "clasificacion": pelicula["clasificacion"],
        "sala": pelicula["sala"],
      });

      for (var fecha in pelicula["fechas_disponibles"]) {
        DocumentReference fechaRef = peliculaRef
            .collection("fechas_disponibles")
            .doc("${fecha["dia_numero"]}-${fecha["mes"]}");

        batch.set(fechaRef, {
          "dia_letras": fecha["dia_letras"],
          "dia_numero": fecha["dia_numero"],
          "mes": fecha["mes"],
          "horarios": fecha["horarios"]
        });

        // 🔹 Agregar horarios dentro de cada fecha
        for (var hora in fecha["horarios"]) {
          DocumentReference horaRef = fechaRef.collection("horarios").doc(hora);
          batch.set(horaRef, {"hora": hora});
        }
      }

        // Generar asientos para esta película
      await generarAsientosPorFechaYHora(peliculaRef.id, pelicula["fechas_disponibles"]);
    }

      await batch.commit();
      print("✅ Películas y fechas agregadas correctamente a Firestore.");
    }

  Future<void> generarAsientosPorFechaYHora(String peliculaId, List<Map<String, dynamic>> fechasDisponibles) async {
    WriteBatch batch = _firestore.batch();
    List<String> filas = ["A", "B", "C", "D", "E", "F"];
    int asientosPorFila = 10;

    for (var fecha in fechasDisponibles) {
      DocumentReference fechaRef = _firestore
          .collection("peliculas")
          .doc(peliculaId)
          .collection("fechas_disponibles")
          .doc("${fecha["dia_numero"]}-${fecha["mes"]}");

      for (var hora in fecha["horarios"]) {
        DocumentReference horaRef = fechaRef.collection("horarios").doc(hora);

        for (var fila in filas) {
          for (int i = 1; i <= asientosPorFila; i++) {
            String numeroAsiento = "$fila$i";

            DocumentReference asientoRef = horaRef.collection("asientos").doc(numeroAsiento);

            batch.set(asientoRef, {
              "numero": numeroAsiento,
              "estado": "libre",
            });
          }
        }
      }
    }

    await batch.commit();
    print("✅ Asientos generados correctamente por fecha y hora.");
  }
}
