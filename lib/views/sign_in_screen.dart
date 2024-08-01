import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_and_learn_app/views/home_view.dart';

import '../cubit/register/Register_Cubit.dart';
import '../cubit/register/Register_States.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsetsDirectional.all(20.w),
                          child: const Text(
                            'Already a learner? let\'s find out!',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w800),
                          ),
                        ),

                        Container(
                          margin: EdgeInsetsDirectional.only(start: 20,end: 20,bottom: 20,top: 20),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) return 'Enter a valid email';
                            },
                            controller: emailController,
                            decoration: InputDecoration(
                                label: const Text('Email'),
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.r))),
                          ),
                        ),

                        Container(
                          margin: EdgeInsetsDirectional.only(start: 20,end: 20,bottom: 20),
                          child: TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (value!.isEmpty) return 'Password is empty';
                            },
                            obscureText: passHidden,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                                label: const Text('Password'),
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      passHidden = !passHidden;
                                      cubit.changeVisibility();
                                    },
                                    icon: const Icon(
                                        Icons.remove_red_eye_outlined)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.r))),
                          ),
                        ),

                        state is LoginLoadingState
                            ? Container(
                                margin: EdgeInsetsDirectional.all(30.w),
                                child: const CupertinoActivityIndicator())
                            : Container(
                                margin: EdgeInsets.all(20.w),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8C00FF),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 80.w, vertical: 20.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      cubit.loginUser(
                                          email: emailController.text
                                              .trim()
                                              .toString(),
                                          password: passwordController.text
                                              .toString());
                                    }
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),

                        // line
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 60.w),
                          child: const Expanded(
                            child: Divider(
                              color: Color(0x208C00FF),
                            ),
                          ),
                        ),

                        // already learner button
                        Container(
                          child: MaterialButton(
                              onPressed: () {
                                // go to SignInScreen

                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Not a learner? Sign up',
                                style: TextStyle(
                                  color: Color(0xFF8C00FF),
                                ),
                              )),
                        )
                      ],
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
