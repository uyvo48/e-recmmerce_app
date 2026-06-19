import 'package:e_commerce_app/feature/authen/data/datasource/auth_datasource_impl.dart';
import 'package:e_commerce_app/feature/authen/data/repository_impl/auth_repository_impl.dart';
import 'package:e_commerce_app/feature/authen/domain/usecase/log_up_usecase.dart';
import 'package:e_commerce_app/feature/authen/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce_app/feature/authen/presentation/screen/logup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = AuthDataSourceImpl();
    final repository = AuthRepositoryImpl(dataSource: dataSource);
    final logUpUseCase = LogUpUseCase(repository: repository);

    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => AuthBloc(logUpUseCase: logUpUseCase),
        child: const LogUpScreen(),
      ),
    );
  }
}
