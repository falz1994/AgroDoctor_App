// Conditional wrapper: export dart:io File on non-web, provide web placeholder otherwise
export 'file_io.dart' if (dart.library.html) 'file_web.dart';
