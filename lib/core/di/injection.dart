import 'package:get_it/get_it.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Theme Cubit
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
