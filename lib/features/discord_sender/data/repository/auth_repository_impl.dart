import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:discord_sender/features/discord_sender/data/data_sources/remote/keyauth_api_service.dart';
import 'package:discord_sender/features/discord_sender/data/models/keyauth.dart';
import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../../../../core/resources/data_state.dart';
import 'package:uuid/v4.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final KeyauthApiService _keyauthApiService;
  final KeyauthModel _keyauthModel;

  const AuthRepositoryImpl(this._keyauthApiService, this._keyauthModel);

  @override
  Future<DataState> checkLicense(String key) async {
    try {
      final httpResponse = await _keyauthApiService.checkLicense(
          key: key,
          hwid: await _getHwid(),
          session: _keyauthModel.session!,
          name: _keyauthModel.name,
          ownerId: _keyauthModel.ownerId);

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        var response = httpResponse.data;
        if (!response['success']) {
          return DataFailedMessage(response['message']);
        }
        _keyauthModel.key = key;
        checkSession();
        return DataSuccess(key);
      } else {
        return DataFailed(DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions));
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<void> checkSession() async {
    Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      try {
        final httpResponse = await _keyauthApiService.checkSession(
            session: _keyauthModel.session!,
            name: _keyauthModel.name,
            ownerId: _keyauthModel.ownerId);

        if (httpResponse.response.statusCode == HttpStatus.ok) {
          var response = httpResponse.data;
          if (!response['success']) {
            debugPrint('сессия не активна');
            exit(0);
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    });
  }

  @override
  Future<void> closeSession() async {
    try {
      await _keyauthApiService.closeSession(
          session: _keyauthModel.session!,
          name: _keyauthModel.name,
          ownerId: _keyauthModel.ownerId);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<DataState> init() async {
    String message;
    if (_keyauthModel.session != null) {
      //String message = "You've already initialized!";
      return const DataSuccess(true);
    }

    String sentKey = const UuidV4().generate().toString().substring(0, 16);

    _keyauthModel.enckey = "$sentKey-${_keyauthModel.secret}";
    try {
      final httpResponse = await _keyauthApiService.init(
          version: _keyauthModel.version,
          sentKey: sentKey,
          checksum: await _getChecksum(),
          name: _keyauthModel.name,
          ownerId: _keyauthModel.ownerId);
      if (httpResponse.response.statusCode == HttpStatus.ok) {
        if (httpResponse.data == "KeyAuth_Invalid") {
          message = "The application doesn't exist";
        }

        Map<String, dynamic> response = httpResponse.data;

        if (response["message"] == "invalidver") {
          if (response["download"] != null) {
            message = "New Version Available  ${response["download"]}";
          } else {
            message =
                'Invalid Version, Contact owner to add download link to latest app version';
          }
          return DataFailedMessage(message);
        }

        if (!response['success']) {
          message = response['message'];
          return DataFailedMessage(message);
        }

        _keyauthModel.session = response['sessionid'];
        _keyauthModel.initialized = true;
        return const DataSuccess(true);
      } else {
        message = httpResponse.response.statusMessage.toString();
        return DataFailedMessage(message);
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  Future<String> _getChecksum() async {
    String path = Platform.script.toFilePath();
    path =
        '${path.substring(0, path.lastIndexOf('\\') + 1)}lib\\${path.substring(path.lastIndexOf('\\') + 1)}';
    if (!await File(path).exists()) {
      path = path.replaceFirst('lib\\main.dart', 'discord_sender.exe');
    }
    var degit = sha256.convert(File(path).readAsBytesSync());
    String value = degit.toString();
    return value;
    //return '1206b202d195a247befa70c774f0322e';
  }

  Future<String> _getHwid() async {
    if (Platform.isWindows) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final allInfo = deviceInfo.data['deviceId'].toString();
      final hwid = allInfo.substring(1, allInfo.length - 1);
      return hwid;
    }
    return '';
  }
}
