import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_and_learn_app/cubit/register/Register_Cubit.dart';
import 'package:translate_and_learn_app/cubit/register/Register_States.dart';
import 'package:translate_and_learn_app/views/home_view.dart';
import 'package:translate_and_learn_app/views/sign_in_screen.dart';

Future<String?> getSelectedLanguageString() async
{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? nativeLanguage = prefs.getString('nativeLanguage');
  String? nativeLanguageCode = prefs.getString('nativeLanguageCode');

  if (nativeLanguage != null && nativeLanguageCode != null)
  {
    return '$nativeLanguage ($nativeLanguageCode)';
  }
  else
  {
    return 'No language selected';
  }
}

class SignUpScreen extends StatefulWidget
{
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? selectedLanguageString;

  @override
  void initState()
  {
    super.initState();
    _loadSelectedLanguageString();
  }

  Future<void> _loadSelectedLanguageString() async
  {
    String? languageString = await getSelectedLanguageString();
    setState(() {
      selectedLanguageString = languageString;
    });
  }

  @override
  Widget build(BuildContext context)
  {

    var formKey = GlobalKey<FormState>();

    var nameController = TextEditingController();
    var emailController    = TextEditingController();
    var passwordController = TextEditingController();

    var passHidden = true;

    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>
        (
        builder: (context,state)
        {
          var cubit = RegisterCubit.get(context);

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sign up text
                        Container(
                          margin: EdgeInsetsDirectional.all(20),
                          child: Text(
                            'Let\'s sign you up!',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                        ),

                        // name input
                        Container(
                          margin: EdgeInsetsDirectional.all(20),
                          child: TextFormField(
                            validator: (value)
                            {
                              if(value!.isEmpty) return 'Enter your name';
                            },
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                                label: Text('Name'),
                                prefixIcon: Icon(Icons.person_outline_rounded),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)
                                )
                            ),
                          ),
                        ),

                        // Email input
                        Container(
                          margin: EdgeInsetsDirectional.all(20),
                          child: TextFormField(
                            validator: (value)
                            {
                              if(value!.isEmpty) return 'Enter a valid email';
                            },
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                label: Text('Email'),
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)
                                )
                            ),
                          ),
                        ),

                        // password input
                        Container(
                          margin: EdgeInsetsDirectional.all(20),
                          child: TextFormField(
                            controller: passwordController,
                            validator: (value)
                            {
                              if(value!.isEmpty) return 'Password is empty';
                            },
                            obscureText: passHidden,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                                label: Text('Password'),
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                    onPressed: ()
                                    {
                                      passHidden = !passHidden;
                                      cubit.changeVisibility();
                                    },
                                    icon : Icon(Icons.remove_red_eye_outlined)
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)
                                )
                            ),
                          ),
                        ),

                        // Sign up button
                        state is RegisterNewUserLoadingState
                            ?
                        Container(
                            margin: EdgeInsetsDirectional.all(30),
                            child: CupertinoActivityIndicator()
                        )
                            :
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8C00FF),
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: ()
                            async {
                              if(formKey.currentState!.validate())
                              {
                                String? selectedLanguage = await getSelectedLanguageString();

                                cubit.registerNewUser(
                                    name: nameController.text.trim().toString(),
                                    email: emailController.text.trim().toString(),
                                    password: passwordController.text.trim().toString(),
                                    language: selectedLanguage ?? "Not Defined"
                                );
                              }
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),

                        // line
                        Container(
                          margin: const EdgeInsets.only(right: 60, left: 60),
                          child: const Expanded(
                            child: Divider(
                              color: Color(0x208C00FF),
                            ),
                          ),
                        ),

                        // already learner button
                        Container(
                          child: MaterialButton(
                              onPressed: ()
                              {
                                // go to SignInScreen

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignInScreen())
                                );

                              },
                              child: const Text(
                                'Already a learner? Sign in',
                                style: TextStyle(
                                  color: Color(0xFF8C00FF),
                                ),
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, Object? state)
        async {
          if(state is SaveDataSuccessState)
          {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasSeenWelcome', true);

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }
        },
      )
    );
  }
}
