import 'package:injectable/injectable.dart';
import 'package:movna/domain/entities/app_metadata.dart';
import 'package:package_info_plus/package_info_plus.dart';

@module
abstract class MetadataModule {
  @preResolve
  Future<AppMetadata> get metadata async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final environment = packageName.endsWith('.dev')
        ? AppEnvironment.development
        : AppEnvironment.production;

    return AppMetadata(
      packageName: packageName,
      environment: environment,
      version: packageInfo.appName,
      buildNumber: int.tryParse(packageInfo.buildNumber) ?? 0,
    );
  }
}
