import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DistanceSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String userId;

  const DistanceSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Distance:'),
        Slider(
          value: value,
          min: 1,
          max: 100,
          divisions: 100,
          label: '${value.round()} km',
          onChanged: (newValue) {
            onChanged(newValue);
            updateDistanceInFirestore(newValue);
          },
        ),
      ],
    );
  }

  Future<void> updateDistanceInFirestore(double newDistance) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'distance': newDistance,
      });
    } catch (e) {
      print("Erreur lors de la mise à jour de la distance : $e");
    }
  }
}
