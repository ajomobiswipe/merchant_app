import 'package:dio/dio.dart';
import 'package:anet_merchants/features/auth/data/models/login_request_model.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:retrofit/retrofit.dart';

part 'merchant_login_api_service.g.dart';

@RestApi()
abstract class MerchantLoginApiService {
  factory MerchantLoginApiService(Dio dio, {String baseUrl}) =
      _MerchantLoginApiService;

  @POST('login')
  Future<HttpResponse<UserInfoModel>> login(
    @Body() LoginRequestModel request,
  );
}

