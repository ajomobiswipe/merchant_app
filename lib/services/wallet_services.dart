/* ===============================================================
| Project : SIFR
| Page    : WALLET_SERVICE.DART
| Date    : 23-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import '../config/config.dart';
import 'services.dart';

class WalletService {
  /*
  * SERVICE NAME: mPin
  * DESC: Check Whether Mpin Exist for User or Not
  * METHOD: POST
  * Params: instId,requestType and custId
  * to pass token in Headers
  */
  mPin(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.mPin;
    var response = await connection.post(url, requestModel);
    return response;
  }

  viewBalance() {}
}
