import 'package:get_it/get_it.dart';

import 'firebaseUtility.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseUtility());
}
