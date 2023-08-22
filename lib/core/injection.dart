import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:movna/core/injection.config.dart';

final injector = GetIt.instance;

@InjectableInit()
Future configureDependencies() => injector.init();
