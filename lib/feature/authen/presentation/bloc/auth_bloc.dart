import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/feature/authen/domain/usecase/log_up_usecase.dart';
import 'package:e_commerce_app/feature/authen/domain/usecase/login_usecase.dart';
import 'package:e_commerce_app/feature/authen/domain/usecase/logout_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LogUpSubmitted>(_onLogUpSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogUpSubmitted(
    LogUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final logUp = GetIt.instance<LogUpUseCase>();

      _validate(event);
      await logUp(
        event.name,
        event.email,
        event.password,
        event.rePassword,
        event.phone,
      );
      emit(AuthSuccess('Dang ky tai khoan thanh cong.'));
    } catch (error) {
      emit(AuthFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final loginUseCase = GetIt.instance<LoginUseCase>();
      await loginUseCase(event.email, event.password);
      emit(AuthSuccess('Dang nhap thanh cong.'));
    } catch (error) {
      emit(AuthFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final logOut = GetIt.instance<LogoutUseCase>();
      await logOut();
      emit(AuthLogoutSuccess('Dang xuat thanh cong.'));
    } catch (error) {
      emit(AuthFailure(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _validate(LogUpSubmitted event) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final phoneRegex = RegExp(r'^[0-9]{9,12}$');

    if (event.name.trim().isEmpty) {
      throw Exception('Vui long nhap ho ten.');
    }
    if (!emailRegex.hasMatch(event.email.trim())) {
      throw Exception('Email khong hop le.');
    }
    if (event.password.length < 6) {
      throw Exception('Mat khau phai co it nhat 6 ky tu.');
    }
    if (event.password != event.rePassword) {
      throw Exception('Mat khau nhap lai khong khop.');
    }
    if (!phoneRegex.hasMatch(event.phone.trim())) {
      throw Exception('So dien thoai khong hop le.');
    }
  }
}
