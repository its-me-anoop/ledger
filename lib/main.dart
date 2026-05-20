import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'data/firebase/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
  } catch (e) {
    debugPrint('[main] Firebase init failed (running without Firebase): $e');
  }

  setupDi();
  runApp(const LedgerApp());
}
