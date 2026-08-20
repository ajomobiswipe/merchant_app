import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:anet_merchants/features/auth/domain/usecases/user_login.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserLogin _userLogin;

  AuthBloc(this._userLogin) : super(AuthInitial()) {
    on<LoginPressed>((event, emit) async {
      if (emit.isDone) return;
      emit(AuthLoading());

      try {
        final dataState = await _userLogin(
          params: UserLoginParams(
            username: event.username,
            password: event.password,
          ),
        );

        if (emit.isDone) return;

        if (dataState is DataSuccess<UserInfoModel>) {
          final userInfo = dataState.data!;

          if (userInfo.responseCode == '04') {
            emit(
              AuthPasswordResetRequired(
                userinfo: userInfo,
                username: event.username,
                message: userInfo.responseMessage,
              ),
            );
            return;
          }

          if (!userInfo.isLoginSuccess) {
            emit(
              AuthFailure(
                error: DioException(
                  requestOptions: RequestOptions(path: 'login'),
                  message: userInfo.responseMessage,
                  type: DioExceptionType.badResponse,
                ),
              ),
            );
            return;
          }

          if (userInfo.isOtpRequired) {
            emit(AuthOtpRequired(userinfo: userInfo));
            return;
          }

          emit(AuthSuccess(userinfo: userInfo));
          return;
        }

        if (dataState is DataFailed) {
          emit(AuthFailure(error: dataState.error!));
        }
      } on DioException catch (e) {
        if (emit.isDone) return;
        emit(AuthFailure(error: e));
      }
    });
  }
}

