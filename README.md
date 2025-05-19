# Movnå

## Description

Movnå is an open-source training application.

## Contributing

### FVM

This project uses [fvm](https://fvm.app/), be sure to have it installed on your computer.
All calls to `flutter` and `dart` in the following shell snippets are actually calls
to `fvm flutter` and `fvm dart` respectively.
You will probably want to update your IDE's path to the flutter sdk accordingly.

- On Android Studio, go to `Languages & Frameworks > Flutter`, and set it to :

```txt
/absolute/path/to/this/project/.fvm/flutter_sdk
```

- On XCode, go to `Build phases`, and inside `Run script` add the following line :

```txt
export FLUTTER_ROOT="$PROJECT_DIR/../.fvm/flutter_sdk"
```

- On VSCode, add this to your `.vscode/settings.json` :

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  },
  "files.watcherExclude": {
    "**/.fvm": true
  }
}
```

### How to build

To install all dependencies, run :

```sh
flutter pub get
```

This project uses generated files, to generate these run :

```sh
dart run build_runner build
```

You are now all set to run with :

```sh
flutter run
```

Alternatively you can build the apk with :

```sh
flutter build apk
```
