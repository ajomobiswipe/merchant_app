part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  final UserInfoModel? userinfo;
  final DioException? error;

  const AuthState({
    this.userinfo,
    this.error,
  });

  @override
  List<Object?> get props => [
        userinfo,
        error,
      ];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  const AuthSuccess({
    required UserInfoModel userinfo,
  }) : super(userinfo: userinfo);
}

class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({
    required UserInfoModel userinfo,
  }) : super(userinfo: userinfo);
}

class AuthPasswordResetRequired extends AuthState {
  final String username;
  final String message;

  const AuthPasswordResetRequired({
    required this.username,
    required this.message,
    required UserInfoModel userinfo,
  }) : super(userinfo: userinfo);

  @override
  List<Object?> get props => [
        ...super.props,
        username,
        message,
      ];
}

class AuthFailure extends AuthState {
  const AuthFailure({
    required DioException error,
  }) : super(error: error);
}
