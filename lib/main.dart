import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'personal_info_screen.dart';
import 'my_shipments_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MyApp());
}

const appID = 'sharein_security_key_store_2022';
const appID2 = 'shareinAPPIDFOR-BOXPID189045026';
List countriesList = [];
int userId = 0;
String userLogin = '';
String userName = '';
String userCountry = '';
String userCountryCode = '';
String userCity = '';
String userPostalCode = '';
String userPhoneNumber = '';
Future<void> _getCountries() async {
  String apiUrl = "https://boxpid.com/backend/view/user/getCountries.php";
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'app-id': appID,
      },
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      countriesList = responseData['data'];
    } else {
      // Handle error
      final String errorMessage = responseData['NOTE'] ?? 'An error occurred';
      print(errorMessage);
    }
  } catch (e) {
    print('Something went wrong please try again later.');
  }
}


// text controllers
final TextEditingController _fromCountry = TextEditingController();
final TextEditingController _fromCountryId = TextEditingController();
final TextEditingController _fromCountryCode = TextEditingController();
final TextEditingController _fromCity = TextEditingController();
final TextEditingController _fromCityId = TextEditingController();

final TextEditingController _toCountry = TextEditingController();
final TextEditingController _toCountryId = TextEditingController();
final TextEditingController _toCountryCode = TextEditingController();
final TextEditingController _toCity = TextEditingController();
final TextEditingController _toCityId = TextEditingController();

final TextEditingController _fromPostalCode = TextEditingController();
final TextEditingController _toPostalCode = TextEditingController();

final TextEditingController _packageRealWeight = TextEditingController();
final TextEditingController _packageRealisticWeight = TextEditingController();
final TextEditingController _packageWidth = TextEditingController();
final TextEditingController _packageHeight = TextEditingController();
final TextEditingController _packageLength = TextEditingController();

final TextEditingController _receiverAgency = TextEditingController();
final TextEditingController _senderAgency = TextEditingController();

final TextEditingController _fullNameSender = TextEditingController();
final TextEditingController _emailSender = TextEditingController();
final TextEditingController _phoneNumberSender = TextEditingController();
final TextEditingController _addressSender = TextEditingController();

final TextEditingController _fullNameReceiver = TextEditingController();
final TextEditingController _emailReceiver = TextEditingController();
final TextEditingController _phoneNumberReceiver = TextEditingController();
final TextEditingController _addressReceiver = TextEditingController();

bool _senderWithAddress = false;
var isExport;
var isNationaly;
var isDocument;
var finalWeight = '';
var shipmentDelais = '';
var shipmentEstimatedDelivery = '';
var shipmentPriceTotal = '';
var sendUsingAddress;
var receiveUsingAddress;
final TextEditingController _pickupDate = TextEditingController();

final TextEditingController _pickupTimeFrom = TextEditingController();
final TextEditingController _pickupTimeTo = TextEditingController();
RangeValues pickUpTimeRangeValue = const RangeValues(9, 17);
DateTime selectedDate = DateTime.now();
final TextEditingController _contents = TextEditingController();
final TextEditingController _email = TextEditingController();
final TextEditingController _description = TextEditingController();
final TextEditingController _address = TextEditingController();

final TextEditingController _itemAmount = TextEditingController();
final TextEditingController _itemQuantity = TextEditingController();
final TextEditingController _itemNetValue = TextEditingController(); // Updated field
var lineItems = [
  {
    "number": 1,
    "description": "doc",
    "price": 10.0,
    "quantity": {
      "value": 1,
      "unitOfMeasurement": "GM"
    },
    "manufacturerCountry": "MA",
    "weight": {
      "netValue": 1,
      "grossValue": 1
    }
  }
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff92B61B),
          ),
          useMaterial3: true,
          primaryColor: const Color(0xff92B61B),
        ),
        home: const Runner()
    );
  }
}


class Runner extends StatefulWidget {
  const Runner({super.key});

  @override
  State<Runner> createState() => _RunnerState();
}

class _RunnerState extends State<Runner> {
  @override
  void initState() {
    super.initState();
    checkLoginSession();
    _getCountries();
  }

  Future<void> checkLoginSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userIdDt = prefs.getInt('user_id');
    final String? userLoginDt = prefs.getString('user_login');
    final String? userFullname = prefs.getString('user_fullname');
    final String? userPhone = prefs.getString('user_phonenumber');
    if(userFullname != null && userIdDt != null && userIdDt != 0 && userLoginDt != '' && userLoginDt != null && userFullname != '' && userPhone != null) {
      userId = userIdDt;
      userLogin = userLoginDt;
      userName = userFullname;
      userPhoneNumber = userPhone;
      Future.delayed(const Duration(seconds: 2)).then((val) {
        Navigator.of(context).push(
          CupertinoPageRoute<bool>(
            fullscreenDialog: false,
            builder: (BuildContext context) => const Home(),
          ),
        );
      });
    }else{
      Future.delayed(const Duration(seconds: 2)).then((val) {
        Navigator.of(context).push(
          CupertinoPageRoute<bool>(
            fullscreenDialog: false,
            builder: (BuildContext context) => const Login(),
          ),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xff92B61B),
          ),
          padding: const EdgeInsets.only(
            left: 150,
            right: 150,
          ),
          child: Image.asset(
            'assets/images/mainIcon.png',
            fit: BoxFit.fitWidth,
          ),
        )
    );
  }
}


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _emailForgotPass = TextEditingController();
  bool showPassword = false;
  String passwordIcon = "assets/icons/eye-Bold.png";

  Future<void> _login(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = "https://boxpid.com/backend/view/user/login.php";
    final navigator = Navigator.of(context);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID,
          'email-user': email,
          'password-user': password,
          'role-user': 'CLIENT'
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['NOTE'] == "OK") {
        var userID = responseData['users'][0]['id'];
        var userLogin = responseData['users'][0]['login'];
        var userPhone = responseData['users'][0]['phone_number'];
        var userFullname = responseData['users'][0]['last_name'] + ' ' + responseData['users'][0]['first_name'];
        await prefs.setInt('user_id', userID);
        await prefs.setString('user_login', userLogin);
        await prefs.setString('user_fullname', userFullname);
        await prefs.setString('user_phonenumber', userPhone);
        navigator.push(
          CupertinoPageRoute<bool>(
            fullscreenDialog: false,
            builder: (BuildContext context) => const Runner(),
          ),
        );
      } else {
        // Handle error
        final String errorMessage = responseData['NOTE'] ?? 'An error occurred';
        _showDialog(errorMessage, 'Error');
      }
    } catch (e) {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  Future<void> _forgotPassword(String email) async {
    String apiUrl = "https://boxpid.com/backend/view/user/resetPassword.php";
    final navigator = Navigator.of(context);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'app-id': appID, 'email-user': email},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Password reset request successful
        navigator.pop();
        _showDialog(
            'If an account with this email address exists, a password reset link will be sent. The link will expire in 24 hours for security reasons.',
            'Email Sent');
      } else {
        // Request failed, handle error
        navigator.pop();
        _showDialog('Something went wrong please try again later.', 'Error');
      }
    } catch (e) {
      // Exception thrown during password reset request
      navigator.pop();
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void openForgotPassword() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: const Text(
                  'Forgot password ?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: _emailForgotPass,
                    style: const TextStyle(fontSize: 18.0, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "example@example.com",
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                        const BorderSide(color: Colors.black38, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Image.asset(
                            "assets/icons/envelope-Bold.png",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      _forgotPassword(_emailForgotPass.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Verify",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Image.asset(
                                "assets/icons/arrow-right-Bold.png",
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.asset(
                  "assets/images/BoxpidLogoFull.png",
                  height: 60,
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: _email,
                    style: const TextStyle(fontSize: 18.0, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "example@example.com",
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                        const BorderSide(color: Colors.black38, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Image.asset(
                            "assets/icons/envelope-Bold.png",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: _password,
                    style: const TextStyle(fontSize: 18.0, color: Colors.black),
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "********",
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                        const BorderSide(color: Colors.black38, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Image.asset(
                            "assets/icons/lock-Bold.png",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          passwordIcon,
                          color: Colors.black38,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                            passwordIcon = showPassword
                                ? "assets/icons/eye-slash-Bold.png"
                                : "assets/icons/eye-Bold.png";
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      // Handle forgot password
                      openForgotPassword();
                    },
                    child: const Text(
                      "Forgot password?",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      _login(_email.text, _password.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Sign in",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Image.asset(
                                "assets/icons/arrow-right-Bold.png",
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _login(_email.text, _password.text);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute<bool>(
                          fullscreenDialog: false,
                          builder: (BuildContext context) => const SignUp(),
                        ),
                      );
                    },
                    child: const Text(
                      "Don't have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _documentId = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool showPassword = false;
  String passwordIcon = "assets/icons/eye-Bold.png";

  void _signUp() async {
    String apiUrl = "https://boxpid.com/backend/view/user/signup.php";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'login': _email.text.trim(),
          'firstName': _fullName.text.trim().split(' ').first,
          'lastName': _fullName.text.trim().split(' ').last,
          'password': _password.text.trim(),
          'phoneNumber': _phoneNumber.text.trim(),
          'country': 'N/A',
          'city': 'N/A',
          'dateOfBirth': 'N/A',
          'cin': _documentId.text.trim(),
          'docCinFront': 'N/A',
          'docCinBack': 'N/A',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['NOTE'] == "OK") {
        // Sign up successful
        _showDialog(responseData['message'], 'Success');
      } else {
        // Sign up failed, handle error
        final String errorMessage = responseData['NOTE'] ?? 'An error occurred';
        _showDialog(errorMessage, 'Error');
      }
    } catch (e) {
      // Exception thrown during sign up process
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            "assets/icons/chevron-left-Bold.png",
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    )),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _fullName,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Full name",
                        hintText: "John Fitzgerald",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: Image.asset(
                              "assets/icons/user-Bold.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _phoneNumber,
                      keyboardType: TextInputType.phone,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Phone number",
                        hintText: "(+000) 000-000-000",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: Image.asset(
                              "assets/icons/mobile-Bold.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _email,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "example@example.com",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: Image.asset(
                              "assets/icons/envelope-Bold.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _password,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      obscureText: showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "********",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: IconButton(
                                icon: Image.asset(
                                  passwordIcon,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (showPassword) {
                                      showPassword = false;
                                      passwordIcon =
                                      "assets/icons/eye-Bold.png";
                                    } else {
                                      showPassword = true;
                                      passwordIcon =
                                      "assets/icons/eye-slash-Bold.png";
                                    }
                                  });
                                },
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _documentId,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Document ID",
                        hintText: "EX909090",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: Image.asset(
                              "assets/icons/file-Bold.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                                text: 'By clicking Sign Up, you agree to our ',
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print('Terms of Service"');
                                  }),
                            const TextSpan(
                                text: ' and that you have read our ',
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print('Privacy Policy"');
                                  }),
                          ],
                        ),
                      ),
                    )),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_email.text.isNotEmpty &&
                            _fullName.text.isNotEmpty &&
                            _password.text.isNotEmpty &&
                            _phoneNumber.text.isNotEmpty &&
                            _documentId.text.isNotEmpty) {
                          _signUp();
                        } else {
                          _showDialog(
                              'You have to provide a value for a the required fields.',
                              'Required fields');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Sign up",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _searchTrackingNumber = TextEditingController();

  late Map<String, dynamic> userData;


  @override
  void initState() {
    super.initState();
    getAddressFromLatLng();

    userData = {
      'fullName': 'User Name', // Replace with actual data
      'email': 'user@example.com',
      'phone': '+212600000000',
      'documentId': 'AB123456',
      'city': 'Casablanca'
    };
  }

  void getAddressFromLatLng() async {
    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

      // Get the placemarks from the coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      // Extract the relevant information
      Placemark place = placemarks[0];
      String country = place.country ?? 'Not allowed';
      String countryCode = place.isoCountryCode ?? 'Not allowed';
      String city = place.locality ?? 'Not allowed';
      String postalCode = place.postalCode ?? 'Not allowed';

      print('Country: $country');
      print('City: $city');
      print('Postal Code: $postalCode');
      print('Postal Code: $countryCode');
      setState((){
        userCountry = country;
        userCountryCode = countryCode;
        userCity = city;
        userPostalCode = postalCode;
      });
    } catch (e) {
      print('Failed to get address: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          userCountry,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: Image.asset(
            "assets/icons/menu-Bold.png",
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => _key.currentState!.openDrawer(),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Image.asset(
              "assets/icons/bell-Bold.png",
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset(
              "assets/icons/user-Bold.png",
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              if (userData != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalInfoScreen(userData: userData!),
                  ),
                );
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User data not loaded')),
                  );
              }
              },
            ),
          ],
      ),
      drawer: Drawer(
          backgroundColor: Theme.of(context).primaryColor,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                              BorderSide(color: Colors.white, width: 2.0))),
                      margin: const EdgeInsets.only(
                          bottom: 8.0, left: 15.0, right: 15.0),
                      accountName: Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      accountEmail: Text(
                        userLogin,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      currentAccountPicture: Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white),
                        child: (() {
                          if (true) {
                            return Text(userName[0],
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor));
                          } else {
                            return Image.asset(
                              "assets/images/person",
                              fit: BoxFit.contain,
                            );
                          }
                        }()),
                      ),
                    ),
                    ListTile(
                      leading: Image.asset(
                        "assets/icons/package-Bold.png",
                        color: Colors.white,
                      ),
                      title: const Text(
                        'My shipments',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            MyShipmentsPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        "assets/icons/phone-Bold.png",
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Support',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Image.asset(
                        "assets/icons/shield-Bold.png",
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Image.asset(
                        "assets/icons/giftbox-Bold.png",
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Advertising space',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Image.asset(
                        "assets/icons/copy-Bold.png",
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Address book',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Image.asset(
                        "assets/icons/settings-Bold.png",
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Settings',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {},
                    )
                  ],
                ),
              ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: ListTile(
            leading: Image.asset(
              "assets/icons/log-out-Bold.png",
              color: Colors.white,
            ),
            title: const Text(
              'Log out',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            onTap: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                // Clear any user session data here if needed
                // For example: await AuthService.logout();

                // Navigate back to SignUp page and remove all routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignUp()),
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        )
            ],
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 20, left: 15, right: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context).primaryColor),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: const Text(
                                  "Track your shipment",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                width: MediaQuery.of(context).size.width,
                                child: TextField(
                                  controller: _searchTrackingNumber,
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  keyboardType: TextInputType.multiline,
                                  style: const TextStyle(
                                      fontSize: 17.0, color: Colors.black),
                                  decoration: InputDecoration(
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 10.0),
                                      hintText: "Enter your tracking number",
                                      border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 1)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: InkWell(
                                            onTap: () {},
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                              child: Image.asset(
                                                "assets/icons/search-Bold.png",
                                                color: Colors.white,
                                              ),
                                            ),
                                          ))),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/illustrations/Home.png",
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ],
                        ))),
                Flexible(
                  child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                        bottom: 30,
                      ),
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 20, left: 15, right: 15),
                      decoration: BoxDecoration(
                          color: const Color(0xffF5F6F9),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Column(
                        children: [
                          Text(
                            'What would you like to do today ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black87
                            ),
                          ),
                          Text(
                            'Tap one of the options to start.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Colors.black87
                            ),
                          )
                        ],
                      )
                  ),
                ),
                Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          if(isExport != true && isExport != true)...[
                            Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState((){
                                      isExport = false;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    padding: const EdgeInsets.only(top: 20, bottom: 60),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffF5F6F9),
                                        borderRadius: BorderRadius.circular(15)),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.only(
                                                left: 30, right: 30),
                                            child: Image.asset(
                                              "assets/illustrations/importilu.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(top: 10),
                                              child: const Text(
                                                "Receive",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                            Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState((){
                                      isExport = true;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    padding: const EdgeInsets.only(top: 20, bottom: 60),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffF5F6F9),
                                        borderRadius: BorderRadius.circular(15)),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.only(
                                                left: 30, right: 30),
                                            child: Image.asset(
                                              "assets/illustrations/exportilu.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(top: 10),
                                              child: const Text(
                                                "Send",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ))
                          ]else...[
                            Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState((){
                                      isNationaly = false;
                                    });
                                    Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<bool>(
                                        fullscreenDialog: false,
                                        builder: (BuildContext context) =>
                                        const Home2(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    padding: const EdgeInsets.only(top: 20, bottom: 60),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffF5F6F9),
                                        borderRadius: BorderRadius.circular(15)),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.only(
                                                left: 30, right: 30),
                                            child: Image.asset(
                                              "assets/illustrations/international.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(top: 10),
                                              child: const Text(
                                                "International",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                            Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState((){
                                      isNationaly = true;
                                    });
                                    Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<bool>(
                                        fullscreenDialog: false,
                                        builder: (BuildContext context) =>
                                        const Home2(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    padding: const EdgeInsets.only(top: 20, bottom: 60),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffF5F6F9),
                                        borderRadius: BorderRadius.circular(15)),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.only(
                                                left: 30, right: 30),
                                            child: Image.asset(
                                              "assets/illustrations/national.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(top: 10),
                                              child: const Text(
                                                "National",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ))
                          ]
                        ],
                      ),
                    )),
                // Flexible(
                //     child: InkWell(
                //   onTap: () {},
                //   child: Container(
                //     height: 200,
                //     margin: const EdgeInsets.only(bottom: 20),
                //     padding: const EdgeInsets.only(
                //         top: 20, bottom: 20, left: 15, right: 15),
                //     decoration: BoxDecoration(
                //         color: const Color(0xffF5F6F9),
                //         borderRadius: BorderRadius.circular(15)),
                //     width: double.infinity,
                //     child: Row(
                //       children: [
                //         Container(
                //           alignment: Alignment.centerLeft,
                //           margin: const EdgeInsets.only(right: 10),
                //           child: Image.asset(
                //             "assets/illustrations/Qa.png",
                //             fit: BoxFit.fitHeight,
                //           ),
                //         ),
                //         const Expanded(
                //           child: SizedBox(
                //               width: double.infinity,
                //               child: Text(
                //                 "Frequently asked questions",
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.black),
                //               )),
                //         )
                //       ],
                //     ),
                //   ),
                // ))
              ],
            ),
          )),
    );
  }
}

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _searchTrackingNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          userCountry,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: Image.asset(
            "assets/icons/chevron-left-Bold.png",
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Image.asset(
              "assets/icons/user-Bold.png",
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {},
          )
        ],
      ),
      // drawer: Drawer(
      //     backgroundColor: Theme.of(context).primaryColor,
      //     child: Column(
      //       children: [
      //         Expanded(
      //           child: ListView(
      //             padding: EdgeInsets.zero,
      //             children: [
      //               UserAccountsDrawerHeader(
      //                 decoration: const BoxDecoration(
      //                     border: Border(
      //                         bottom:
      //                         BorderSide(color: Colors.white, width: 2.0))),
      //                 margin: const EdgeInsets.only(
      //                     bottom: 8.0, left: 15.0, right: 15.0),
      //                 accountName: const Text(
      //                   "ELKEBBAR Ayoub",
      //                   style: TextStyle(
      //                       fontSize: 18,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white),
      //                 ),
      //                 accountEmail: const Text(
      //                   "ay.elkebbar@share-in.ma",
      //                   style: TextStyle(
      //                       fontSize: 18,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.white),
      //                 ),
      //                 currentAccountPicture: Container(
      //                   alignment: Alignment.center,
      //                   width: 200,
      //                   height: 200,
      //                   decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(50),
      //                       color: Colors.white),
      //                   child: (() {
      //                     if (true) {
      //                       return Text("A",
      //                           style: TextStyle(
      //                               fontSize: 25,
      //                               fontWeight: FontWeight.bold,
      //                               color: Theme.of(context).primaryColor));
      //                     } else {
      //                       return Image.asset(
      //                         "assets/images/person",
      //                         fit: BoxFit.contain,
      //                       );
      //                     }
      //                   }()),
      //                 ),
      //               ),
      //               ListTile(
      //                 leading: Image.asset(
      //                   "assets/icons/package-Bold.png",
      //                   color: Colors.white,
      //                 ),
      //                 title: const Text(
      //                   'My shipments',
      //                   style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18),
      //                 ),
      //                 onTap: () {},
      //               ),
      //               ListTile(
      //                 leading: Image.asset(
      //                   "assets/icons/phone-Bold.png",
      //                   color: Colors.white,
      //                 ),
      //                 title: const Text(
      //                   'Support',
      //                   style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18),
      //                 ),
      //                 onTap: () {},
      //               ),
      //               ListTile(
      //                 leading: Image.asset(
      //                   "assets/icons/shield-Bold.png",
      //                   color: Colors.white,
      //                 ),
      //                 title: const Text(
      //                   'Terms & Conditions',
      //                   style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18),
      //                 ),
      //                 onTap: () {},
      //               ),
      //               ListTile(
      //                 leading: Image.asset(
      //                   "assets/icons/giftbox-Bold.png",
      //                   color: Colors.white,
      //                 ),
      //                 title: const Text(
      //                   'Advertising space',
      //                   style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18),
      //                 ),
      //                 onTap: () {},
      //               ),
      //               ListTile(
      //                 leading: Image.asset(
      //                   "assets/icons/copy-Bold.png",
      //                   color: Colors.white,
      //                 ),
      //                 title: const Text(
      //                   'Address book',
      //                   style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18),
      //                 ),
      //                 onTap: () {},
      //               ),
      //               ListTile(
      //                 leading: Image.asset(
      //                   "assets/icons/settings-Bold.png",
      //                   color: Colors.white,
      //                 ),
      //                 title: const Text(
      //                   'Settings',
      //                   style: TextStyle(
      //                       color: Colors.white,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18),
      //                 ),
      //                 onTap: () {},
      //               )
      //             ],
      //           ),
      //         ),
      //         Align(
      //             alignment: FractionalOffset.bottomCenter,
      //             child: ListTile(
      //               leading: Image.asset(
      //                 "assets/icons/log-out-Bold.png",
      //                 color: Colors.white,
      //               ),
      //               title: const Text(
      //                 'Log out',
      //                 style: TextStyle(
      //                     color: Colors.white,
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 18),
      //               ),
      //               onTap: () {},
      //             ))
      //       ],
      //     )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                    child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.only(
                            top:30, bottom: 30, left: 15, right: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context).primaryColor),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // Flexible(
                            //   child: Container(
                            //     margin: const EdgeInsets.only(bottom: 20),
                            //     width: MediaQuery.of(context).size.width,
                            //     child: TextField(
                            //       controller: _searchTrackingNumber,
                            //       textCapitalization:
                            //       TextCapitalization.characters,
                            //       keyboardType: TextInputType.multiline,
                            //       style: const TextStyle(
                            //           fontSize: 17.0, color: Colors.black),
                            //       decoration: InputDecoration(
                            //           contentPadding:
                            //           const EdgeInsets.symmetric(
                            //               vertical: 15.0, horizontal: 10.0),
                            //           hintText: "Enter your tracking number",
                            //           border: OutlineInputBorder(
                            //               borderRadius:
                            //               BorderRadius.circular(10.0),
                            //               borderSide: BorderSide(
                            //                   color: Theme.of(context)
                            //                       .primaryColor,
                            //                   width: 1)),
                            //           focusedBorder: OutlineInputBorder(
                            //               borderRadius:
                            //               BorderRadius.circular(10.0),
                            //               borderSide: BorderSide(
                            //                   color: Theme.of(context)
                            //                       .primaryColor,
                            //                   width: 1)),
                            //           enabledBorder: OutlineInputBorder(
                            //               borderRadius:
                            //               BorderRadius.circular(10.0),
                            //               borderSide: BorderSide(
                            //                   color: Theme.of(context)
                            //                       .primaryColor,
                            //                   width: 1)),
                            //           errorBorder: OutlineInputBorder(
                            //               borderRadius:
                            //               BorderRadius.circular(10.0),
                            //               borderSide: BorderSide(
                            //                   color: Theme.of(context)
                            //                       .primaryColor,
                            //                   width: 1)),
                            //           disabledBorder: OutlineInputBorder(
                            //               borderRadius:
                            //               BorderRadius.circular(10.0),
                            //               borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1)),
                            //           filled: true,
                            //           fillColor: Colors.white,
                            //           suffixIcon: Padding(
                            //               padding: const EdgeInsets.all(10),
                            //               child: InkWell(
                            //                 onTap: () {},
                            //                 child: Container(
                            //                   width: 35,
                            //                   height: 35,
                            //                   decoration: BoxDecoration(
                            //                       borderRadius:
                            //                       BorderRadius.circular(5),
                            //                       color: Theme.of(context)
                            //                           .primaryColor),
                            //                   child: Image.asset(
                            //                     "assets/icons/search-Bold.png",
                            //                     color: Colors.white,
                            //                   ),
                            //                 ),
                            //               ))),
                            //     ),
                            //   ),
                            // ),
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/illustrations/Home.png",
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20,top: 30),
                                child: Text(
                                  "What would you like to ${(isExport == true) ? 'send' : 'receive'} ?",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Package: Use this option if you need to send items like boxes, parcels, or larger goods.",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Document: Select this if you're sending papers, letters, or important documents.",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ))),
                // Flexible(
                //   child: Container(
                //       width: double.infinity,
                //       margin: const EdgeInsets.only(
                //         bottom: 30,
                //       ),
                //       padding: const EdgeInsets.only(
                //           top: 10, bottom: 20, left: 15, right: 15),
                //       decoration: BoxDecoration(
                //           color: const Color(0xffF5F6F9),
                //           borderRadius: BorderRadius.circular(15)),
                //       child: const Column(
                //         children: [
                //           Text(
                //             'What would you like to do today ?',
                //             textAlign: TextAlign.center,
                //             style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: 20,
                //                 color: Colors.black87
                //             ),
                //           ),
                //           Text(
                //             'Tap one of the options to start.',
                //             textAlign: TextAlign.left,
                //             style: TextStyle(
                //                 fontWeight: FontWeight.normal,
                //                 fontSize: 17,
                //                 color: Colors.black87
                //             ),
                //           )
                //         ],
                //       )
                //   ),
                // ),
                Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState((){
                                    isDocument = false;
                                  });
                                  if(isNationaly == false){
                                    Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<bool>(
                                        fullscreenDialog: false,
                                        builder: (BuildContext context) =>
                                        const FirstOrderStep(),
                                      ),
                                    );
                                  }else{
                                    Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<bool>(
                                        fullscreenDialog: false,
                                        builder: (BuildContext context) =>
                                        const FirstOrderStepNational(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  padding: const EdgeInsets.only(top: 20, bottom: 60),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF5F6F9),
                                      borderRadius: BorderRadius.circular(15)),
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.only(
                                              left: 30, right: 30),
                                          child: Image.asset(
                                            "assets/illustrations/packages.png",
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(top: 10),
                                            child: const Text(
                                              "Package",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState((){
                                    isDocument = true;
                                  });
                                  if(isNationaly == false){
                                    Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<bool>(
                                        fullscreenDialog: false,
                                        builder: (BuildContext context) =>
                                        const FirstOrderStep(),
                                      ),
                                    );
                                  }else{
                                    Navigator.of(context, rootNavigator: true).push(
                                      CupertinoPageRoute<bool>(
                                        fullscreenDialog: false,
                                        builder: (BuildContext context) =>
                                        const FirstOrderStepNational(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  padding: const EdgeInsets.only(top: 20, bottom: 60),
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF5F6F9),
                                      borderRadius: BorderRadius.circular(15)),
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.only(
                                              left: 30, right: 30),
                                          child: Image.asset(
                                            "assets/illustrations/documents.png",
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(top: 10),
                                            child: const Text(
                                              "Document",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    )),
                // Flexible(
                //     child: InkWell(
                //   onTap: () {},
                //   child: Container(
                //     height: 200,
                //     margin: const EdgeInsets.only(bottom: 20),
                //     padding: const EdgeInsets.only(
                //         top: 20, bottom: 20, left: 15, right: 15),
                //     decoration: BoxDecoration(
                //         color: const Color(0xffF5F6F9),
                //         borderRadius: BorderRadius.circular(15)),
                //     width: double.infinity,
                //     child: Row(
                //       children: [
                //         Container(
                //           alignment: Alignment.centerLeft,
                //           margin: const EdgeInsets.only(right: 10),
                //           child: Image.asset(
                //             "assets/illustrations/Qa.png",
                //             fit: BoxFit.fitHeight,
                //           ),
                //         ),
                //         const Expanded(
                //           child: SizedBox(
                //               width: double.infinity,
                //               child: Text(
                //                 "Frequently asked questions",
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                     fontSize: 20,
                //                     fontWeight: FontWeight.bold,
                //                     color: Colors.black),
                //               )),
                //         )
                //       ],
                //     ),
                //   ),
                // ))
              ],
            ),
          )),
    );
  }
}

// Create shipment sender
class FirstOrderStepNational extends StatefulWidget {
  const FirstOrderStepNational({super.key});

  @override
  State<FirstOrderStepNational> createState() => _FirstOrderStepNationalState();
}

class _FirstOrderStepNationalState extends State<FirstOrderStepNational> {
  Future<List> _loadAgenciesSender(countryName,countryCode,cityName,postalCode) async {
    String apiUrl = "https://boxpid.com/backend/view/order/getAgencyList.php";
    final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID,
          'email-adress': userLogin,
          'country-name': countryName,
          'country-code': countryCode,
          'city-name': cityName,
          'postal-code': postalCode
        }
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List agencyList = responseData['data'];
      return agencyList;
    } else {
      // Handle error
      return [];
    }
  }

  void _fillModalAgenciesSender(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var selectedValueInfos = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the agency:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((agency) {
                            return searchValue.isEmpty ||
                                agency['libelle'].toLowerCase().contains(searchValue);
                          }).map((agency) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = agency['id'].toString();
                                  selectedValueLibelle = agency['libelle'];
                                  selectedValueInfos = agency['infos'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    agency['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: agency['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = agency['id'].toString();
                                        selectedValueLibelle = agency['libelle'];
                                        selectedValueInfos = agency['infos'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _senderAgency.text = selectedValueInfos;
                            } else {
                              _senderAgency.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<List> _getCities(idCountry,String selectedCity) async {
    String apiUrl = "https://boxpid.com/backend/view/user/getVilles.php";
    var bodyRequest = {
      'app-id': appID,
      'id_pays': idCountry,
    };
    if(selectedCity != ''){
      bodyRequest = {
        'app-id': appID,
        'id_pays': idCountry,
        'ville_name': selectedCity.toUpperCase(),
      };
    }
    final response = await http.post(
        Uri.parse(apiUrl),
        body: bodyRequest
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List citiesList = responseData['data'];
      return citiesList;
    } else {
      // Handle error
      return [];
    }
  }

  Future<void> _fillModalCitiesFrom(List listValues) async{
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the city:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) async {
                          var search = value.toLowerCase();
                          if(search.length > 4){
                            var countryId = _fromCountryId.text;
                            Iterable contain;
                            contain = listValues.where((element) => element['libelle'] == search);
                            if (contain.isEmpty){
                              print('nothing found in the list');
                              List listValuesSearch = await _getCities(countryId,search);
                              print(listValuesSearch);
                              setState(() {
                                listValues.addAll(listValuesSearch);
                              });
                            }
                          }
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _fromCity.text = selectedValueLibelle;
                              _fromCityId.text = selectedValue;
                            } else {
                              _fromCity.clear();
                              _fromCityId.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _fillModalCitiesTo(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the city:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) async {
                          var search = value.toLowerCase();
                          if(search.length > 4){
                            var countryId = _fromCountryId.text;
                            Iterable contain;
                            contain = listValues.where((element) => element['libelle'] == search);
                            if (contain.isEmpty){
                              print('nothing found in the list');
                              List listValuesSearch = await _getCities(countryId,search);
                              print(listValuesSearch);
                              setState(() {
                                listValues.addAll(listValuesSearch);
                              });
                            }
                          }
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _toCity.text = selectedValueLibelle;
                              _toCityId.text = selectedValue;
                            } else {
                              _toCity.clear();
                              _toCityId.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  @override
  void initState() {
    super.initState();
    if(isExport == true){
      _fullNameSender.text = userName;
      _phoneNumberSender.text = userPhoneNumber;
      _emailSender.text = userLogin;
    }else{
      _fullNameReceiver.text = userName;
      _phoneNumberReceiver.text = userPhoneNumber;
      _emailReceiver.text = userLogin;
    }
    _toCountryId.text = '172';
    _toCountry.text = 'MOROCCO';
    _toCountryCode.text = 'MA';
    _fromCountryId.text = '172';
    _fromCountry.text = 'MOROCCO';
    _fromCountryCode.text = 'MA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Sender information",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 30,
                          end: 40,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Sender information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fromCity,
                              onTap: () async {
                                if(_fromCountryId.text != ''){
                                  List citiesList = await _getCities(_fromCountryId.text,'');
                                  _fillModalCitiesFrom(citiesList);
                                }
                              },
                              readOnly: true,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "City",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-pin-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _senderAgency,
                              readOnly: true,
                              onTap: () async {
                                var countryName = _fromCountry.text;
                                var countryCode = _fromCountryCode.text;
                                var cityName = _fromCity.text;
                                var postalCode = _fromPostalCode.text;
                                // List listAgc = await _loadAgenciesSender(countryName,countryCode,cityName,postalCode);
                                List listAgc = [{"libelle":"Agence Casablanca","id": "1","infos":"Agence Casablanca"},{"libelle":"Agence Agadir","id": "2","infos":"Agence Agadir"}];
                                _fillModalAgenciesSender(listAgc);
                              },
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Agency",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-marker-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fullNameSender,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Full name",
                                hintText: "John Fitzgerald",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/user-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _phoneNumberSender,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                hintText: "(+000) 000-000-000",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/mobile-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _emailSender,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "example@example.com",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/envelope-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _addressSender,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Address",
                                hintText: "Address",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/map-marker-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const FirstOrderStepNational2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

//second order receiver
class FirstOrderStepNational2 extends StatefulWidget {
  const FirstOrderStepNational2({super.key});

  @override
  State<FirstOrderStepNational2> createState() => _FirstOrderStepNational2State();
}

class _FirstOrderStepNational2State extends State<FirstOrderStepNational2> {
  final bool _receiveWithAddress = true;

  Future<List> _loadAgenciesReceiver(countryName,countryCode,cityName,postalCode) async {
    String apiUrl = "https://boxpid.com/backend/view/order/getAgencyList.php";
    final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID,
          'email-adress': userLogin,
          'country-name': countryName,
          'country-code': countryCode,
          'city-name': cityName,
          'postal-code': postalCode
        }
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List agencyList = responseData['data'];
      return agencyList;
    } else {
      // Handle error
      return [];
    }
  }

  void _fillModalAgenciesReceiver(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var selectedValueInfos = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the agency:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((agency) {
                            return searchValue.isEmpty ||
                                agency['libelle'].toLowerCase().contains(searchValue);
                          }).map((agency) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = agency['id'].toString();
                                  selectedValueLibelle = agency['libelle'];
                                  selectedValueInfos = agency['infos'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    agency['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: agency['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = agency['id'].toString();
                                        selectedValueLibelle = agency['libelle'];
                                        selectedValueInfos = agency['infos'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _receiverAgency.text = selectedValueInfos;
                            } else {
                              _receiverAgency.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<List> _getCities(idCountry,String selectedCity) async {
    String apiUrl = "https://boxpid.com/backend/view/user/getVilles.php";
    var bodyRequest = {
      'app-id': appID,
      'id_pays': idCountry,
    };
    if(selectedCity != ''){
      bodyRequest = {
        'app-id': appID,
        'id_pays': idCountry,
        'ville_name': selectedCity.toUpperCase(),
      };
    }
    final response = await http.post(
        Uri.parse(apiUrl),
        body: bodyRequest
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List citiesList = responseData['data'];
      return citiesList;
    } else {
      // Handle error
      return [];
    }
  }

  void _fillModalCitiesTo(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the city:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) async {
                          var search = value.toLowerCase();
                          if(search.length > 4){
                            var countryId = _fromCountryId.text;
                            Iterable contain;
                            contain = listValues.where((element) => element['libelle'] == search);
                            if (contain.isEmpty){
                              print('nothing found in the list');
                              List listValuesSearch = await _getCities(countryId,search);
                              print(listValuesSearch);
                              setState(() {
                                listValues.addAll(listValuesSearch);
                              });
                            }
                          }
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _toCity.text = selectedValueLibelle;
                              _toCityId.text = selectedValue;
                            } else {
                              _toCity.clear();
                              _toCityId.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Recipient information",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 40,
                          end: 50,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Recipient information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _toCity,
                              onTap: () async {
                                if(_fromCountryId.text != ''){
                                  List citiesList = await _getCities(_toCountryId.text,'');
                                  _fillModalCitiesTo(citiesList);
                                }
                              },
                              readOnly: true,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "City",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-pin-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _receiverAgency,
                              readOnly: true,
                              onTap: () async {
                                var countryName = _toCountry.text;
                                var countryCode = _toCountryCode.text;
                                var cityName = _toCity.text;
                                var postalCode = _toPostalCode.text;
                                // List listAgc = await _loadAgenciesReceiver(countryName,countryCode,cityName,postalCode);
                                List listAgc = [{"libelle":"Agence Casablanca","id": "1","infos":"Agence Casablanca"},{"libelle":"Agence Agadir","id": "2","infos":"Agence Agadir"}];
                                _fillModalAgenciesReceiver(listAgc);
                              },
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Agency",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-marker-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fullNameReceiver,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Full name",
                                hintText: "John Fitzgerald",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/user-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _phoneNumberReceiver,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                hintText: "(+000) 000-000-000",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/mobile-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _emailReceiver,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "example@example.com",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/envelope-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _addressReceiver,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Address",
                                hintText: "Address",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/map-marker-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const FirstOrderStepNational3(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

//second order details
class FirstOrderStepNational3 extends StatefulWidget {
  const FirstOrderStepNational3({super.key});

  @override
  State<FirstOrderStepNational3> createState() => _FirstOrderStepNational3State();
}

class _FirstOrderStepNational3State extends State<FirstOrderStepNational3> {
  final TextEditingController _promoCode = TextEditingController();
  bool _isVip = false;
  final bool _senderWithAddress = false;
  final bool _receiveWithAddress = false;

  @override
  void initState() {
    super.initState();
    shipmentPriceTotal = '120.00';
    shipmentDelais = '24';
    _packageRealWeight.text = "1";
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showDialog2(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute<bool>(
                        fullscreenDialog: false,
                        builder: (BuildContext context) =>
                            MyShipmentsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<List> _getWeight() async {
    List<Map<String, dynamic>> weights = [];
    double weight = 0.5;
    int id = 1;

    while (weight <= 70) {
      weights.add({
        'id': id,
        'libelle': weight.toString()
      });
      weight += 0.5;
      id++;
    }

    return weights;
  }

  void _fillModalWeight(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the weight:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'] + ' KG',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              setState((){
                                _packageRealWeight.text = selectedValueLibelle;
                              });
                            } else {
                              setState((){
                                _packageRealWeight.text = "1";
                              });
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },

      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  Future<void> createShipment() async {
    print(userId);
    String apiUrl = "https://boxpid.com/backend/view/order/createShipmentNew.php";

    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'app_id': appID,
        'id_user': userId.toString(),
        'shipper_city_name': _fromCity.text,
        'shipper_address_line1': _addressSender.text,
        'shipper_country_name': _fromCountry.text,
        'shipper_phone': _phoneNumberSender.text,
        'shipper_full_name': _fullNameSender.text,
        'shipper_email_address': _emailSender.text,
        'receiver_city_name': _toCity.text,
        'receiver_address_line1': _addressReceiver.text,
        'receiver_country_name': _toCountry.text,
        'receiver_phone': _phoneNumberReceiver.text,
        'receiver_full_name': _fullNameReceiver.text,
        'receiver_email_address': _emailReceiver.text,
        'is_document': isDocument.toString(),
        'package_weight': _packageRealWeight.text,
        'pickup_city_name': _fromCity.text,
        'pickup_address_line1': _addressSender.text,
        'pickup_country_name': _fromCountry.text,
        'pickup_email_address': _emailSender.text,
        'pickup_phone': _phoneNumberSender.text,
        'pickup_full_name': _fullNameSender.text,
        'is_export': isExport.toString(),
        'planned_date_and_time': '${_pickupDate.text}T${_pickupTimeTo.text}:00 GMT+01:00',
        'total_price': shipmentPriceTotal.toString(),
      },
    );

    print({
      'app_id': appID,
      'id_user': userId.toString(),
      'shipper_city_name': _fromCity.text,
      'shipper_address_line1': _addressSender.text,
      'shipper_country_name': _fromCountry.text,
      'shipper_phone': _phoneNumberSender.text,
      'shipper_full_name': _fullNameSender.text,
      'shipper_email_address': _emailSender.text,
      'receiver_city_name': _toCity.text,
      'receiver_address_line1': _addressReceiver.text,
      'receiver_country_name': _toCountry.text,
      'receiver_phone': _phoneNumberReceiver.text,
      'receiver_full_name': _fullNameReceiver.text,
      'receiver_email_address': _emailReceiver.text,
      'is_document': isDocument.toString(),
      'package_weight': _packageRealWeight.text,
      'pickup_city_name': _fromCity.text,
      'pickup_address_line1': _addressSender.text,
      'pickup_country_name': _fromCountry.text,
      'pickup_email_address': _emailSender.text,
      'pickup_phone': _phoneNumberSender.text,
      'pickup_full_name': _fullNameSender.text,
      'is_export': isExport.toString(),
      'planned_date_and_time': '${_pickupDate.text}T${_pickupTimeTo.text}:00 GMT+01:00',
      'total_price': shipmentPriceTotal.toString(),
    });
    _showDialog2('Your order has been created successfully. You can proceed with the payment after a driver affected to your shipment.', 'Note');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Shipments summary",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 70,
                          end: 80,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity:const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text(
                              "Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            subtitle: Text(
                              (isDocument) ? "Document" : "Package",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "Weight",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "${_packageRealWeight.text} KG",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                  minLeadingWidth : 0,
                                  trailing: InkWell(
                                    onTap: () async {
                                      var listWeight = await _getWeight();
                                      if(listWeight.isNotEmpty){
                                        _fillModalWeight(listWeight);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        top: 15,
                                        right: 25,
                                      ),
                                      child: Image.asset(
                                        "assets/icons/pen-Bold.png",
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "Delay",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "$shipmentDelais Hours",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "From",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    _fromCity.text,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "To",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    _toCity.text,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text(
                              "Agency to drop off",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            subtitle: Text(
                              _senderAgency.text,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _promoCode,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.characters,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Promo code",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: Image.asset(
                              "assets/icons/comment-dots-Bold.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isVip = false;
                                  shipmentPriceTotal = '120.00';
                                  shipmentDelais = '24';
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.only(
                                  bottom: 0,
                                  left: 10,
                                  right: 10,
                                  top: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.shade200),
                                  color: (() {
                                    if (_isVip) {
                                      return Colors.white;
                                    } else {
                                      return Theme.of(context).primaryColor;
                                    }
                                  }()),
                                ),
                                child: ListTile(
                                  contentPadding:
                                  const EdgeInsets.only(left: 0.0, right: 0.0),
                                  visualDensity: const VisualDensity(
                                      horizontal: 0.0, vertical: -2),
                                  isThreeLine: true,
                                  leading: Container(
                                    padding: const EdgeInsets.all(4),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: (() {
                                          if (_isVip) {
                                            return Theme.of(context).primaryColor;
                                          } else {
                                            return Colors.white;
                                          }
                                        }()),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Image.asset(
                                      "assets/illustrations/vip.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: Text(
                                    'Service : ',
                                    style: TextStyle(
                                        color: (() {
                                          if (_isVip) {
                                            return Colors.black87;
                                          } else {
                                            return Colors.white;
                                          }
                                        }()),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    'Express',
                                    style: TextStyle(
                                        color: (() {
                                          if (_isVip) {
                                            return Colors.black87;
                                          } else {
                                            return Colors.white;
                                          }
                                        }()),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            )),
                        Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isVip = true;
                                  shipmentPriceTotal = '60.00';
                                  shipmentDelais = '48';
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 5),
                                padding: const EdgeInsets.only(
                                  bottom: 0,
                                  left: 10,
                                  right: 10,
                                  top: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.shade200),
                                  color: (() {
                                    if (_isVip) {
                                      return Theme.of(context).primaryColor;
                                    } else {
                                      return Colors.white;
                                    }
                                  }()),
                                ),
                                child: ListTile(
                                  contentPadding:
                                  const EdgeInsets.only(left: 0.0, right: 0.0),
                                  visualDensity: const VisualDensity(
                                      horizontal: 0.0, vertical: -2),
                                  isThreeLine: true,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (() {
                                        if (_isVip) {
                                          return Colors.white;
                                        } else {
                                          return Theme.of(context).primaryColor;
                                        }
                                      }()),
                                    ),
                                    child: Image.asset(
                                      "assets/illustrations/normal.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: Text(
                                    'Service : ',
                                    style: TextStyle(
                                        color: (() {
                                          if (_isVip) {
                                            return Colors.white;
                                          } else {
                                            return Colors.black87;
                                          }
                                        }()),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    'Normal',
                                    style: TextStyle(
                                        color: (() {
                                          if (_isVip) {
                                            return Colors.white;
                                          } else {
                                            return Colors.black87;
                                          }
                                        }()),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 0, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Amount",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "$shipmentPriceTotal DH TTC",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Discount",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "0,00 DH TTC",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 18),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                visualDensity:
                                const VisualDensity(horizontal: 0, vertical: -4),
                                title: const Text(
                                  "Total amount",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  "$shipmentPriceTotal DH TTC",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 22),
                                ),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(
                          top: 10, right: 10, left: 10, bottom: 30),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  right: 5,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    createShipment();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff1D3058),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Online",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: Image.asset(
                                                "assets/icons/arrow-right-Bold.png",
                                                color: Colors.white,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 5,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    createShipment();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff1D3058),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Cash",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: Image.asset(
                                                "assets/icons/arrow-right-Bold.png",
                                                color: Colors.white,
                                              ),
                                              onPressed: () {},
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              )
                          ),
                        ],
                      )
                  ),
                )
              ],
            ),
          )),
    );
  }
}


class FirstOrderStep extends StatefulWidget {
  const FirstOrderStep({super.key});

  @override
  State<FirstOrderStep> createState() => _FirstOrderStepState();
}

class _FirstOrderStepState extends State<FirstOrderStep> {
  @override
  void initState() {
    super.initState();
    checkUserLocationInfo();
  }

  Future checkUserLocationInfo() async {
    var idCountry = 0;
    var idCity = 0;
    var cityName = '';
    var countryCode = '';
    var countryName = '';
    var postalCode = '';

    var userCont = userCountry.toLowerCase();
    bool containsCountry = countriesList.any((element) {
      var listCont = element['libelle'].toLowerCase();
      if (listCont.contains(userCont)) {
        print('Country found: $listCont');
        idCountry = element['id'];
        countryCode = element['codE_ISO'];
        countryName = element['libelle'];

        setState((){
          if(isExport == true){
            _fromCountryId.text = idCountry.toString();
            _fromCountry.text = countryName.toUpperCase();
            _fromCountryCode.text = userCountryCode.toUpperCase();
            if(countryName != 'morocco'){
              _toCountryId.text = '172';
              _toCountry.text = 'MOROCCO';
              _toCountryCode.text = 'MA';
            }
          }else{
            _toCountryId.text = idCountry.toString();
            _toCountry.text = countryName.toUpperCase();
            _toCountryCode.text = userCountryCode.toUpperCase();
            if(countryName != 'morocco'){
              _fromCountryId.text = '172';
              _fromCountry.text = 'MOROCCO';
              _fromCountryCode.text = 'MA';
            }
          }
        });
        return true;
      }
      return false;
    });

    if (containsCountry) {
      var selectedCity = userCity.toUpperCase();
      var firstFourLetters = '${selectedCity[0]}${selectedCity[1]}${selectedCity[2]}${selectedCity[3]}';


      var citiesList = await _getCities(idCountry.toString(), firstFourLetters);


      bool containsCity = citiesList.any((element) {
        var listCont = element['libelle'].toLowerCase();
        if (listCont.contains(selectedCity.toLowerCase())) {
          print('City found: $listCont');
          idCity = element['id'];
          cityName = element['libelle'];
          setState((){
            if(isExport == true){
              _fromCityId.text = idCity.toString();
              _fromCity.text = cityName.toUpperCase();
              _fromPostalCode.text = userPostalCode;
              if(countryName != 'morocco'){
                _toCityId.text = '175745';
                _toCity.text = 'CASABLANCA';
                _toPostalCode.text = '20250';
              }
            }else{
              _toCityId.text = idCity.toString();
              _toCity.text = cityName.toUpperCase();
              _toPostalCode.text = userPostalCode;
              if(countryName != 'morocco'){
                _fromCityId.text = '175745';
                _fromCity.text = 'CASABLANCA';
                _fromPostalCode.text = '20250';
              }
            }
          });
          return true;
        }
        return false;
      });
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _fillModalCountriesFrom(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';
    var selectedCode = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the country:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                  selectedCode = country['codE_ISO'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  leading: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFe0f2f1)),
                                    child: CountryFlag.fromCountryCode(
                                      country['codE_ISO'],
                                      height: 48,
                                      width: 62,
                                      borderRadius: 8,
                                    ),
                                  ),
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                        selectedCode = country['codE_ISO'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _fromCountry.text = selectedValueLibelle;
                              _fromCountryId.text = selectedValue;
                              _fromCountryCode.text = selectedCode;
                              if(_fromCountry.text != 'MOROCCO'){
                                _toCountry.text = 'MOROCCO';
                                _toCountryId.text = '172';
                                _toCountryCode.text = 'MA';
                              }
                            } else {
                              _fromCountry.clear();
                              _fromCountryId.clear();
                              _fromCountryCode.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _fillModalCountriesTo(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';
    var selectedCode = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the country:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                  selectedCode = country['codE_ISO'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  leading: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFe0f2f1)),
                                    child: CountryFlag.fromCountryCode(
                                      country['codE_ISO'],
                                      height: 48,
                                      width: 62,
                                      borderRadius: 8,
                                    ),
                                  ),
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                        selectedCode = country['codE_ISO'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _toCountry.text = selectedValueLibelle;
                              _toCountryId.text = selectedValue;
                              _toCountryCode.text = selectedCode;
                              if(_toCountry.text != 'MOROCCO'){
                                _fromCountry.text = 'MOROCCO';
                                _fromCountryId.text = '172';
                                _fromCountryCode.text = 'MA';
                              }
                            } else {
                              _toCountry.clear();
                              _toCountryId.clear();
                              _toCountryCode.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  Future<List> _getCities(idCountry,String selectedCity) async {
    String apiUrl = "https://boxpid.com/backend/view/user/getVilles.php";
    var bodyRequest = {
      'app-id': appID,
      'id_pays': idCountry,
    };
    if(selectedCity != ''){
      bodyRequest = {
        'app-id': appID,
        'id_pays': idCountry,
        'ville_name': selectedCity.toUpperCase(),
      };
    }
    final response = await http.post(
        Uri.parse(apiUrl),
        body: bodyRequest
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List citiesList = responseData['data'];
      return citiesList;
    } else {
      // Handle error
      return [];
    }
  }

  Future<void> _fillModalCitiesFrom(List listValues) async{
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the city:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) async {
                          var search = value.toLowerCase();
                          if(search.length > 4){
                            var countryId = _fromCountryId.text;
                            Iterable contain;
                            contain = listValues.where((element) => element['libelle'] == search);
                            if (contain.isEmpty){
                              print('nothing found in the list');
                              List listValuesSearch = await _getCities(countryId,search);
                              print(listValuesSearch);
                              setState(() {
                                listValues.addAll(listValuesSearch);
                              });
                            }
                          }
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _fromCity.text = selectedValueLibelle;
                              _fromCityId.text = selectedValue;
                            } else {
                              _fromCity.clear();
                              _fromCityId.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _fillModalCitiesTo(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the city:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) async {
                          var search = value.toLowerCase();
                          if(search.length > 4){
                            var countryId = _fromCountryId.text;
                            Iterable contain;
                            contain = listValues.where((element) => element['libelle'] == search);
                            if (contain.isEmpty){
                              print('nothing found in the list');
                              List listValuesSearch = await _getCities(countryId,search);
                              print(listValuesSearch);
                              setState(() {
                                listValues.addAll(listValuesSearch);
                              });
                            }
                          }
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _toCity.text = selectedValueLibelle;
                              _toCityId.text = selectedValue;
                            } else {
                              _toCity.clear();
                              _toCityId.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  Future<List> _getPostalCodes(idCity) async {
    String apiUrl = "https://boxpid.com/backend/view/user/getPostalCodes.php";
    final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID,
          'id_city': idCity,
        }
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List postalList = responseData['data'];
      return postalList;
    } else {
      // Handle error
      return [];
    }
  }

  void _fillModalPostalCodesFrom(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the postal code:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _fromPostalCode.text = selectedValueLibelle;
                            } else {
                              _fromPostalCode.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _fillModalPostalCodesTo(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the postal code:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _toPostalCode.text = selectedValueLibelle;
                            } else {
                              _toPostalCode.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Create shipment",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 00,
                          end: 10,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Depart informations",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fromCountry,
                              readOnly: true,
                              onTap: () => _fillModalCountriesFrom(countriesList),
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Country",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-marker-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fromCity,
                              onTap: () async {
                                if(_fromCountryId.text != ''){
                                  List citiesList = await _getCities(_fromCountryId.text,'');
                                  _fillModalCitiesFrom(citiesList);
                                }
                              },
                              readOnly: true,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "City",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-pin-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fromPostalCode,
                              readOnly: true,
                              onTap: () async {
                                if(_fromCityId.text != ''){
                                  List postalList = await _getPostalCodes(_fromCityId.text);
                                  _fillModalPostalCodesFrom(postalList);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Postal code",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/inbox-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Destination information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _toCountry,
                              onTap: () => _fillModalCountriesTo(countriesList),
                              readOnly: true,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Country",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-marker-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _toCity,
                              onTap: () async {
                                if(_toCountryId.text != ''){
                                  List citiesList = await _getCities(_toCountryId.text,'');
                                  _fillModalCitiesTo(citiesList);
                                }
                              },
                              readOnly: true,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "City",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/map-pin-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _toPostalCode,
                              readOnly: true,
                              onTap: () async {
                                if(_toCityId.text != ''){
                                  List postalList = await _getPostalCodes(_toCityId.text);
                                  _fillModalPostalCodesTo(postalList);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Postal code",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/inbox-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const FirstOrderStep2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
// Create shipment
class FirstOrderStep2 extends StatefulWidget {
  const FirstOrderStep2({super.key});

  @override
  State<FirstOrderStep2> createState() => _FirstOrderStep2State();
}

class _FirstOrderStep2State extends State<FirstOrderStep2> {
  bool _senderWithAddress = false;
  bool _receiveWithAddress = true;

  @override
  void initState() {
    super.initState();
    checkUserLocationInfo();
  }

  void checkUserLocationInfo() {
    var idCountry = 0;
    var idCity = 0;
    var countryCode = '';
    var countryName = '';
    var postalCode = '';

    var userCont = userCountry.toLowerCase();
    bool containsCountry = countriesList.any((element) {
      var listCont = element['libelle'].toLowerCase();
      if (listCont.contains(userCont)) {
        print('Country found: $listCont');
        return true;
      }
      return false;
    });

    if (!containsCountry) {
      print('Country not found.');
    }
  }
  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<List> _getWeight() async {
    List<Map<String, dynamic>> weights = [];
    double weight = 0.5;
    int id = 1;

    while (weight <= 70) {
      weights.add({
        'id': id,
        'libelle': weight.toString()
      });
      weight += 0.5;
      id++;
    }

    return weights;
  }

  void _fillModalWeight(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the weight:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((country) {
                            return searchValue.isEmpty ||
                                country['libelle'].toLowerCase().contains(searchValue);
                          }).map((country) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = country['id'].toString();
                                  selectedValueLibelle = country['libelle'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    country['libelle'] + ' KG',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: country['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = country['id'].toString();
                                        selectedValueLibelle = country['libelle'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _packageRealWeight.text = selectedValueLibelle;
                            } else {
                              _packageRealWeight.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  Future<void> _getBestPrices() async {
    var paysSourceId = _fromCountryId.text;
    var villeSourceId = _fromCityId.text;
    var paysDestinationId = _toCountryId.text;
    var villeDestinationId = _toCityId.text;
    var weight = (double.parse(_packageRealWeight.text) >= double.parse(_packageRealisticWeight.text)) ? _packageRealWeight.text : _packageRealisticWeight.text;
    var length = _packageLength.text;
    var width = _packageWidth.text;
    var height = _packageHeight.text;
    String apiUrl = "https://boxpid.com/backend/view/getPricing/index.php";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID2,
          'email-adress': userLogin,
          'paysSourceId': paysSourceId,
          'villeSourceId': villeSourceId,
          'paysDestinationId': paysDestinationId,
          'villeDestinationId': villeDestinationId,
          'weight': weight,
          'length': length,
          'width': width,
          'height': height
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        var data = responseData['data'];
        print(data);
        setState((){
          shipmentDelais = data['delais'].toString();
          shipmentPriceTotal = data['prixTotal'].toString();
          var shipmentEstimated = data['livrisonDate'];
          DateTime livrisonDate = DateTime.parse(shipmentEstimated);
          shipmentEstimatedDelivery = DateFormat('dd/MM/yyyy').format(livrisonDate);
        });
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute<bool>(
            fullscreenDialog: false,
            builder: (BuildContext context) =>
            const SecondOrderStep(),
          ),
        );
      } else {
        // Handle error
        final String errorMessage = responseData['NOTE'] ?? 'An error occurred';
        print(errorMessage);
      }
    } catch (e) {
      print('Something went wrong please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Create shipment",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 00,
                          end: 10,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Package information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        Flexible(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _packageRealWeight,
                              readOnly: true,
                              onTap: () async {
                                var listWeight = await _getWeight();
                                if(listWeight.isNotEmpty){
                                  _fillModalWeight(listWeight);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Real Weight",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/package-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        if(_packageRealisticWeight.text != '')...[
                          Flexible(
                            child:
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: double.infinity,
                              child: Text(
                                'Realistic weight : ${_packageRealisticWeight.text}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.black38, width: 1),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/dimension-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    controller: _packageWidth,
                                    onChanged: (value) {
                                      setState((){
                                        double realisticWeight = 0;
                                        if(value != '' && _packageHeight.text != '' && _packageLength.text != ''){
                                          var width = int.parse(value);
                                          var height = int.parse(_packageHeight.text);
                                          var length = int.parse(_packageLength.text);
                                          realisticWeight = (width * height * length) / 6000;
                                          realisticWeight = (realisticWeight * 2).round() / 2;
                                          _packageRealisticWeight.text = realisticWeight.toString();
                                          print('width');
                                          print(realisticWeight);
                                        }
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      border: InputBorder.none,
                                      hintText: "Width",
                                      hintStyle: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Flexible(
                                  child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      controller: _packageHeight,
                                      onChanged: (value) {
                                        setState((){
                                          double realisticWeight = 0;
                                          if(_packageWidth.text != '' && value != '' && _packageLength.text != ''){
                                            var width = int.parse(_packageWidth.text);
                                            var height = int.parse(value);
                                            var length = int.parse(_packageLength.text);
                                            realisticWeight = (width * height * length) / 6000;
                                            realisticWeight = (realisticWeight * 2).round() / 2;
                                            _packageRealisticWeight.text = realisticWeight.toString();
                                            print('height');
                                            print(realisticWeight);
                                          }
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(10),
                                        border: InputBorder.none,
                                        hintText: "Height",
                                        hintStyle: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.normal),
                                      )),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Flexible(
                                  child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      controller: _packageLength,
                                      onChanged: (value) {
                                        setState((){
                                          double realisticWeight = 0;
                                          if(_packageWidth.text != '' && _packageHeight.text != '' && value != ''){
                                            var width = int.parse(_packageWidth.text);
                                            var height = int.parse(_packageHeight.text);
                                            var length = int.parse(value);
                                            realisticWeight = (width * height * length) / 6000;
                                            realisticWeight = (realisticWeight * 2).round() / 2;
                                            _packageRealisticWeight.text = realisticWeight.toString();
                                            print('length');
                                            print(realisticWeight);
                                          }
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          border: InputBorder.none,
                                          hintText: "Length",
                                          hintStyle: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.normal))),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if(isExport != null)...[
                          if(isExport == true)...[
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _senderWithAddress = false;
                                              sendUsingAddress = false;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 5),
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                              color: (() {
                                                if (_senderWithAddress) {
                                                  return Colors.white;
                                                } else {
                                                  return Theme.of(context).primaryColor;
                                                }
                                              }()),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: (() {
                                                          if (_senderWithAddress) {
                                                            return Theme.of(context)
                                                                .primaryColor;
                                                          } else {
                                                            return Colors.white;
                                                          }
                                                        }()),
                                                        borderRadius:
                                                        BorderRadius.circular(10)),
                                                    child: Image.asset(
                                                      "assets/illustrations/agency.png",
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    child: ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Text(
                                                        'Drop in :',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_senderWithAddress) {
                                                                return Colors.black87;
                                                              } else {
                                                                return Colors.white;
                                                              }
                                                            }()),
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            fontSize: 12),
                                                      ),
                                                      subtitle: Text(
                                                        'Agency',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_senderWithAddress) {
                                                                return Colors.black87;
                                                              } else {
                                                                return Colors.white;
                                                              }
                                                            }()),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _senderWithAddress = true;
                                              sendUsingAddress = true;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 5),
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                              color: (() {
                                                if (_senderWithAddress) {
                                                  return Theme.of(context).primaryColor;
                                                } else {
                                                  return Colors.white;
                                                }
                                              }()),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: (() {
                                                        if (_senderWithAddress) {
                                                          return Colors.white;
                                                        } else {
                                                          return Theme.of(context)
                                                              .primaryColor;
                                                        }
                                                      }()),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/illustrations/SendWithAddress.png",
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    child: ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Text(
                                                        'Pickup from :',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_senderWithAddress) {
                                                                return Colors.white;
                                                              } else {
                                                                return Colors.black87;
                                                              }
                                                            }()),
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            fontSize: 12),
                                                      ),
                                                      subtitle: Text(
                                                        'Home address',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_senderWithAddress) {
                                                                return Colors.white;
                                                              } else {
                                                                return Colors.black87;
                                                              }
                                                            }()),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ]else...[
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _receiveWithAddress = false;
                                              receiveUsingAddress = true;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 5),
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                              color: (() {
                                                if (_receiveWithAddress) {
                                                  return Colors.white;
                                                } else {
                                                  return Theme.of(context).primaryColor;
                                                }
                                              }()),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: (() {
                                                          if (_receiveWithAddress) {
                                                            return Theme.of(context)
                                                                .primaryColor;
                                                          } else {
                                                            return Colors.white;
                                                          }
                                                        }()),
                                                        borderRadius:
                                                        BorderRadius.circular(10)),
                                                    child: Image.asset(
                                                      "assets/illustrations/house.png",
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    child: ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Text(
                                                        'Receive in : ',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_receiveWithAddress) {
                                                                return Colors.black87;
                                                              } else {
                                                                return Colors.white;
                                                              }
                                                            }()),
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            fontSize: 12),
                                                      ),
                                                      subtitle: Text(
                                                        'Home address',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_receiveWithAddress) {
                                                                return Colors.black87;
                                                              } else {
                                                                return Colors.white;
                                                              }
                                                            }()),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _receiveWithAddress = true;
                                              receiveUsingAddress = false;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 5),
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                              color: (() {
                                                if (_receiveWithAddress) {
                                                  return Theme.of(context).primaryColor;
                                                } else {
                                                  return Colors.white;
                                                }
                                              }()),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      color: (() {
                                                        if (_receiveWithAddress) {
                                                          return Colors.white;
                                                        } else {
                                                          return Theme.of(context)
                                                              .primaryColor;
                                                        }
                                                      }()),
                                                    ),
                                                    child: Image.asset(
                                                      "assets/illustrations/agency.png",
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    child: ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Text(
                                                        'Receive in : ',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_receiveWithAddress) {
                                                                return Colors.white;
                                                              } else {
                                                                return Colors.black87;
                                                              }
                                                            }()),
                                                            fontWeight:
                                                            FontWeight.normal,
                                                            fontSize: 12),
                                                      ),
                                                      subtitle: Text(
                                                        'Agency',
                                                        style: TextStyle(
                                                            color: (() {
                                                              if (_receiveWithAddress) {
                                                                return Colors.white;
                                                              } else {
                                                                return Colors.black87;
                                                              }
                                                            }()),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ],
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        _getBestPrices();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Shipments summary
class SecondOrderStep extends StatefulWidget {
  const SecondOrderStep({super.key});

  @override
  State<SecondOrderStep> createState() => _SecondOrderStepState();
}

class _SecondOrderStepState extends State<SecondOrderStep> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Shipments summary",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 10,
                          end: 30,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text(
                              "Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            subtitle: Text(
                              (isDocument == true) ? "Document" : "Package",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "Weight",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    (double.parse(_packageRealisticWeight.text) >= double.parse(_packageRealWeight.text)) ? "${_packageRealisticWeight.text} Kg" : "${_packageRealWeight.text} Kg",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "Delay",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "$shipmentDelais Hours",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "From",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "${_fromCity.text} ${_fromPostalCode.text}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: const Text(
                                    "To",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "${_toCity.text} ${_toPostalCode.text}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text(
                              "Delivery",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            subtitle: Text(
                              "Delivery estimated date $shipmentEstimatedDelivery",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 0, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Amount",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "$shipmentPriceTotal DH TTC",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        // Flexible(
                        //     child: Container(
                        //   margin: const EdgeInsets.only(bottom: 10),
                        //   child: const Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Expanded(
                        //         child: Text(
                        //           "Discount",
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.normal,
                        //               color: Colors.grey,
                        //               fontSize: 15),
                        //         ),
                        //       ),
                        //       Expanded(
                        //         child: Text(
                        //           "7,00 DH TTC",
                        //           textAlign: TextAlign.right,
                        //           style: TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               color: Colors.black87,
                        //               fontSize: 18),
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // )),
                        Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                visualDensity:
                                const VisualDensity(horizontal: 0, vertical: -4),
                                title: const Text(
                                  "Total amount",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  "$shipmentPriceTotal DH TTC",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 22),
                                ),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const PaymentPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Sender information
class ThirdOrderStep extends StatefulWidget {
  const ThirdOrderStep({super.key});

  @override
  State<ThirdOrderStep> createState() => _ThirdOrderStepState();
}

class _ThirdOrderStepState extends State<ThirdOrderStep> {
  Future<List> _loadAgenciesSender(countryName,countryCode,cityName,postalCode) async {
    String apiUrl = "https://boxpid.com/backend/view/order/getAgencyList.php";
    final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID,
          'email-adress': userLogin,
          'country-name': countryName,
          'country-code': countryCode,
          'city-name': cityName,
          'postal-code': postalCode
        }
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List agencyList = responseData['data'];
      return agencyList;
    } else {
      // Handle error
      return [];
    }
  }

  void _fillModalAgenciesSender(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var selectedValueInfos = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the agency:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((agency) {
                            return searchValue.isEmpty ||
                                agency['libelle'].toLowerCase().contains(searchValue);
                          }).map((agency) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = agency['id'].toString();
                                  selectedValueLibelle = agency['libelle'];
                                  selectedValueInfos = agency['infos'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    agency['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: agency['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = agency['id'].toString();
                                        selectedValueLibelle = agency['libelle'];
                                        selectedValueInfos = agency['infos'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _senderAgency.text = selectedValueInfos;
                            } else {
                              _senderAgency.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if(isExport == true){
      _fullNameSender.text = userName;
      _phoneNumberSender.text = userPhoneNumber;
      _emailSender.text = userLogin;
    }else{
      _fullNameReceiver.text = userName;
      _phoneNumberReceiver.text = userPhoneNumber;
      _emailReceiver.text = userLogin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Sender information",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 30,
                          end: 40,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Sender information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        if(sendUsingAddress == null)...[
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _senderWithAddress = false;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 5),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                            color: (() {
                                              if (_senderWithAddress) {
                                                return Colors.white;
                                              } else {
                                                return Theme.of(context).primaryColor;
                                              }
                                            }()),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: (() {
                                                        if (_senderWithAddress) {
                                                          return Theme.of(context)
                                                              .primaryColor;
                                                        } else {
                                                          return Colors.white;
                                                        }
                                                      }()),
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                  child: Image.asset(
                                                    "assets/illustrations/agency.png",
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(
                                                      'Drop in :',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_senderWithAddress) {
                                                              return Colors.black87;
                                                            } else {
                                                              return Colors.white;
                                                            }
                                                          }()),
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 12),
                                                    ),
                                                    subtitle: Text(
                                                      'Agency',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_senderWithAddress) {
                                                              return Colors.black87;
                                                            } else {
                                                              return Colors.white;
                                                            }
                                                          }()),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _senderWithAddress = true;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 5),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                            color: (() {
                                              if (_senderWithAddress) {
                                                return Theme.of(context).primaryColor;
                                              } else {
                                                return Colors.white;
                                              }
                                            }()),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    color: (() {
                                                      if (_senderWithAddress) {
                                                        return Colors.white;
                                                      } else {
                                                        return Theme.of(context)
                                                            .primaryColor;
                                                      }
                                                    }()),
                                                  ),
                                                  child: Image.asset(
                                                    "assets/illustrations/SendWithAddress.png",
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(
                                                      'Pickup from :',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_senderWithAddress) {
                                                              return Colors.white;
                                                            } else {
                                                              return Colors.black87;
                                                            }
                                                          }()),
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 12),
                                                    ),
                                                    subtitle: Text(
                                                      'Home address',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_senderWithAddress) {
                                                              return Colors.white;
                                                            } else {
                                                              return Colors.black87;
                                                            }
                                                          }()),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if(!_senderWithAddress)...[
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                controller: _senderAgency,
                                readOnly: true,
                                onTap: () async {
                                  var countryName = _fromCountry.text;
                                  var countryCode = _fromCountryCode.text;
                                  var cityName = _fromCity.text;
                                  var postalCode = _fromPostalCode.text;
                                  List listAgc = await _loadAgenciesSender(countryName,countryCode,cityName,postalCode);
                                  _fillModalAgenciesSender(listAgc);
                                },
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                                decoration: InputDecoration(
                                    labelText: "Agency",
                                    labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: Colors.black38, width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 2)),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color:
                                            Theme.of(context).primaryColor),
                                        child: Image.asset(
                                          "assets/icons/map-marker-Bold.png",
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        "assets/icons/chevron-down-Bold.png",
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fullNameSender,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Full name",
                                hintText: "John Fitzgerald",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/user-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _phoneNumberSender,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                hintText: "(+000) 000-000-000",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/mobile-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _emailSender,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "example@example.com",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/envelope-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _addressSender,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Address",
                                hintText: "Address",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/map-marker-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const FourthOrderStep(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Recipient Information
class FourthOrderStep extends StatefulWidget {
  const FourthOrderStep({super.key});

  @override
  State<FourthOrderStep> createState() => _FourthOrderStepState();
}

class _FourthOrderStepState extends State<FourthOrderStep> {
  bool _receiveWithAddress = true;

  Future<List> _loadAgenciesReceiver(countryName,countryCode,cityName,postalCode) async {
    String apiUrl = "https://boxpid.com/backend/view/order/getAgencyList.php";
    final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'app-id': appID,
          'email-adress': userLogin,
          'country-name': countryName,
          'country-code': countryCode,
          'city-name': cityName,
          'postal-code': postalCode
        }
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      List agencyList = responseData['data'];
      return agencyList;
    } else {
      // Handle error
      return [];
    }
  }

  void _fillModalAgenciesReceiver(List listValues) {
    var selectedValue = '';
    var selectedValueLibelle = '';
    var selectedValueInfos = '';
    var searchValue = '';

    if (listValues.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'Choose the agency:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 60,
                      width: double.infinity,
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 18.0, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black38, width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).primaryColor),
                              child: Image.asset(
                                "assets/icons/search-Bold.png",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchValue = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 250,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: listValues.where((agency) {
                            return searchValue.isEmpty ||
                                agency['libelle'].toLowerCase().contains(searchValue);
                          }).map((agency) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedValue = agency['id'].toString();
                                  selectedValueLibelle = agency['libelle'];
                                  selectedValueInfos = agency['infos'];
                                });
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                child: ListTile(
                                  title: Text(
                                    agency['libelle'],
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  trailing: Radio(
                                    value: agency['id'].toString(),
                                    groupValue: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = agency['id'].toString();
                                        selectedValueLibelle = agency['libelle'];
                                        selectedValueInfos = agency['infos'];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedValue.isNotEmpty && selectedValueLibelle.isNotEmpty) {
                              _receiverAgency.text = selectedValueInfos;
                            } else {
                              _receiverAgency.clear();
                            }
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      _showDialog('Something went wrong please try again later.', 'Error');
    }
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Recipient information",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 40,
                          end: 50,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Recipient information",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        if(receiveUsingAddress == null)...[
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _receiveWithAddress = false;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 5),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                            color: (() {
                                              if (_receiveWithAddress) {
                                                return Colors.white;
                                              } else {
                                                return Theme.of(context).primaryColor;
                                              }
                                            }()),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color: (() {
                                                        if (_receiveWithAddress) {
                                                          return Theme.of(context)
                                                              .primaryColor;
                                                        } else {
                                                          return Colors.white;
                                                        }
                                                      }()),
                                                      borderRadius:
                                                      BorderRadius.circular(10)),
                                                  child: Image.asset(
                                                    "assets/illustrations/house.png",
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(
                                                      'Receive in : ',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_receiveWithAddress) {
                                                              return Colors.black87;
                                                            } else {
                                                              return Colors.white;
                                                            }
                                                          }()),
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 12),
                                                    ),
                                                    subtitle: Text(
                                                      'Home address',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_receiveWithAddress) {
                                                              return Colors.black87;
                                                            } else {
                                                              return Colors.white;
                                                            }
                                                          }()),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _receiveWithAddress = true;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 5),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                            color: (() {
                                              if (_receiveWithAddress) {
                                                return Theme.of(context).primaryColor;
                                              } else {
                                                return Colors.white;
                                              }
                                            }()),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                    color: (() {
                                                      if (_receiveWithAddress) {
                                                        return Colors.white;
                                                      } else {
                                                        return Theme.of(context)
                                                            .primaryColor;
                                                      }
                                                    }()),
                                                  ),
                                                  child: Image.asset(
                                                    "assets/illustrations/agency.png",
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(
                                                      'Receive in : ',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_receiveWithAddress) {
                                                              return Colors.white;
                                                            } else {
                                                              return Colors.black87;
                                                            }
                                                          }()),
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 12),
                                                    ),
                                                    subtitle: Text(
                                                      'Agency',
                                                      style: TextStyle(
                                                          color: (() {
                                                            if (_receiveWithAddress) {
                                                              return Colors.white;
                                                            } else {
                                                              return Colors.black87;
                                                            }
                                                          }()),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if(!_receiveWithAddress)...[
                          Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                controller: _receiverAgency,
                                readOnly: true,
                                onTap: () async {
                                  var countryName = _toCountry.text;
                                  var countryCode = _toCountryCode.text;
                                  var cityName = _toCity.text;
                                  var postalCode = _toPostalCode.text;
                                  List listAgc = await _loadAgenciesReceiver(countryName,countryCode,cityName,postalCode);
                                  _fillModalAgenciesReceiver(listAgc);
                                },
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                                decoration: InputDecoration(
                                    labelText: "Agency",
                                    labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(
                                            color: Colors.black38, width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: BorderSide(
                                            color: Theme.of(context).primaryColor,
                                            width: 2)),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color:
                                            Theme.of(context).primaryColor),
                                        child: Image.asset(
                                          "assets/icons/map-marker-Bold.png",
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        "assets/icons/chevron-down-Bold.png",
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ],
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _fullNameReceiver,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Full name",
                                hintText: "John Fitzgerald",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/user-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _phoneNumberReceiver,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                hintText: "(+000) 000-000-000",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/mobile-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _emailReceiver,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Email",
                                hintText: "example@example.com",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/envelope-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _addressReceiver,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Address",
                                hintText: "Address",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/map-marker-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const FifthOrderStep(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Shipment detail
class FifthOrderStep extends StatefulWidget {
  const FifthOrderStep({super.key});

  @override
  State<FifthOrderStep> createState() => _FifthOrderStepState();
}

class _FifthOrderStepState extends State<FifthOrderStep> {
  void _addItem() {
    setState(() {
      lineItems.add({
        "number": lineItems.length + 1,
        "description": _description.text,
        "price": double.tryParse(_itemAmount.text) ?? 0,
        "quantity": {
          "value": int.tryParse(_itemQuantity.text) ?? 0,
          "unitOfMeasurement": "GM",
        },
        "manufacturerCountry": "MA", // Replace with user input if necessary
        "weight": {
          "netValue": double.parse(_itemNetValue.text), // Replace with user input if necessary
          "grossValue": double.parse(_itemNetValue.text) // Replace with user input if necessary
        }
      });

      // Clear the text fields
      _description.clear();
      _itemAmount.clear();
      _itemQuantity.clear();
      _itemNetValue.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Shipment detail",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 50,
                          end: 70,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Shipment detail",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        if(lineItems.length > 1)...[
                          Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                width: double.infinity,
                                child: Text(
                                  "Items count : ${(lineItems.length > 1) ? lineItems.length - 1 : 0}",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87),
                                ),
                              )),
                        ],
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _contents,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Contents",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/content-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _description,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Description",
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        color: Colors.black38, width: 1)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 2)),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Theme.of(context).primaryColor),
                                    child: Image.asset(
                                      "assets/icons/comment-dots-Bold.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                              bottom: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0.0),
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: 0),
                                    leading: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color:
                                            Theme.of(context).primaryColor),
                                        child: Image.asset(
                                          "assets/icons/map-marker-Bold.png",
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {},
                                      icon: Image.asset(
                                        "assets/icons/help-Bold.png",
                                        color: Theme.of(context).primaryColor,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: const Text(
                                      'Transaction',
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Flexible(
                                          child: TextField(
                                            controller: _itemAmount,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.left,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.all(0),
                                              labelText: "Amount",
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Flexible(
                                          child: TextField(
                                              controller: _itemQuantity,
                                              keyboardType:
                                              TextInputType.number,
                                              textAlign: TextAlign.left,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                EdgeInsets.all(0),
                                                labelText: "Quantity",
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              )),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: TextField(
                                            controller: _itemNetValue,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.left,
                                            decoration: const InputDecoration(
                                              contentPadding:
                                              EdgeInsets.all(0),
                                              labelText: "Weight",
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.only(
                                      right: 10,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _addItem,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                        side: const BorderSide(
                                            color: Colors.red, width: 2),
                                      ),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "Delete",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                child: Image.asset(
                                                  "assets/icons/minus-square-Bold.png",
                                                  color: Colors.red,
                                                  alignment: Alignment.centerRight,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _addItem,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xff1D3058),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "Add",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                child: Image.asset(
                                                  "assets/icons/plus-square-Bold.png",
                                                  color: Colors.white,
                                                  alignment: Alignment.centerRight,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )

                        // Flexible(
                        //     child: Container(
                        //   margin: const EdgeInsets.only(bottom: 20),
                        //   width: double.infinity,
                        //   child: const Text(
                        //     "Shipment detail",
                        //     textAlign: TextAlign.left,
                        //     style: TextStyle(
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.black87),
                        //   ),
                        // )),
                        // Flexible(
                        //   child: Container(
                        //     margin: const EdgeInsets.only(bottom: 20),
                        //     width: MediaQuery.of(context).size.width,
                        //     child: TextField(
                        //       controller: _contents,
                        //       style: const TextStyle(
                        //           fontSize: 18.0, color: Colors.black),
                        //       decoration: InputDecoration(
                        //         labelText: "Contents",
                        //         labelStyle: const TextStyle(
                        //             color: Colors.black,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.normal),
                        //         enabledBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: const BorderSide(
                        //                 color: Colors.black38, width: 1)),
                        //         focusedBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: BorderSide(
                        //                 color: Theme.of(context).primaryColor,
                        //                 width: 2)),
                        //         prefixIcon: Padding(
                        //           padding: const EdgeInsets.all(10),
                        //           child: Container(
                        //             width: 35,
                        //             height: 35,
                        //             decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(5),
                        //                 color: Theme.of(context).primaryColor),
                        //             child: Image.asset(
                        //               "assets/icons/content-Bold.png",
                        //               color: Colors.white,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Flexible(
                        //   child: Container(
                        //     margin: const EdgeInsets.only(bottom: 20),
                        //     width: MediaQuery.of(context).size.width,
                        //     child: TextField(
                        //       controller: _description,
                        //       keyboardType: TextInputType.phone,
                        //       style: const TextStyle(
                        //           fontSize: 18.0, color: Colors.black),
                        //       decoration: InputDecoration(
                        //         labelText: "Description",
                        //         labelStyle: const TextStyle(
                        //             color: Colors.black,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.normal),
                        //         enabledBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: const BorderSide(
                        //                 color: Colors.black38, width: 1)),
                        //         focusedBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide: BorderSide(
                        //                 color: Theme.of(context).primaryColor,
                        //                 width: 2)),
                        //         prefixIcon: Padding(
                        //           padding: const EdgeInsets.all(10),
                        //           child: Container(
                        //             width: 35,
                        //             height: 35,
                        //             decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(5),
                        //                 color: Theme.of(context).primaryColor),
                        //             child: Image.asset(
                        //               "assets/icons/comment-dots-Bold.png",
                        //               color: Colors.white,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Flexible(
                        //   child: Container(
                        //     width: double.infinity,
                        //     padding: const EdgeInsets.only(
                        //       left: 5,
                        //       right: 5,
                        //       top: 5,
                        //       bottom: 20,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(20),
                        //       border: Border.all(width: 1, color: Colors.grey),
                        //     ),
                        //     margin: const EdgeInsets.only(bottom: 20),
                        //     child: Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //       children: [
                        //         Flexible(
                        //           child: ListTile(
                        //             contentPadding: const EdgeInsets.symmetric(
                        //                 horizontal: 0.0, vertical: 0.0),
                        //             visualDensity: const VisualDensity(
                        //                 horizontal: 0, vertical: 0),
                        //             leading: Padding(
                        //               padding: const EdgeInsets.all(10),
                        //               child: Container(
                        //                 width: 35,
                        //                 height: 35,
                        //                 decoration: BoxDecoration(
                        //                     borderRadius:
                        //                         BorderRadius.circular(5),
                        //                     color:
                        //                         Theme.of(context).primaryColor),
                        //                 child: Image.asset(
                        //                   "assets/icons/map-marker-Bold.png",
                        //                   color: Colors.white,
                        //                 ),
                        //               ),
                        //             ),
                        //             trailing: IconButton(
                        //               onPressed: () {},
                        //               icon: Image.asset(
                        //                 "assets/icons/help-Bold.png",
                        //                 color: Theme.of(context).primaryColor,
                        //                 fit: BoxFit.cover,
                        //               ),
                        //             ),
                        //             title: const Text(
                        //               'Transaction',
                        //               style: TextStyle(
                        //                   color: Colors.black87,
                        //                   fontWeight: FontWeight.bold,
                        //                   fontSize: 18),
                        //             ),
                        //             onTap: () {},
                        //           ),
                        //         ),
                        //         Flexible(
                        //           child: Container(
                        //             width: double.infinity,
                        //             margin: const EdgeInsets.only(
                        //                 top: 10, left: 10, right: 10),
                        //             child: Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.start,
                        //               crossAxisAlignment:
                        //                   CrossAxisAlignment.center,
                        //               children: <Widget>[
                        //                 Flexible(
                        //                   child: TextField(
                        //                     controller: _itemAmount,
                        //                     keyboardType: TextInputType.number,
                        //                     textAlign: TextAlign.left,
                        //                     decoration: const InputDecoration(
                        //                       contentPadding: EdgeInsets.all(0),
                        //                       labelText: "Amount",
                        //                       labelStyle: TextStyle(
                        //                           color: Colors.black,
                        //                           fontSize: 15,
                        //                           fontWeight: FontWeight.w600),
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 const SizedBox(
                        //                   width: 10.0,
                        //                 ),
                        //                 Flexible(
                        //                   child: TextField(
                        //                       controller: _itemQuantity,
                        //                       keyboardType:
                        //                           TextInputType.number,
                        //                       textAlign: TextAlign.left,
                        //                       decoration: const InputDecoration(
                        //                         contentPadding:
                        //                             EdgeInsets.all(0),
                        //                         labelText: "Quantity",
                        //                         labelStyle: TextStyle(
                        //                             color: Colors.black,
                        //                             fontSize: 15,
                        //                             fontWeight:
                        //                                 FontWeight.w600),
                        //                       )),
                        //                 ),
                        //                 const SizedBox(
                        //                   width: 10.0,
                        //                 ),
                        //                 Flexible(
                        //                   flex: 2,
                        //                   child: TextField(
                        //                     controller: _itemCurrency,
                        //                     keyboardType: TextInputType.number,
                        //                     textAlign: TextAlign.left,
                        //                     decoration: InputDecoration(
                        //                       contentPadding:
                        //                           const EdgeInsets.all(0),
                        //                       labelText: "Currency",
                        //                       labelStyle: const TextStyle(
                        //                           color: Colors.black,
                        //                           fontSize: 15,
                        //                           fontWeight: FontWeight.w600),
                        //                       suffixIcon: Padding(
                        //                         padding:
                        //                             const EdgeInsets.all(5),
                        //                         child: Image.asset(
                        //                           "assets/icons/chevron-down-Bold.png",
                        //                           color: Theme.of(context)
                        //                               .primaryColor,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Flexible(
                        //   child: SizedBox(
                        //     width: double.infinity,
                        //     child: Row(
                        //       children: [
                        //         Expanded(
                        //           child: Container(
                        //             alignment: Alignment.center,
                        //             height: 50,
                        //             width: MediaQuery.of(context).size.width,
                        //             margin: const EdgeInsets.only(
                        //               right: 10,
                        //             ),
                        //             child: ElevatedButton(
                        //               onPressed: () {
                        //                 Navigator.of(context,
                        //                         rootNavigator: true)
                        //                     .push(
                        //                   CupertinoPageRoute<bool>(
                        //                     fullscreenDialog: false,
                        //                     builder: (BuildContext context) =>
                        //                         const SecondOrderStep(),
                        //                   ),
                        //                 );
                        //               },
                        //               style: ElevatedButton.styleFrom(
                        //                 backgroundColor: Colors.white,
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(15),
                        //                 ),
                        //                 side: const BorderSide(
                        //                     color: Colors.red, width: 2),
                        //               ),
                        //               child: Row(
                        //                 children: [
                        //                   const Expanded(
                        //                     child: Text(
                        //                       "Delete",
                        //                       textAlign: TextAlign.left,
                        //                       style: TextStyle(
                        //                           color: Colors.red,
                        //                           fontSize: 18,
                        //                           fontWeight: FontWeight.bold),
                        //                     ),
                        //                   ),
                        //                   Expanded(
                        //                       child: Container(
                        //                     alignment: Alignment.centerRight,
                        //                     child: Image.asset(
                        //                       "assets/icons/minus-square-Bold.png",
                        //                       color: Colors.red,
                        //                       alignment: Alignment.centerRight,
                        //                     ),
                        //                   ))
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //         Expanded(
                        //           child: Container(
                        //             alignment: Alignment.center,
                        //             height: 50,
                        //             width: MediaQuery.of(context).size.width,
                        //             margin: const EdgeInsets.only(
                        //               left: 10,
                        //             ),
                        //             child: ElevatedButton(
                        //               onPressed: () {
                        //                 Navigator.of(context,
                        //                         rootNavigator: true)
                        //                     .push(
                        //                   CupertinoPageRoute<bool>(
                        //                     fullscreenDialog: false,
                        //                     builder: (BuildContext context) =>
                        //                         const SecondOrderStep(),
                        //                   ),
                        //                 );
                        //               },
                        //               style: ElevatedButton.styleFrom(
                        //                 backgroundColor:
                        //                     const Color(0xff1D3058),
                        //                 shape: RoundedRectangleBorder(
                        //                   borderRadius:
                        //                       BorderRadius.circular(15),
                        //                 ),
                        //               ),
                        //               child: Row(
                        //                 children: [
                        //                   const Expanded(
                        //                     child: Text(
                        //                       "Add",
                        //                       textAlign: TextAlign.left,
                        //                       style: TextStyle(
                        //                           color: Colors.white,
                        //                           fontSize: 18,
                        //                           fontWeight: FontWeight.bold),
                        //                     ),
                        //                   ),
                        //                   Expanded(
                        //                       child: Container(
                        //                     alignment: Alignment.centerRight,
                        //                     child: Image.asset(
                        //                       "assets/icons/plus-square-Bold.png",
                        //                       color: Colors.white,
                        //                       alignment: Alignment.centerRight,
                        //                     ),
                        //                   ))
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const NinthOrderStep(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Shipments summary 2
class SixthOrderStep extends StatefulWidget {
  const SixthOrderStep({super.key});

  @override
  State<SixthOrderStep> createState() => _SixthOrderStepState();
}

class _SixthOrderStepState extends State<SixthOrderStep> {
  final TextEditingController _promoCode = TextEditingController();
  bool _cashplusIsSender = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Shipments summary",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 70,
                          end: 80,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity:
                            VisualDensity(horizontal: 0, vertical: -4),
                            title: Text(
                              "Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            subtitle: Text(
                              "Documents",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: Text(
                                    "Weight",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "0,5 Kg",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: Text(
                                    "Delay",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "72 Hours",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: Text(
                                    "From",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "Casablanca, 20000",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity(
                                      horizontal: 0, vertical: -4),
                                  title: Text(
                                    "To",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    "Alaska, 80230",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            visualDensity:
                            VisualDensity(horizontal: 0, vertical: -4),
                            title: Text(
                              "Delivery",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 12),
                            ),
                            subtitle: Text(
                              "Delivery estimated time 28/12/2020",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _promoCode,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.characters,
                      style:
                      const TextStyle(fontSize: 18.0, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Promo code",
                        labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black38, width: 1)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2)),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                            child: Image.asset(
                              "assets/icons/comment-dots-Bold.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _cashplusIsSender = false;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.only(
                                  bottom: 0,
                                  left: 10,
                                  right: 10,
                                  top: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.shade200),
                                  color: (() {
                                    if (_cashplusIsSender) {
                                      return Colors.white;
                                    } else {
                                      return Theme.of(context).primaryColor;
                                    }
                                  }()),
                                ),
                                child: ListTile(
                                  contentPadding:
                                  const EdgeInsets.only(left: 0.0, right: 0.0),
                                  visualDensity: const VisualDensity(
                                      horizontal: 0.0, vertical: -2),
                                  isThreeLine: true,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: (() {
                                          if (_cashplusIsSender) {
                                            return Theme.of(context).primaryColor;
                                          } else {
                                            return Colors.white;
                                          }
                                        }()),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Image.asset(
                                      "assets/illustrations/house.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: Text(
                                    'Send with : ',
                                    style: TextStyle(
                                        color: (() {
                                          if (_cashplusIsSender) {
                                            return Colors.black87;
                                          } else {
                                            return Colors.white;
                                          }
                                        }()),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    'Address',
                                    style: TextStyle(
                                        color: (() {
                                          if (_cashplusIsSender) {
                                            return Colors.black87;
                                          } else {
                                            return Colors.white;
                                          }
                                        }()),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            )),
                        Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _cashplusIsSender = true;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 5),
                                padding: const EdgeInsets.only(
                                  bottom: 0,
                                  left: 10,
                                  right: 10,
                                  top: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.shade200),
                                  color: (() {
                                    if (_cashplusIsSender) {
                                      return Theme.of(context).primaryColor;
                                    } else {
                                      return Colors.white;
                                    }
                                  }()),
                                ),
                                child: ListTile(
                                  contentPadding:
                                  const EdgeInsets.only(left: 0.0, right: 0.0),
                                  visualDensity: const VisualDensity(
                                      horizontal: 0.0, vertical: -2),
                                  isThreeLine: true,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (() {
                                        if (_cashplusIsSender) {
                                          return Colors.white;
                                        } else {
                                          return Theme.of(context).primaryColor;
                                        }
                                      }()),
                                    ),
                                    child: Image.asset(
                                      "assets/illustrations/cashplus_logo.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  title: Text(
                                    'Send with : ',
                                    style: TextStyle(
                                        color: (() {
                                          if (_cashplusIsSender) {
                                            return Colors.white;
                                          } else {
                                            return Colors.black87;
                                          }
                                        }()),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    'CASHPLUS',
                                    style: TextStyle(
                                        color: (() {
                                          if (_cashplusIsSender) {
                                            return Colors.white;
                                          } else {
                                            return Colors.black87;
                                          }
                                        }()),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 0, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Amount",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "725,00 DH TTC",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Discount",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey,
                                          fontSize: 15),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "7,00 DH TTC",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          fontSize: 18),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: const ListTile(
                                contentPadding: EdgeInsets.zero,
                                visualDensity:
                                VisualDensity(horizontal: 0, vertical: -4),
                                title: Text(
                                  "Total amount",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  "723,00 DH TTC",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      fontSize: 22),
                                ),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 5, left: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        topRight: Radius.circular(100),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    height: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const NinthOrderStep(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Create pickup
class NinthOrderStep extends StatefulWidget {
  const NinthOrderStep({super.key});

  @override
  State<NinthOrderStep> createState() => _NinthOrderStepState();
}

class _NinthOrderStepState extends State<NinthOrderStep> {

  void _showDatePicker() {
    var minDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 1);
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: CupertinoColors.systemBackground,
        padding: const EdgeInsets.only(
            bottom: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                minimumDate: minDate,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    selectedDate = newDateTime;
                  });
                },
              ),
            ),
            CupertinoButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  // _pickupDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                  _pickupDate.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showDialog2(String message, String title) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute<bool>(
                        fullscreenDialog: false,
                        builder: (BuildContext context) =>
                            MyShipmentsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> createShipment() async {
    print(userId);
    String apiUrl = "https://boxpid.com/backend/view/order/createShipmentOrder.php";

    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'app_id': appID,
        'id_user': userId.toString(),
        'shipper_postal_code': _fromPostalCode.text,
        'shipper_city_name': _fromCity.text,
        'shipper_country_code': _fromCountryCode.text,
        'shipper_address_line1': _addressSender.text,
        'shipper_country_name': _fromCountry.text,
        'shipper_phone': _phoneNumberSender.text,
        'shipper_full_name': _fullNameSender.text,
        'shipper_email_address': _emailSender.text,
        'receiver_postal_code': _toPostalCode.text,
        'receiver_city_name': _toCity.text,
        'receiver_country_code': _toCountryCode.text,
        'receiver_address_line1': _addressReceiver.text,
        'receiver_country_name': _toCountry.text,
        'receiver_phone': _phoneNumberReceiver.text,
        'receiver_full_name': _fullNameReceiver.text,
        'receiver_email_address': _emailReceiver.text,
        'is_document': isDocument.toString(),
        'package_weight': (double.parse(_packageRealWeight.text) >= double.parse(_packageRealisticWeight.text)) ? _packageRealWeight.text : _packageRealisticWeight.text,
        'package_length': _packageLength.text,
        'package_width': _packageWidth.text,
        'package_height': _packageHeight.text,
        'line_items_list': jsonEncode(lineItems), // Example of line items list
        'declared_value_amount': '100',
        'declared_value_currency': 'USD',
        'pickup_postal_code': _fromPostalCode.text,
        'pickup_city_name': _fromCity.text,
        'pickup_country_code': _fromCountryCode.text,
        'pickup_address_line1': _addressSender.text,
        'pickup_country_name': _fromCountry.text,
        'pickup_email_address': _emailSender.text,
        'pickup_phone': _phoneNumberSender.text,
        'pickup_full_name': _fullNameSender.text,
        'is_export': isExport.toString(),
        'planned_date_and_time': '${_pickupDate.text}T${_pickupTimeTo.text}:00 GMT+01:00',
        'total_price': shipmentPriceTotal.toString(),
      },
    );

    print(response.body);
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['NOTE'] == "OK") {
      _showDialog2('Your order has been created successfully.', 'Note');
    } else {
      // Handle error
      final String errorMessage = responseData['message'] ?? 'An error occurred';
      _showDialog(errorMessage, 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Create pickup",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 80,
                          end: 90,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              width: double.infinity,
                              child: const Text(
                                "Shipment detail",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            )),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            child: TextField(
                              controller: _pickupDate,
                              readOnly: true,
                              onTap: () {
                                _showDatePicker();
                              },
                              style: const TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: "Create pickup",
                                  labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Colors.black38, width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2)),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color:
                                          Theme.of(context).primaryColor),
                                      child: Image.asset(
                                        "assets/icons/calendar-Bold.png",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/icons/chevron-down-Bold.png",
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                              bottom: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0.0, vertical: 0.0),
                                    visualDensity: const VisualDensity(
                                        horizontal: 0, vertical: 0),
                                    leading: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            color:
                                            Theme.of(context).primaryColor),
                                        child: Image.asset(
                                          "assets/icons/map-marker-Bold.png",
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {},
                                      icon: Image.asset(
                                        "assets/icons/help-Bold.png",
                                        color: Theme.of(context).primaryColor,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: const Text(
                                      'Time range',
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Flexible(
                                          child: TextField(
                                            controller: _pickupTimeFrom,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.left,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.all(0),
                                              labelText: "From",
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 50.0,
                                        ),
                                        Flexible(
                                          child: TextField(
                                              controller: _pickupTimeTo,
                                              keyboardType:
                                              TextInputType.number,
                                              textAlign: TextAlign.left,
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                EdgeInsets.all(0),
                                                labelText: "To",
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                          activeTrackColor:
                                          Theme.of(context).primaryColor,
                                          inactiveTrackColor:
                                          Colors.grey.shade300,
                                          thumbColor:
                                          Theme.of(context).primaryColor,
                                          trackHeight: 1,
                                          overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 1),
                                          thumbShape:
                                          const RoundSliderThumbShape(
                                              enabledThumbRadius: 8.0,
                                              pressedElevation: 1.0)),
                                      child: RangeSlider(
                                        onChanged: (RangeValues values) {
                                          setState(() {
                                            // Ensure the values stay within the min and max range
                                            if (values.start < 9) {
                                              values = RangeValues(9, values.end);
                                            }
                                            if (values.end > 17) {
                                              values = RangeValues(values.start, 17);
                                            }

                                            _pickupTimeFrom.text = '${values.start.round()}:00';
                                            _pickupTimeTo.text = '${values.end.round()}:00';
                                            pickUpTimeRangeValue = values;
                                          });
                                        },
                                        values: pickUpTimeRangeValue,
                                        min: 9,
                                        max: 17,
                                        divisions: 8,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        createShipment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}

// Payment page
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  var controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url == 'https://boxpid.com/backend/payment/Ok-Fail.php') {
            return NavigationDecision.prevent;
          }else if(request.url.startsWith('https://boxpid.com/backend/payment/Ok-Fail.php') && request.url.startsWith('https://boxpid.com')){
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://boxpid.com/backend/payment/1.PaymentRequest.php?EMAIL=elke.ayoub@gmail.com&ID=1&TOTAL=10&FULLNAME=AYOUB ELKEBBAR&TRACKINGID=1234'));

  // @override
  // void initState() {
  //   super.initState();
  //   controller = WebViewController()
  //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //     ..setBackgroundColor(const Color(0x00000000))
  //     ..setNavigationDelegate(
  //       NavigationDelegate(
  //         onProgress: (int progress) {
  //           // Update loading bar.
  //         },
  //         onPageStarted: (String url) {},
  //         onPageFinished: (String url) {},
  //         onWebResourceError: (WebResourceError error) {},
  //         onNavigationRequest: (NavigationRequest request) {
  //           if (request.url == 'https://boxpid.com/backend/payment/Ok-Fail.php') {
  //             Future.microtask(() {
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(builder: (context) => const MyShipments()),
  //               );
  //             });
  //             return NavigationDecision.prevent;
  //           } else if(request.url == 'https://boxpid.com/backend/payment/fail.php'){
  //             Navigator.pop(context);
  //           }
  //           return NavigationDecision.prevent;
  //         },
  //       ),
  //     )
  //     ..loadRequest(Uri.parse('https://boxpid.com/backend/payment/1.PaymentRequest.php?EMAIL=elke.ayoub@gmail.com&ID=1&TOTAL=10&FULLNAME=AYOUB ELKEBBAR&TRACKINGID=1234'));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Payment",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            icon: Image.asset(
              "assets/icons/chevron-left-Bold.png",
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          )),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 90,
                          end: 95,
                        ),
                        builder: (context, value, _) {
                          return SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                                activeTrackColor:
                                Theme.of(context).primaryColor,
                                inactiveTrackColor: Colors.grey.shade300,
                                thumbColor: Theme.of(context).primaryColor,
                                trackHeight: 1,
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 1),
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    pressedElevation: 1.0)),
                            child: Slider(
                                onChanged: (value) => print(value),
                                value: value,
                                min: 0,
                                max: 100),
                          );
                        }),
                  ),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
                            height: 600,
                            width: double.infinity,
                            color: Colors.red,
                            child: WebViewWidget(controller: controller,),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(
                        top: 10, right: 10, left: 10, bottom: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          CupertinoPageRoute<bool>(
                            fullscreenDialog: false,
                            builder: (BuildContext context) =>
                            const ThirdOrderStep(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1D3058),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Next",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Image.asset(
                                    "assets/icons/arrow-right-Bold.png",
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}


//class MyShipments extends StatefulWidget {
//  const MyShipments({super.key});

//  @override
//  State<MyShipments> createState() => _MyShipmentsState();
//}

//class _MyShipmentsState extends State<MyShipments> {
//  final GlobalKey<ScaffoldState> _key = GlobalKey();
//  List shipmentsUser = [];
//  @override
//  void initState() {
//    super.initState();
//    _fetchUserShipments();
//  }

//  Future<void> _fetchUserShipments() async {
//    String apiUrl = "https://boxpid.com/backend/view/order/readUserShipmentOrders.php";
//    final response = await http.post(
//      Uri.parse(apiUrl),
//      body: {
//        'app-id': appID,
//        'email-user': userLogin
//      },
//    );

//    final Map<String, dynamic> responseData = json.decode(response.body);
//    if (response.statusCode == 200 && responseData['NOTE'] == 'OK') {
//      shipmentsUser = responseData['shipments'];
//    } else {
//      // Handle error
//      const String errorMessage = 'An error occurred';
//      print(errorMessage);
//    }
//  }

//  Future<void> _fetchShipmentDetails(trackingNumber) async {
//    String apiUrl = "https://boxpid.com/backend/view/order/trackShipmentOrder.php";
//    final response = await http.post(
//      Uri.parse(apiUrl),
//      body: {
//        'app-id': appID,
//        'tracking-number': trackingNumber,
//      },
//    );

//    final Map<String, dynamic> responseData = json.decode(response.body);
//    if (response.statusCode == 200 && responseData['NOTE'] == 'OK') {
//      Map<String, dynamic> shipmentDetail = responseData['data'];
//      Navigator.push(
//        context,
//        MaterialPageRoute(
//          builder: (context) => const MyShipmentDtl(),
//        ),
//      );
//    } else {
//      // Handle error
//      String errorMessage = 'Something went wrong please try again later.';
//      _showDialog(errorMessage,'Error');
//    }
//  }

//  void _showDialog(String message, String title) {
//    showModalBottomSheet(
//      context: context,
//      builder: (ctx) {
//        return Container(
//          padding: const EdgeInsets.all(20),
//          width: double.infinity,
//          child: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              Container(
//                width: double.infinity,
//                margin: const EdgeInsets.only(bottom: 20),
//                child: Text(
//                  title,
//                  style: const TextStyle(
//                    fontSize: 20,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//              ),
//              Container(
//                width: double.infinity,
//                margin: const EdgeInsets.only(bottom: 20),
//                child: Text(
//                  message,
//                  style: const TextStyle(
//                    fontSize: 16,
//                    fontWeight: FontWeight.normal,
//                  ),
//                ),
//              ),
//              SizedBox(
//                width: double.infinity,
//                height: 50,
//                child: ElevatedButton(
//                  onPressed: () {
//                    Navigator.of(ctx).pop();
//                  },
//                  style: ElevatedButton.styleFrom(
//                    backgroundColor: Theme.of(context).primaryColor,
//                    shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.circular(15),
//                    ),
//                  ),
//                  child: const Text(
//                    "Close",
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      color: Colors.white,
//                      fontSize: 20,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//              )
//            ],
//          ),
//        );
//      },
//    );
//  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      key: _key,
//      appBar: AppBar(
//        backgroundColor: Colors.white,
//        elevation: 0,
//        leading: IconButton(
//          icon: Image.asset(
//            "assets/icons/chevron-left-Bold.png",
//            color: Theme.of(context).primaryColor,
//          ),
//          onPressed: () => Navigator.pop(context),
//        ),
//        actions: [
//          IconButton(
//            padding: EdgeInsets.zero,
//            icon: Image.asset(
//              "assets/icons/user-Bold.png",
//              color: Theme.of(context).primaryColor,
//            ),
//            onPressed: () {},
//          )
//        ],
//      ),
//      body: Container(
//          width: double.infinity,
//          height: double.infinity,
//          padding: const EdgeInsets.all(15),
//          decoration: const BoxDecoration(
//            color: Colors.white,
//          ),
//          child: SingleChildScrollView(
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.start,
//              mainAxisSize: MainAxisSize.min,
//crossAxisAlignment: CrossAxisAlignment.stretch,
//              children: [
//                Flexible(
//                    child: InkWell(
//                      onTap: () {
//                        String trackingNumber = "BP123456";
//                        _fetchShipmentDetails(trackingNumber);
//                      },
//                      child: Container(
//                          width: double.infinity,
//                          margin: const EdgeInsets.only(
//                            bottom: 30,
//                          ),
//                          padding: const EdgeInsets.only(
//                              top: 20, bottom: 20, left: 15, right: 15),
//                          decoration: BoxDecoration(
//                              color: const Color(0xffF5F6F9),
//                              borderRadius: BorderRadius.circular(15)),
//                          child: Column(
//                            mainAxisSize: MainAxisSize.min,
//                            children: [
//                              Flexible(
//                                child: Container(
//                                  width: double.infinity,
//                                  margin: const EdgeInsets.only(
//                                      bottom: 5
//                                  ),
//                                  child: Text(
//                                    '# BP123456',
//                                    textAlign: TextAlign.left,
//                                    style: TextStyle(
//                                        fontWeight: FontWeight.bold,
//                                        fontSize: 20,
//                                        color: Theme.of(context).primaryColor
//                                    ),
//                                  ),
//                                ),
//                              ),
//                              Flexible(
//                                child: Container(
//                                  width: double.infinity,
//                                  margin: const EdgeInsets.only(
//                                      bottom: 5
//                                  ),
//                                  child: const Row(
//                                    children: [
//                                      Expanded(
//                                        child: Text(
//                                          'Morocco',
//                                          textAlign: TextAlign.left,
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.normal,
//                                              fontSize: 15,
//                                              color: Colors.black87
//                                          ),
//                                        ),
//                                      ),
//                                      Expanded(
//                                        child: Text(
//                                          'Morocco',
//                                          textAlign: TextAlign.right,
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.normal,
//                                              fontSize: 15,
//                                              color: Colors.black87
//                                          ),
//                                        ),
//                                      )
//                                    ],
//                                  ),
//                                ),
//                              ),
//                              Flexible(
//                                child: Container(
//                                  width: double.infinity,
//                                  margin: const EdgeInsets.only(
//                                      bottom: 5
//                                  ),
//                                  child: Row(
//                                    children: [
//                                      Expanded(
//                                        child: Text(
//                                          ((){
//                                            DateTime now = DateTime.now();
//                                            return DateTime(now.year, now.month, now.day).toString().replaceAll("00:00:00.000", "");
//                                          }()),
//                                          textAlign: TextAlign.left,
//                                          style: const TextStyle(
//                                              fontWeight: FontWeight.normal,
//                                              fontSize: 17,
//                                              color: Colors.black87
//                                          ),
//                                        ),
//                                      ),
//                                      const Expanded(
//                                        child: Text(
//                                          'Express',
//                                          textAlign: TextAlign.right,
//                                          style: TextStyle(
//                                              fontWeight: FontWeight.normal,
//                                              fontSize: 17,
//                                              color: Colors.black87
//                                          ),
//                                        ),
//                                      )
//                                    ],
//                                  ),
//                                ),
//                              ),
//                            ],
//                          )
//                      ),
//                    )
//                ),
//                for(var i = 0;i < shipmentsUser.length;i++)...[
//                  Flexible(
//                      child: InkWell(
//                        onTap: () {
//                          String trackingNumber = shipmentsUser[i]['tracking_number'];
//                          _fetchShipmentDetails(trackingNumber);
//                        },
//                        child: Container(
//                            width: double.infinity,
//                            margin: const EdgeInsets.only(
//                              bottom: 30,
//                            ),
//                            padding: const EdgeInsets.only(
//                                top: 20, bottom: 20, left: 15, right: 15),
//                            decoration: BoxDecoration(
//                                color: const Color(0xffF5F6F9),
//                                borderRadius: BorderRadius.circular(15)),
//                            child: Column(
//                              mainAxisSize: MainAxisSize.min,
//                              children: [
//                                Flexible(
//                                  child: Container(
//                                    width: double.infinity,
//                                    margin: const EdgeInsets.only(
//                                        bottom: 5
//                                    ),
//                                    child: Text(
//                                      '# TN' + shipmentsUser[i]['tracking_number'],
//                                      textAlign: TextAlign.left,
//                                      style: TextStyle(
//                                          fontWeight: FontWeight.bold,
//                                          fontSize: 20,
//                                          color: Theme.of(context).primaryColor
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                Flexible(
//                                  child: Container(
//                                    width: double.infinity,
//                                    margin: const EdgeInsets.only(
//                                        bottom: 5
//                                    ),
//                                    child: Row(
//                                      children: [
//                                        Expanded(
//                                          child: Text(
//                                            shipmentsUser[i]['origin_country'],
//                                            textAlign: TextAlign.left,
//                                            style: const TextStyle(
//                                                fontWeight: FontWeight.normal,
//                                                fontSize: 15,
//                                                color: Colors.black87
//                                            ),
//                                          ),
//                                        ),
//                                        Expanded(
//                                          child: Text(
//                                            shipmentsUser[i]['distination_country'],
//                                            textAlign: TextAlign.right,
//                                            style: const TextStyle(
//                                                fontWeight: FontWeight.normal,
//                                                fontSize: 15,
//                                                color: Colors.black87
//                                            ),
//                                          ),
//                                        )
//                                      ],
//                                    ),
//                                  ),
//                                ),
//                                Flexible(
//                                  child: Container(
//                                    width: double.infinity,
//                                    margin: const EdgeInsets.only(
//                                        bottom: 5
//                                    ),
//                                    child: Row(
//                                      children: [
//                                        Expanded(
//                                          child: Text(
//                                            ((){
//                                              DateTime dateTime = DateTime.parse(shipmentsUser[i]['pick_up_date']);
//                                              return DateFormat('yyyy-MM-dd').format(dateTime);
//                                            }()),
//                                            textAlign: TextAlign.left,
//                                            style: const TextStyle(
//                                                fontWeight: FontWeight.normal,
//                                                fontSize: 17,
//                                                color: Colors.black87
//                                            ),
//                                          ),
//                                        ),
//                                        Expanded(
//                                          child: Text(
//                                            shipmentsUser[i]['pick_up_time'],
//                                            textAlign: TextAlign.right,
//                                            style: const TextStyle(
//                                                fontWeight: FontWeight.normal,
//                                                fontSize: 17,
//                                                color: Colors.black87
//                                            ),
//                                          ),
//                                        )
//                                      ],
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            )
//                        ),
//                      )
//                  ),
//                ],
//              ],
//            ),
//          )),
//    );
//  }
//}



//class MyShipmentDtl extends StatefulWidget {
//  const MyShipmentDtl({super.key});

//  @override
//  State<MyShipmentDtl> createState() => _MyShipmentDtlState();
//}

//class _MyShipmentDtlState extends State<MyShipmentDtl> {
//  final GlobalKey<ScaffoldState> _key = GlobalKey();
//  List<Map<String, dynamic>> shipmentDetail = [
//    {
//      'shipmentDate': DateTime.now().toString().split(' ')[0],
//      'totalWeight': '1',
//      'shipperName': 'Ayoub ELKEBBAR',
//      'shipperCityName': 'Casablanca',
//      'shipperPostalCode': '20250',
//      'receiverName': 'Amine IRAQI',
//      'receiverCityName': 'Marrakech',
//      'receiverPostalCode': '30000',
//      'events': {
//        'date': DateTime.now().toString().split(' ')[0],
//        'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
//        'description': 'Order created'
//      }
//    }
//  ];
//  @override
//  void initState() {
//    super.initState();
//  }

//  Future<void> _fetchShipmentDetails(trackingNumber) async {
//    String apiUrl = "https://boxpid.com/backend/view/order/trackShipmentOrder.php";
//    final response = await http.post(
//      Uri.parse(apiUrl),
//      body: {
//        'app-id': appID,
//        'tracking-number': trackingNumber,
//      },
//    );

//    final Map<String, dynamic> responseData = json.decode(response.body);
//    if (response.statusCode == 200 && responseData['NOTE'] == 'OK') {
//      shipmentDetail = responseData['data'];
//      print(shipmentDetail);
//    } else {
//      // Handle error
//      String errorMessage = 'Something went wrong please try again later.';
//      _showDialog(errorMessage,'Error');
//    }
//  }

// --to add the last bit in Notepad --
