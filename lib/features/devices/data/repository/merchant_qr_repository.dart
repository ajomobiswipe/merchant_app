import 'package:anet_merchants/features/devices/data/models/vpa_qr_parser.dart';
import 'package:anet_merchants/features/devices/data/models/vpa_qr_request_model.dart';
import 'package:anet_merchants/features/shared/data/data_sources/ui_api_service.dart';

class MerchantQrRepository {
  static const int _pageSize = 200;
  static const int _maxPages = 5;

  final MerchantUiApiService apiService;

  MerchantQrRepository({required this.apiService});

  Future<List<VpaQrItem>> getVpaAndQrData({
    required String merchantId,
    required String bearerToken,
    required String clientUniqueId,
  }) async {
    final authorization = _authorizationHeader(bearerToken);
    final request = VpaQrRequestModel(merchantId: merchantId);
    final allItems = <VpaQrItem>[];
    var totalElements = 0;

    for (var page = 0; page < _maxPages; page++) {
      final httpResponse = await apiService.getListOfVpaAndQrData(
        authorization,
        clientUniqueId,
        request,
        pageNumber: page,
        size: _pageSize,
      );

      if (httpResponse.response.statusCode != 200) {
        throw Exception(httpResponse.response.statusMessage);
      }

      final pageData = httpResponse.data.pageData;
      allItems.addAll(pageData.content);
      totalElements = pageData.totalElements;

      final reachedEnd = pageData.last ||
          pageData.empty ||
          pageData.content.isEmpty ||
          (totalElements > 0 && allItems.length >= totalElements);
      if (reachedEnd) {
        break;
      }
    }

    final seen = <String>{};
    return [
      for (final item in allItems)
        if (seen.add(item.vpa)) item,
    ];
  }

  String _authorizationHeader(String bearerToken) {
    if (bearerToken.startsWith('Bearer ')) {
      return bearerToken;
    }

    return 'Bearer $bearerToken';
  }
}
