import 'package:e_commerce_app/feature/authen/presentation/bloc/auth_bloc.dart';
import 'package:e_commerce_app/feature/authen/presentation/screen/login_screen.dart';
import 'package:e_commerce_app/feature/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'injection_contaner.dart';

void main() {
  setUpDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => GetIt.instance<AuthBloc>(),
        ),
        BlocProvider<CartCubit>(
          create: (context) => GetIt.instance<CartCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'E-Commerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
