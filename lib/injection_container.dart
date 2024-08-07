import 'package:discord_sender/core/log_output.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/discord_api_service.dart';
import 'package:discord_sender/features/discord_sender/data/repository/guild_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/data/repository/message_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/data/repository/profile_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_channel.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_guild_channels.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_guilds.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/get_profile_data.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/load_avatar.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/load_guild_icon.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/send_message.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/logs/logs_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/theme/theme.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/local/app_data_service_impl.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/keyauth_api_service.dart';
import 'package:discord_sender/features/discord_sender/data/repository/app_data_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/data/repository/auth_repository_impl.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/check_license.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/close_app.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/load_data.dart';
import 'package:discord_sender/features/discord_sender/domain/usecases/save_data.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/auth/auth_bloc.dart';
import 'package:discord_sender/features/discord_sender/presentation/bloc/local_data/local_data_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'config/routes.dart';
import 'features/discord_sender/data/models/keyauth.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies(
    GlobalKey<NavigatorState> rootNavigatorKey) async {
  //routes
  sl.registerLazySingleton<GoRouter>(
      () => AppRoutes.onGenerateRoutes(rootNavigatorKey));

  // Dio
  sl.registerSingleton<Dio>(Dio());

  //// Dependencies
  // services
  sl.registerSingleton<KeyauthApiService>(KeyauthApiService(sl()));
  sl.registerSingleton<DiscordApiService>(DiscordApiService(sl()));
  sl.registerSingleton<DiscordAvatarService>(DiscordAvatarService(sl()));
  sl.registerSingleton<AppDataServiceImpl>(AppDataServiceImpl());

  //models
  sl.registerSingleton<KeyauthModel>(KeyauthModel());

  // repositories
  sl.registerSingleton<AuthRepositoryImpl>(AuthRepositoryImpl(sl(), sl()));
  sl.registerSingleton<AppDataRepositoryImpl>(
      AppDataRepositoryImpl(sl(), sl()));
  sl.registerSingleton<ProfileRepositoryImpl>(
      ProfileRepositoryImpl(sl(), sl()));
  sl.registerSingleton<MessageRepositoryImpl>(MessageRepositoryImpl(sl()));
  sl.registerSingleton<GuildRepositoryImpl>(GuildRepositoryImpl(sl(), sl()));

  //UseCases
  sl.registerSingleton<CheckLicenseUseCase>(CheckLicenseUseCase(sl(), sl()));
  sl.registerFactory<SendMessageUseCase>(() => SendMessageUseCase(sl()));
  sl.registerSingleton<LoadDataUseCase>(LoadDataUseCase(sl()));
  sl.registerSingleton<GetProfileDataUseCase>(GetProfileDataUseCase(sl()));
  sl.registerSingleton<GetChannelUseCase>(GetChannelUseCase(sl()));
  sl.registerSingleton<GetGuildsUseCase>(GetGuildsUseCase(sl()));
  sl.registerSingleton<SaveDataUseCase>(SaveDataUseCase(sl()));
  sl.registerSingleton<LoadAvatarUseCase>(LoadAvatarUseCase(sl()));
  sl.registerSingleton<GetGuildChannelsUseCase>(GetGuildChannelsUseCase(sl()));
  sl.registerSingleton<CloseAppUseCase>(CloseAppUseCase(sl(), sl()));
  sl.registerSingleton<LoadGuildIConUseCase>(LoadGuildIConUseCase(sl()));

  //Blocs
  sl.registerSingleton<LocalDataBloc>(LocalDataBloc(sl(), sl(), sl()));
  sl.registerSingleton<AuthBloc>(AuthBloc(sl()));
  sl.registerSingleton<AppTheme>(AppTheme());
  sl.registerSingleton<LogsCubit>(LogsCubit());

  //logs
  sl.registerSingleton<Logger>(Logger(output: LogsOutput(cubit: sl())));
}
