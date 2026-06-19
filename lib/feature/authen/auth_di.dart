import 'package:dio/dio.dart';
import 'package:e_commerce_app/feature/product/data/datasource/product_datasource.dart';
import 'package:e_commerce_app/feature/product/data/datasource/product_datasource_impl.dart';
import 'package:e_commerce_app/feature/product/data/repository_impl/product_repository_impl.dart';
import 'package:e_commerce_app/feature/product/domain/repository/product_repository.dart';
import 'package:e_commerce_app/feature/product/domain/usecase/get_products_usecase.dart';
import 'package:e_commerce_app/feature/product/presentation/cubit/product_cubit.dart';
import 'package:get_it/get_it.dart';

import 'data/datasource/auth_datasource.dart';
import 'data/datasource/auth_datasource_impl.dart';
import 'data/repository_impl/auth_repository_impl.dart';
import 'domain/repository/auth_repository.dart';
import 'domain/usecase/log_up_usecase.dart';
import 'domain/usecase/login_usecase.dart';
import 'domain/usecase/logout_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

void authDi() {
  final sl = GetIt.instance;

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://ecommerce.routemisr.com/api/v1',
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Content-Type': 'application/json'},
        ),
      ),
    );
  }

  //data
  if (!sl.isRegistered<AuthDataSource>()) {
    sl.registerLazySingleton<AuthDataSource>(
      () => AuthDataSourceImpl(
        dio: sl(),
        loginDio: Dio(
          BaseOptions(
            baseUrl: 'https://api.escuelajs.co/api/v1',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        ),
      ),
    );
  }

  // repository
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(dataSource: sl()),
    );
  }

  // usecase
  if (!sl.isRegistered<LogUpUseCase>()) {
    sl.registerLazySingleton<LogUpUseCase>(
      () => LogUpUseCase(repository: sl()),
    );
  }

  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(repository: sl()),
    );
  }

  if (!sl.isRegistered<LogoutUseCase>()) {
    sl.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(repository: sl()),
    );
  }

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(),
    );
  }

  if (!sl.isRegistered<ProductCubit>()) {
    sl.registerFactory<ProductCubit>(
      () => ProductCubit(getProductsUseCase: sl()),
    );
  }

  if (!sl.isRegistered<ProductDataSource>()) {
    sl.registerLazySingleton<ProductDataSource>(
      () => ProductDataSourceImpl(dio: sl()),
    );
  }

  if (!sl.isRegistered<ProductRepository>()) {
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(dataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetProductsUseCase>()) {
    sl.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(repository: sl()),
    );
  }
}
