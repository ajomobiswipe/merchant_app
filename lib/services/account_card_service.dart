/* ===============================================================
| Project : SIFR
| Page    : ACCOUNT_CARD_SERVICE.DART
| Date    : 23-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import '../config/endpoints.dart';
import '../models/models.dart';
import 'connection.dart';

class AccountCardService {
  /*
  * SERVICE NAME: loadAccountAndCard
  * DESC: Fetch Account And Card Details
  * METHOD: GET
  * Params: userName
  * to pass token in Headers
  */
  loadAccountAndCard(userName) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.accountCardList + userName;
    var response = await connection.get(url);
    return response;
  }

  /*
  * SERVICE NAME: saveAccountsCard
  * DESC: Save Account And Card Details
  * METHOD: POST
  * Params: AccountRequestModel/CardRequestModel
  * to pass token in Headers
  */
  saveAccountsCard(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.saveAccountCard;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: verifyAccountsCard
  * DESC: Verify Account And Card Details
  * METHOD: POST
  * Params: cardManageRequestModel/AccountRequestModel
  * to pass token in Headers
  */
  verifyAccountsCard(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.verifyAccountCard;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: linkAccountsCard
  * DESC: Link Account And Card Details
  * METHOD: POST
  * Params: cardManageRequestModel/AccountRequestModel
  * to pass token in Headers
  */
  linkAccountsCard(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.linkAccountCard;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: deLinkAccountsCard
  * DESC: De-Link Account And Card Details
  * METHOD: POST
  * Params: cardManageRequestModel/AccountRequestModel
  * to pass token in Headers
  */
  deLinkAccountsCard(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.deLinkAccountCard;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: swapCardToCard
  * DESC: Primary Card Swap Between Cards
  * METHOD: POST
  * Params: CardManageRequestModel
  * to pass token in Headers
  */
  swapCardToCard(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.cardToCard;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: swapCardToAccount
  * DESC: Primary Account Swap Between Card To Account
  * METHOD: POST
  * Params: AccountRequestModel
  * to pass token in Headers
  */
  swapCardToAccount(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.cardToAccount;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: swapAccountToAccount
  * DESC: Primary Account Swap Between Accounts
  * METHOD: POST
  * Params: AccountRequestModel
  * to pass token in Headers
  */
  swapAccountToAccount(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.accountToAccount;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: swapAccountToCard
  * DESC: Primary Account Swap Between Account To Card
  * METHOD: POST
  * Params: CardManageRequestModel
  * to pass token in Headers
  */
  swapAccountToCard(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9502 + EndPoints.accountToCard;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: checkBalance
  * DESC: Check Balance From Account/Card
  * METHOD: POST
  * Params: ViewBalance/BalanceCheck
  * to pass token in Headers
  */
  checkBalance(requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9503 + EndPoints.viewBalance;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: addMoneyToWallet
  * DESC: Add Money To Account Or Card
  * METHOD: POST
  * Params: AddMoneyModel
  * to pass token in Headers
  */
  addMoneyToWallet(AddMoneyModel requestModel) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9503 + EndPoints.addMoney;
    var response = await connection.post(url, requestModel);
    return response;
  }
}
