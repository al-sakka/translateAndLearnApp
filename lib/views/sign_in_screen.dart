import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_and_learn_app/services/localization_service.dart';
import 'package:translate_and_learn_app/views/home_view.dart';

import '../cubit/register/Register_Cubit.dart';
import '../cubit/register/Register_States.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final LocalizationService _localizationService = LocalizationService();
  late Future<String> _alreadyTranslation;

  @override
  void initState() {
    super.initState();
    _alreadyTranslation = _localizationService.fetchFromFirestore(
        'Already a learner? let\'s find out!',
        'Already a learner? let\'s find out!');
  }

  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormState>();

    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    var passHidden = true;

    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        builder: (context, state) {
          var cubit = RegisterCubit.get(context);

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 20.h),
                            child: FutureBuilder<String>(
                                future: _alreadyTranslation,
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? '',
                                    style: TextStyle(
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  );
                                }),
                          ),

                          // Email Input
                          Container(
                            margin: EdgeInsets.only(bottom: 20.h),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Enter a valid email';
                              },
                              controller: emailController,
                              decoration: InputDecoration(
                                  label: FutureBuilder<String>(
                                    future: LocalizationService()
                                        .fetchFromFirestore('Email', 'Email'),
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data ?? '',
                                      );
                                    },
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.r))),
                            ),
                          ),

                          // Password Input
                          Container(
                            margin: EdgeInsets.only(bottom: 20.h),
                            child: TextFormField(
                              controller: passwordController,
                              validator: (value) {
                                if (value!.isEmpty) return 'Password is empty';
                              },
                              obscureText: passHidden,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  label: FutureBuilder<String>(
                                    future: LocalizationService()
                                        .fetchFromFirestore(
                                      'Password',
                                      'Password',
                                    ),
                                    builder: (context, snapshot) {
                                      return Text(snapshot.data ?? '');
                                    },
                                  ),
                                  prefixIcon:
                                      const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passHidden = !passHidden;
                                        });
                                      },
                                      icon: const Icon(
                                          Icons.remove_red_eye_outlined)),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.r))),
                            ),
                          ),

                          // Sign In Button
                          state is LoginLoadingState
                              ? Container(
                                  margin: EdgeInsets.all(30.w),
                                  child: const CupertinoActivityIndicator())
                              : Container(
                                  margin: EdgeInsets.only(top: 20.h),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8C00FF),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 80.w, vertical: 20.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        cubit.loginUser(
                                          email: emailController.text
                                              .trim()
                                              .toString(),
                                          password: passwordController.text
                                              .toString(),
                                        );
                                      }
                                    },
                                    child: FutureBuilder<String>(
                                      future: LocalizationService()
                                          .fetchFromFirestore(
                                        'Sign In',
                                        'Sign In',
                                      ),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? '',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                          // Divider
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20.h),
                            child: Divider(
                              color: const Color(0x208C00FF),
                              thickness: 1,
                            ),
                          ),

                          // Already Learner Button
                          Container(
                            margin: EdgeInsets.only(bottom: 20.h),
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: FutureBuilder<String>(
                                future:
                                    LocalizationService().fetchFromFirestore(
                                  'Not a learner? Sign up',
                                  'Not a learner? Sign up',
                                ),
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF8C00FF),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, Object? state) async {
          if (state is LoginSuccessState) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasSeenWelcome', true);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false);
          }
        },
      ),
    );
  }
}
