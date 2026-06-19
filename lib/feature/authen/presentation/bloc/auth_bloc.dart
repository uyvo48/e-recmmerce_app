import 'package:bloc/bloc.dart';
import 'package:e_commerce_app/feature/authen/domain/usecase/log_up_usecase.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogUpUseCase logUpUseCase;

  AuthBloc({required this.logUpUseCase}) : super(AuthInitial()) {
    on<LogUpSubmitted>(_onLogUpSubmitted);
  }

  Future<void> _onLogUpSubmitted(
    LogUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      _validate(event);
      await logUpUseCase(
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
