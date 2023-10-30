import '../config/endpoints.dart';
import 'connection.dart';

class NearByLocationServices {
  /*
  * SERVICE NAME: nearestGeoLocation
  * DESC: Find Merchant Geo Location By user current location
  * METHOD: POST
  * Params: NearByLocationRequest
  * to pass token in Headers
  */
  nearestGeoLocation(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.nearestLocation;
    var response = await connection.post(url, requestModel);
    return response;
  }
}
