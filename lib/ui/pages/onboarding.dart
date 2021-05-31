import 'package:chatapp/colors.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_cubit.dart';
import 'package:chatapp/states_mngmt/onboarding/onboarding_state.dart';
import 'package:chatapp/states_mngmt/onboarding/profile_image_cubit.dart';
import 'package:chatapp/ui/widgets/oboarding/logo.dart';
import 'package:chatapp/ui/widgets/oboarding/profile_upload.dart';
import 'package:chatapp/ui/widgets/shared/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  ProfileImageCubit profileImageCubit = ProfileImageCubit();
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _logo(context),
              Spacer(),
              ProfileUpload(profileImageCubit),
              Spacer(flex: 1),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: CustomTextField(
                  hint: 'wah yuh name?',
                  height: 45.0,
                  onChanged: (val) {
                    _username = val;
                  },
                  inputAction: TextInputAction.done,
                ),
              ),
              SizedBox(height: 30.0),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await context
                        .read<OnboardingCubit>()
                        .connect(_username, null);
                  },
                  child: Container(
                    height: 45.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Mek wi chat!',
                      style: Theme.of(context).textTheme.button.copyWith(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: kPrimary,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45.0))),
                ),
              ),
              Spacer(),
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) => state is Loading
                    ? Center(child: CircularProgressIndicator())
                    : Container(),
              ),
              Spacer(flex: 1)
            ],
          ),
        )));
  }

  Row _logo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Laba',
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontWeight: FontWeight.bold)),
        SizedBox(width: 8.0),
        Logo(),
        SizedBox(width: 8.0),
        Text('Laba',
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontWeight: FontWeight.bold))
      ],
    );
  }
}
