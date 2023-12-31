import 'package:chatsuble/profile/widgets/_distance_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;
  double distance = 50;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _getDistance();
  }

  void _getDistance() async {
    try {
      var userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      var userData = await userDoc.get();

      if (userData.exists) {
        setState(() {
          distance = userData['distance'] ?? 50;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la distance : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DistanceSlider(
          value: distance,
          onChanged: (double value) {
            setState(() {
              distance = value;
            });
          },
          userId: user.uid,
        ),
      ),
    );
  }
}
