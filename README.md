# Movnå

## Description

Movnå is an open-source training application.

## Contributing

### How to build

This project uses [fvm](https://fvm.app/), be sure to have it installed on your computer.
On Android Studio you can then set the flutter sdk path for this project to `absolute/path/to/movna/.fvm/flutter_sdk/`.
All calls to `flutter` in the following shell snippets are actually calls to `fvm flutter`.

To install all dependencies, run :
```shell
flutter pub get
```

This projects uses generated files, to generate these run :
```shell
flutter pub run build_runner build
```