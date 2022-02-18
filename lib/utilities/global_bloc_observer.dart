import 'dart:developer';

import 'package:bloc/bloc.dart';

class GlobalBlocObserver extends BlocObserver {

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition.toString());
    super.onTransition(bloc, transition);
  }
}
