import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:anet_merchants/features/auth/domain/repository/merchant_login_repository.dart';
import 'package:anet_merchants/features/auth/domain/usecases/user_login.dart';
import 'package:anet_merchants/features/auth/presentation/bloc/login/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('AuthBloc login', () {
    test('emits loading and success when repository returns user info',
        () async {
      final repository = _FakeMerchantLoginRepository(
        result: DataSuccess(_userInfo),
      );
      final bloc = AuthBloc(UserLogin(repository));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ]),
      );

      bloc.add(const LoginPressed(username: 'merchant', password: 'secret'));

      await expectation;
      await bloc.close();

      expect(repository.username, 'merchant');
      expect(repository.password, 'secret');
    });

    test('emits loading and failure when repository returns DataFailed',
        () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/login'),
        message: 'Invalid credentials',
      );
      final repository = _FakeMerchantLoginRepository(
        result: DataFailed(error),
      );
      final bloc = AuthBloc(UserLogin(repository));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (state) => state.error?.message,
            'error message',
            'Invalid credentials',
          ),
        ]),
      );

      bloc.add(const LoginPressed(username: 'merchant', password: 'wrong'));

      await expectation;
      await bloc.close();

      expect(repository.username, 'merchant');
      expect(repository.password, 'wrong');
    });

    test('emits reset required when login response code is 04', () async {
      final repository = _FakeMerchantLoginRepository(
        result: DataSuccess(
          _userInfoWithResponse('04', message: 'Password reset required'),
        ),
      );
      final bloc = AuthBloc(UserLogin(repository));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthPasswordResetRequired>()
              .having((state) => state.username, 'username', 'merchant')
              .having(
                (state) => state.message,
                'message',
                'Password reset required',
              ),
        ]),
      );

      bloc.add(const LoginPressed(username: 'merchant', password: 'secret'));

      await expectation;
      await bloc.close();
    });

    test('emits loading and failure when repository throws DioException',
        () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/login'),
        message: 'Network error',
      );
      final repository = _ThrowingMerchantLoginRepository(error);
      final bloc = AuthBloc(UserLogin(repository));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>().having(
            (state) => state.error?.message,
            'error message',
            'Network error',
          ),
        ]),
      );

      bloc.add(const LoginPressed(username: 'merchant', password: 'secret'));

      await expectation;
      await bloc.close();
    });
  });
}

class _FakeMerchantLoginRepository implements MerchantLoginRepository {
  final DataState<UserInfoModel> result;

  String? username;
  String? password;

  _FakeMerchantLoginRepository({required this.result});

  @override
  Future<DataState<UserInfoModel>> login({
    required String username,
    required String password,
  }) async {
    this.username = username;
    this.password = password;
    return result;
  }
}

class _ThrowingMerchantLoginRepository implements MerchantLoginRepository {
  final DioException error;

  _ThrowingMerchantLoginRepository(this.error);

  @override
  Future<DataState<UserInfoModel>> login({
    required String username,
    required String password,
  }) async {
    throw error;
  }
}

final _userInfo = _userInfoWithResponse('00');

UserInfoModel _userInfoWithResponse(
  String responseCode, {
  String message = 'Success',
}) {
  return UserInfoModel(
    firstName: 'Test',
    lastName: 'Merchant',
    userName: 'merchant_user',
    email: 'merchant@example.com',
    shopName: 'Merchant Shop',
    responseCode: responseCode,
    responseMessage: message,
    instId: 'OMAIND',
    custId: '1',
    role: 'MERCHANT USER',
    roleId: 1,
    productId: 1,
    productName: 'NanoPay',
    deviceType: 'MOBAPP',
    merchantId: '651010000022371',
    acqMerchantId: '651010000022371',
    bearerToken: 'token',
    passFlag: true,
    checker: false,
    cid: '',
    userRoleType: 'MERCHANT',
    isChecker: false,
    twoFAOTPTimer: 0,
    dashboardEnabled: 'Y',
    twoFARequired: false,
    userType: 'merchant',
    terminalId: '',
    merchantIds: const {},
    merchantInfoForDashboard: const [],
  );
}

