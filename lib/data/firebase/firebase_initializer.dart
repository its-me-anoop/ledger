import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Run once at app start. Safe to call repeatedly — handles already-initialized.
Future<void> initializeFirebase({FirebaseOptions? options}) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }
    _configureFirestore();
  } catch (e) {
    debugPrint('[Firebase] init error (placeholder config?): $e');
  }
}

void _configureFirestore() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('[Firestore] settings error: $e');
  }
}
