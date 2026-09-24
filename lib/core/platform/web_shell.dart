// Bridges the Flutter app to the HTML page it runs in on web (index.html's
// splash/background, the browser's theme-color, storage persistence). No-op
// on native — conditionally exported like legacy_recipe_image.dart.
export 'web_shell_stub.dart' if (dart.library.js_interop) 'web_shell_web.dart';
