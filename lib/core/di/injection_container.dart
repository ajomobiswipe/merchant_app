import 'package:dio/dio.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/dio/dio_factory.dart';
import 'package:anet_merchants/features/auth/auth.dart';
import 'package:anet_merchants/features/devices/devices.dart';
import 'package:anet_merchants/features/settlements/settlements.dart';
import 'package:anet_merchants/features/shared/shared.dart';
import 'package:anet_merchants/features/support/support.dart';
import 'package:anet_merchants/features/transactions/transactions.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // final database =
  //     await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  // sl.registerSingleton<AppDatabase>(database);
  // Dio

  final dio = await DioFactory.create();

  sl.registerLazySingleton<Dio>(() => dio);
  //sl.registerSingleton<Dio>(Dio());

  // Data sources are the thin Retrofit / Dio entry points used by repositories.
  sl.registerSingleton<MerchantLoginApiService>(
    MerchantLoginApiService(sl(), baseUrl: EndPoints.baseApiPublicNanoUMS),
  );
  sl.registerSingleton<MerchantUiApiService>(
    MerchantUiApiService(sl(), baseUrl: EndPoints.uiApiBaseUrl),
  );

  // Repositories isolate transport details from the rest of the app and keep
  // use cases / blocs working with feature-level abstractions.
  sl.registerLazySingleton<MerchantLoginRepository>(() => LoginRepositoryImpl(
        apiService: sl(),
      ));
  sl.registerLazySingleton<ForgotPasswordRepository>(
    () => ForgotPasswordRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<OtpValidationRepository>(
    () => OtpValidationRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<PasswordResetRepository>(
    () => PasswordResetRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<SoundBoxRepository>(() => SoundBoxRepositoryImpl(
        apiService: sl(),
      ));
  sl.registerLazySingleton<MerchantVpaTxnRepository>(
      () => MerchantVpaTxnRepositoryImpl(
            apiService: sl(),
          ));
  sl.registerLazySingleton<PosTransactionRepository>(
    () => PosTransactionRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<SettlementRepository>(
    () => SettlementRepositoryImpl(dio: sl()),
  );
  sl.registerLazySingleton<SupportActionRepository>(
      () => SupportActionRepositoryImpl(
            apiService: sl(),
          ));
  sl.registerLazySingleton<UserLogin>(
    () => UserLogin(sl()),
  );
  sl.registerLazySingleton<RequestForgotPassword>(
    () => RequestForgotPassword(sl()),
  );
  sl.registerLazySingleton<VerifyEmailOtp>(
    () => VerifyEmailOtp(sl()),
  );
  sl.registerLazySingleton<ResetPassword>(
    () => ResetPassword(sl()),
  );
  sl.registerLazySingleton<GetSoundBoxDevices>(
    () => GetSoundBoxDevices(sl()),
  );
  sl.registerLazySingleton<GetMerchantVpaTxnData>(
    () => GetMerchantVpaTxnData(sl()),
  );
  sl.registerLazySingleton<GetPosTerminals>(
    () => GetPosTerminals(sl()),
  );
  sl.registerLazySingleton<GetPosTransactions>(
    () => GetPosTransactions(sl()),
  );
  sl.registerLazySingleton<GetSettlementHistory>(
    () => GetSettlementHistory(sl()),
  );
  sl.registerLazySingleton<GetSupportActionData>(
    () => GetSupportActionData(sl()),
  );
  sl.registerLazySingleton<RaiseSupportRequest>(
    () => RaiseSupportRequest(sl()),
  );

  // Blocs are factories so each route / provider gets a fresh state container
  // unless we explicitly share one higher in the widget tree.
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => SoundBoxBloc(sl()));
  sl.registerFactory(() => MerchantVpaTxnBloc(sl()));
  sl.registerFactory(() => PosTransactionBloc(sl(), sl()));
  sl.registerFactory(() => SettlementBloc(sl()));
  sl.registerFactory(() => SupportActionBloc(sl(), sl()));
}
