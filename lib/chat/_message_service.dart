import 'package:chatsuble/chat/widgets/distance_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

Future<List<Map<String, dynamic>>> getMessages() async {
  try {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    final QuerySnapshot snapshot = await messagesCollection.get();
    List<Map<String, dynamic>> messages = snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'messageId': doc.id,
            })
        .toList();

    messages.sort((a, b) {
      final DateTime dateTimeA = (a['timestamp'] as Timestamp).toDate();
      final DateTime dateTimeB = (b['timestamp'] as Timestamp).toDate();

      return dateTimeB.compareTo(dateTimeA);
    });

    Position userLocation = await getUserLocation();
    double userDistance = await getUserDistance();
    print("Distance d'affichage msg choisi par le user: $userDistance");

    messages = messages.where((message) {
      if (message.containsKey('latitude') && message.containsKey('longitude')) {
        double messageLat = message['latitude'] as double;
        double messageLon = message['longitude'] as double;

        double distance = calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          messageLat,
          messageLon,
        );
        print("Distance entre le user et message = $distance");
        return distance <= userDistance;
      } else {
        return false;
      }
    }).toList();

    return messages;
  } catch (e) {
    print('Erreur lors de la récupération des messages: $e');
    return [];
  }
}

Future<Position> getUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  } catch (e) {
    print(e);
    return Position(
      latitude: 0,
      longitude: 0,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}

Future<double> getUserDistance() async {
  // Récupérez l'utilisateur actuellement connecté
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Obtenez l'ID de l'utilisateur connecté
    String userId = user.uid;

    // Utilisez l'ID de l'utilisateur pour lire la distance du document utilisateur
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      // Accédez au champ "distance" du document utilisateur et renvoyez la valeur
      dynamic distance = userSnapshot['distance'];
      return distance.toDouble();
    } else {
      print('L\'utilisateur avec l\'ID $userId n\'existe pas.');
      return 0.0; // Ou une valeur par défaut
    }
  }

  return 0.0; // Ou une valeur par défaut
}
