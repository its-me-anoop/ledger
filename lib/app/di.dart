import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/expenses/data/firestore_expense_repository.dart';
import '../features/expenses/domain/expense_repository.dart';
import '../features/expenses/presentation/bloc/expense_bloc.dart';
import '../features/groups/data/firestore_group_repository.dart';
import '../features/groups/domain/group_repository.dart';
import '../features/groups/presentation/bloc/group_bloc.dart';
import '../features/groups/presentation/bloc/group_detail_bloc.dart';
import '../features/settlements/data/firestore_settlement_repository.dart';
import '../core/theme/theme_cubit.dart';
import '../features/settlements/domain/settlement_repository.dart';
import '../features/settlements/presentation/bloc/settlement_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupDi() {
  // SharedPreferences — async singleton, initialized before app starts.
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  getIt.registerSingletonWithDependencies<ThemeCubit>(
    () => ThemeCubit(getIt<SharedPreferences>()),
    dependsOn: [SharedPreferences],
  );

  // Firebase singletons — registered lazily; Firebase.initializeApp must run first.
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<GroupRepository>(
    () => FirestoreGroupRepository(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () => FirestoreExpenseRepository(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<SettlementRepository>(
    () => FirestoreSettlementRepository(firestore: getIt<FirebaseFirestore>()),
  );

  // Blocs — factories so each page gets a fresh instance.
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<GroupBloc>(() => GroupBloc(getIt<GroupRepository>()));
  getIt.registerFactory<GroupDetailBloc>(
    () => GroupDetailBloc(getIt<GroupRepository>()),
  );
  getIt.registerFactory<SettlementBloc>(
    () => SettlementBloc(getIt<SettlementRepository>()),
  );
  getIt.registerFactory<ExpenseBloc>(
    () => ExpenseBloc(
      expenseRepository: getIt<ExpenseRepository>(),
      settlementRepository: getIt<SettlementRepository>(),
    ),
  );
}
