import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/groups/data/firestore_group_repository.dart';
import '../features/groups/domain/group_repository.dart';
import '../features/groups/presentation/bloc/group_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupDi() {
  // Firebase singletons — registered lazily; Firebase.initializeApp must run first.
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Repositories (eager singletons once first accessed).
  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  getIt.registerLazySingleton<GroupRepository>(
    () => FirestoreGroupRepository(firestore: getIt<FirebaseFirestore>()),
  );

  // Blocs — factories so each page gets a fresh instance.
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<GroupBloc>(() => GroupBloc(getIt<GroupRepository>()));
}
