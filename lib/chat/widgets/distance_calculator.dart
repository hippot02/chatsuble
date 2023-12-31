import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double radius = 6371; // Rayon de la Terre en kilomètres

  // Convertir les coordonnées en radians
  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  // Calcul de la distance haversine
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return radius * c;
}

double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}
