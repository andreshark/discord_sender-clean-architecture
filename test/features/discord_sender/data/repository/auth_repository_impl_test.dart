import 'package:dio/dio.dart';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/keyauth_api_service.dart';
import 'package:discord_sender/features/discord_sender/data/models/keyauth.dart';
import 'package:discord_sender/features/discord_sender/data/repository/auth_repository_impl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:retrofit/retrofit.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([KeyauthApiService])
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('KeyAuth', () {
    final keyAuthService = MockKeyauthApiService();
    final keyAuthModel = KeyauthModel();
    keyAuthModel.session = '';
    test('init test', () async {
      AuthRepositoryImpl authRep =
          AuthRepositoryImpl(keyAuthService, keyAuthModel);
      when(keyAuthService.checkLicense(
              key: any, hwid: any, session: any, name: any, ownerId: any))
          .thenAnswer((value) async => HttpResponse<dynamic>(
              {'success': 'true'},
              Response(statusCode: 200, requestOptions: RequestOptions())));

      when(keyAuthService.checkSession(
              session: 'session', name: 'name', ownerId: 'ownerId'))
          .thenAnswer((value) async => HttpResponse<dynamic>(
              {'success': 'true'},
              Response(statusCode: 200, requestOptions: RequestOptions())));

      final result = await authRep.checkLicense('key');

      debugPrint(result.data.toString());

      expect(result, isA<DataSuccess>);
    });
  });
}
