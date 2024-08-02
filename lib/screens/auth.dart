import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mill_project/screens/MainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO : use shared preferences package for validate once and googleAuth for OTP verification
//remember must be involved at main function
class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    //for phone number
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController controller = TextEditingController();
    String initialCountry = 'MY';
    PhoneNumber number = PhoneNumber(isoCode: 'MY');

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      return Colors.blue;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              Image.asset(
                'assets/upmlogo.png',
                width: 280,
                height: 120,
                alignment: Alignment.topLeft,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  'Welcome !',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFD9D9D9),
                          borderRadius: BorderRadius.circular(
                              10), // Optional: To add rounded corners
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // Spread radius of the shadow
                              blurRadius: 4, // Blur radius of the shadow
                              offset: Offset(0, 3), // Offset of the shadow
                            ),
                          ],
                        ),
                        height: 360,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 280,
                                        child: Text(
                                          'Enter your mobile number to activate your account.',
                                          style: TextStyle(fontSize: 18),
                                        )),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.info_outline),
                                      tooltip:
                                          'Only registered number can\nrequest for activation.',
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 20, 0, 40),
                                        child: SizedBox(
                                          width: 320,
                                          child: InternationalPhoneNumberInput(
                                              inputDecoration: InputDecoration(
                                                isCollapsed: true,
                                                contentPadding:
                                                    EdgeInsets.all(10),
                                                suffixIconColor: Colors.white,
                                                filled: true,
                                                fillColor: Colors
                                                    .white, // Change the background color here
                                                border: OutlineInputBorder(),
                                              ),
                                              onInputChanged:
                                                  (PhoneNumber number) {
                                                print(number.phoneNumber);
                                              },
                                              onInputValidated: (bool value) {
                                                print(value);
                                              },
                                              selectorConfig: SelectorConfig(
                                                selectorType:
                                                    PhoneInputSelectorType
                                                        .BOTTOM_SHEET,
                                              ),
                                              ignoreBlank: false,
                                              autoValidateMode:
                                                  AutovalidateMode.disabled,
                                              selectorTextStyle: TextStyle(
                                                  color: Colors.black),
                                              initialValue: number,
                                              textFieldController: controller,
                                              formatInput: true,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true,
                                                      decimal: true),
                                              inputBorder: OutlineInputBorder(),
                                              onSaved: (PhoneNumber number) {
                                                print('On Saved: $number');
                                              }),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Checkbox(
                                            checkColor: Colors.white,
                                            fillColor: MaterialStateProperty
                                                .resolveWith(getColor),
                                            value: isChecked,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isChecked = value!;
                                              });
                                            },
                                          ),
                                          Text(
                                              'I agree to the terms & conditions'),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          //currently only check if phone number in valid form
                                          //TODO : Need to add condition here to check if they are registered (found in records) and do OTP
                                          if (formKey.currentState!
                                                  .validate() &&
                                              isChecked) {
                                            Navigator.pushReplacement(context,
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return MainPage();
                                            }));
                                          }
                                        },
                                        child: Text(
                                          'Get Activation Code',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Disclaimer | Privacy Statement',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ),
              ),
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Copyright UPM & Kejuruteraan Minyak Sawit',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'CCS Sdn. Bhd.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
