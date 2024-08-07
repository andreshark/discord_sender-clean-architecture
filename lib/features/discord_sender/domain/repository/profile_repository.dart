import 'dart:typed_data';
import 'package:discord_sender/core/resources/data_state.dart';
import 'package:discord_sender/features/discord_sender/domain/entities/profile.dart';

abstract class ProfileRepository {
  // API methods
  Future<DataState<ProfileEntity>> getProfileData(String token);

  Future<DataState<Uint8List>> loadAvatar(
      String token, String avatarId, String profileId);
}
