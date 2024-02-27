import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/models/login/sales_team_login_model.dart';
import 'package:sifr_latest/services/user_services.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/providers.dart';
import '../../../storage/secure_storage.dart';
import '../../../widgets/app/alert_service.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/patternWidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //LoginRequestModel requestModel = LoginRequestModel();
  SalesTeamLoginModel requestModel = SalesTeamLoginModel();
  UserServices userServices = UserServices();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  String password = "Password";
  String pin = "PIN";
  var keyboardType = TextInputType.text;
  final FocusNode _focusNode = FocusNode();
  late PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  // VARIABLE DECLARATION
  late bool _isLoading = false;
  bool hidePassword = true;
  bool isFinished = false;
  final List<bool> _activeToggleMenu = [true, false];
  AlertService alertWidget = AlertService();
  final Uri _url = Uri.parse('https://sifr.ae/privacy.html');
  final Uri _url1 = Uri.parse('https://sifr.ae/terms.html');
  bool isChecked = false;

  @override
  void initState() {
    DevicePermission().checkPermission();
    _initPackageInfo();
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: _isLoading
            ? const LoadingWidget()
            : BackgroundPattern(
                childData: childData(),
              ));
  }

  childData() {
    return Center(
        child: Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Image.asset('assets/logo/logo2.png',
          //         height: 30, fit: BoxFit.fill),
          //     Text("App Version ${_packageInfo.version.toString()}"),
          //   ],
          // ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'userType', (route) => false);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              const SizedBox(height: 20),
            ],
          ),
          // Align(
          //   alignment: Alignment.center,
          //   child: Text(
          //     "Login to your Account",
          //     textAlign: TextAlign.center,
          //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          //         fontSize: 25,
          //         fontWeight: FontWeight.bold,
          //         decoration: TextDecoration.none),
          //   ),
          // ),
          const SizedBox(height: 10),
          //Image.asset(Constants.omaLogo, height: 100, fit: BoxFit.fill),
          Image.asset("assets/screen/anet.png", height: 100, fit: BoxFit.fill),
          const SizedBox(height: 20),
          // toggledButton(),
          const SizedBox(height: 10),
          userNameField(),
          const SizedBox(height: 10),
          passwordField(),
          const SizedBox(height: 10.0),
          //login(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            //forgotUserName(),
            Checkbox(
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),

            CustomTextWidget(
              text: "Remember me", fontWeight: FontWeight.bold,
              // color: AppColors.kPrimaryColor,
            ),
            const Expanded(child: SizedBox()),
            forgotPassword(),
          ]),
          const SizedBox(height: 10),
          CustomAppButton(
            title: 'Log In',
            onPressed: () {
              //Navigator.pushNamed(context, 'MerchantNumVerify');
              submitLoginForm();
            },
          ),
          // swipeButton(),

          const SizedBox(height: 10),
          CustomTextWidget(
            text: '--- Or ---',
            size: 22,
          ),
          const SizedBox(height: 10),
          CustomTextWidget(
            text: 'Connect With',
            size: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                flex: 4,
                child: SizedBox(),
              ),
              connectWithOptions(
                  icon: const Icon(
                    Icons.phone,
                    color: Colors.white,
                  ),
                  title: 'Phone'),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              connectWithOptions(
                  icon: const Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                  title: 'E-mail'),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              connectWithOptions(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                  ),
                  title: 'Other'),
              const Expanded(
                flex: 4,
                child: SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          copyRightWidget(),
        ],
      ),
    ));
  }

  Column connectWithOptions(
      {required Widget icon, required String title, Function()? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
              backgroundColor: AppColors.kPrimaryColor, child: icon),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        )
      ],
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      setLoading(true);
      _formKey.currentState!.save();
      //requestModel.instId = Constants.instId;
      requestModel.deviceType = Constants.deviceType;
      // requestModel.deviceId =
      //     await Validators.encrypt(await Global.getUniqueId());
      // password == 'Password'
      //     ? requestModel.pin = null
      //     : requestModel.password = null;
      // if (password == 'Password') {
      //   requestModel.pin = null;
      //   requestModel.password =
      //       await Validators.encrypt(requestModel.password.toString());
      // } else {
      //   requestModel.password = null;
      //   requestModel.pin =
      //       await Validators.encrypt(requestModel.pin.toString());
      // }
      print(json.encode(requestModel));

      _passwordController.clear();
      userServices.salesTeamlogin(requestModel).then((response) async {
        print(response.body);

        var result = jsonDecode(response.body);

        var code = response.statusCode;
        if (code == 200 || code == 201) {
          if (result['responseCode'] == "00") {
            saveSecureStorage(result,userName: requestModel.userName);
            Navigator.pushReplacementNamed(context, 'MerchantNumVerify');
            setLoading(false);
          } else if (result['responseCode'] == "03") {
            setLoading(false);
            alertWidget.failure(context, 'Failure', result['responseMessage']);
            // Navigator.pushReplacementNamed(context, "loginAuthOtp");
            Navigator.pushNamed(context, 'loginAuthOtp',
                arguments: {'userDetails': json.encode(requestModel)});
            // Navigator.pushReplacementNamed(context, 'home');
          } else {
            setLoading(false);

           try{
             alertWidget.failure(context, 'Failure', result['responseMessage']);
           }catch(e){
             alertWidget.failure(context, 'Failure', 'Wrong Credentials');
           }


          }
        } else {
          setLoading(false);
          alertWidget.failure(context, 'Failure', result['message']);
        }
      });
    }
  }

  saveSecureStorage(decodeData,{String? userName}) async {
    /// NEW HIVE STORAGE CONTROLS
    var datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String dateStr = datetime.toString();
    BoxStorage secureStorage = BoxStorage();
    secureStorage.saveUserDetails(decodeData);
    secureStorage.save('lastLogin', dateStr);
    secureStorage.save('isLogged', true);
    // secureStorage.save('notificationToken', decodeData.notificationToken);
    if (decodeData['role'].toString() == "MERCHANT") {
      secureStorage.save('merchantStatus', decodeData['status'].toString());
    }

    /// OLD Shared Preferences STORAGE CONTROLS
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', decodeData['bearerToken'].toString());

    // prefs.setString('userName', decodeData['userName'].toString());
    prefs.setString('userName', userName!);


    prefs.setString('role', decodeData['role'].toString());
    prefs.setString('lastLogin', dateStr);
    prefs.setBool('isLogged', true);
    prefs.setString('custId', decodeData['custId'].toString());
    if (decodeData['role'].toString() == "MERCHANT") {
      prefs.setString('merchantId', decodeData['merchantId'].toString());
      prefs.setString('terminalId', decodeData['terminalId'].toString());
      prefs.setString(
          'kycExpiryAlertMsg', decodeData['kycExpiryAlertMsg'].toString());
    }
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  toggledButton() {
    return Center(
      child: Container(
        height: 45,
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border.all(width: 1.5, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(50)),
        child: ToggleButtons(
          borderWidth: 2,
          borderColor: Colors.white,
          selectedBorderColor: Colors.white,
          borderRadius: BorderRadius.circular(50),
          tapTargetSize: MaterialTapTargetSize.padded,
          color: Theme.of(context).primaryColor,
          fillColor: Theme.of(context).primaryColor,
          selectedColor: Colors.white,
          splashColor: Theme.of(context).primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          renderBorder: true,
          onPressed: (int index) {
            if (index == 1) {
              Navigator.pushNamed(context, 'role');
              // Navigator.pushNamed(context, 'signUp');
            }
          },
          isSelected: _activeToggleMenu,
          children: const <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 14),
                )),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  "SignUp",
                  style: TextStyle(fontSize: 14),
                )),
          ],
        ),
      ),
    );
  }

  userNameField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: CustomTextWidget(
              text: "Username",
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
              keyboardType: TextInputType.text,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13,fontFamily: 'Mont'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\w'))
              ],
              decoration: InputDecoration(
                hintText: 'Username',
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 16),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                fillColor:
                    AppColors.kTileColor, // Set the background color here
                filled: true,
                hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13 // Set the hint text color here
                    ),
                // prefixIcon: Icon(Icons.verified_user_rounded,
                //     size: 25, color: Theme.of(context).primaryColor),
              ),
              onSaved: (value) {
                requestModel.userName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Username!';
                }
                if (value.length < 3) {
                  return 'Minimum character length is 3';
                }
                if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_.]+[a-zA-Z0-9]$')
                    .hasMatch(value)) {
                  return 'Invalid username!';
                }

                return null;
              }),
        ],
      ),
    );
  }

  passwordField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: CustomTextWidget(
              text: "Password",
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: _passwordController,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13,fontFamily: 'Mont'),
            obscureText: hidePassword,
            obscuringCharacter: '*',
            maxLength: password != 'Password' ? 4 : null,
            focusNode: _focusNode,
            keyboardType: keyboardType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onSaved: (value) {
              requestModel.password = value;
              // : requestModel.pin = value;
              // password == 'Password'
              //     ? requestModel.password = value
              //     : requestModel.pin = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $password!';
              }
              if (password == 'Password') {
                // if (!Validators.isPassword(value)) {
                //   return Constants.passwordError;
                // }
              } else {
                if (value.length != 4) {
                  return 'Login PIN must be 4 digits';
                }
                if (Validators.isConsecutive(value) != -1) {
                  return 'Login PIN should not be consecutive digits.';
                }
              }

              return null;
            },
            inputFormatters: <TextInputFormatter>[
              password != 'Password'
                  ? FilteringTextInputFormatter.digitsOnly
                  : FilteringTextInputFormatter.singleLineFormatter
            ],
            decoration: InputDecoration(
              hintText: 'Password',
              labelStyle:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              fillColor: AppColors.kTileColor,
              filled: true,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  login() {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          _passwordController.clear();
          setState(() {
            if (password == 'Password') {
              _focusNode.unfocus();
              keyboardType = TextInputType.number;
              Future.delayed(const Duration(milliseconds: 150)).then((value) {
                _focusNode.requestFocus();
              });
            } else {
              _focusNode.unfocus();
              keyboardType = TextInputType.text;
              Future.delayed(const Duration(milliseconds: 150)).then((value) {
                _focusNode.requestFocus();
              });
            }
            password == 'Password' ? password = 'PIN' : password = 'Password';
            pin == 'PIN' ? pin = 'Password' : pin = 'PIN';
          });
        },
        child: Text(
          "Login using $pin",
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  forgotPassword() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, 'forgotPassword');
      },
      child: const CustomTextWidget(
        text: "Forgot Password?",
        color: AppColors.kPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      // Text("Forgot $password?",
      //     style: Theme.of(context)
      //         .textTheme
      //         .bodyLarge
      //         ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  forgotUserName() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, 'forgotUserName');
      },
      child: Text("Forgot Username?",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  swipeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 8,
      ),
      child: SwipeButton.expand(
        elevationThumb: 5,
        elevationTrack: 5,
        duration: const Duration(milliseconds: 100),
        thumb: const Icon(
          Icons.double_arrow_rounded,
          color: Colors.white,
        ),
        activeThumbColor: Theme.of(context).primaryColor,
        activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.7),
        onSwipe: () {
          submitLoginForm();
        },
        child: const Text(
          "Swipe to Login",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
