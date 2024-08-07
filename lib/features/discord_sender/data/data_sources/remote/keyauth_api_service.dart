import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../../../../../core/constants.dart';
part 'keyauth_api_service.g.dart';

@RestApi(baseUrl: keyauthAPIBaseURL)
abstract class KeyauthApiService {
  factory KeyauthApiService(Dio dio) = _KeyauthApiService;

  @GET(
      '?type=init&ver={version}&name={name}&ownerid={ownerId}&hash={checksum}&enckey={sentKey}')
  @Headers(<String, dynamic>{'User-Agent': 'Apidog/1.0.0 (https://apidog.com)'})
  Future<HttpResponse> init({
    @Path('version') required String version,
    @Path('name') required String name,
    @Path('ownerId') required String ownerId,
    @Path('checksum') required String checksum,
    @Path('sentKey') required String sentKey,
  });

  @GET(
      '?type=license&key={key}&hwid={hwid}&sessionid={session}&name={name}&ownerid={ownerId}')
  @Headers(<String, dynamic>{'User-Agent': 'Apidog/1.0.0 (https://apidog.com)'})
  Future<HttpResponse> checkLicense({
    @Path('key') required String key,
    @Path('hwid') required String hwid,
    @Path('session') required String session,
    @Path('name') required String name,
    @Path('ownerId') required String ownerId,
  });

  @GET('?type=check&sessionid={session}&name={name}&ownerid={ownerId}')
  @Headers(<String, dynamic>{'User-Agent': 'Apidog/1.0.0 (https://apidog.com)'})
  Future<HttpResponse> checkSession({
    @Path('session') required String session,
    @Path('name') required String name,
    @Path('ownerId') required String ownerId,
  });

  @GET('?type=logout&sessionid={session}&name={name}&ownerid={ownerId}')
  @Headers(<String, dynamic>{'User-Agent': 'Apidog/1.0.0 (https://apidog.com)'})
  Future<HttpResponse> closeSession({
    @Path('session') required String session,
    @Path('name') required String name,
    @Path('ownerId') required String ownerId,
  });
}
