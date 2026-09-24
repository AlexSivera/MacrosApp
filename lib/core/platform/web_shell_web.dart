import 'dart:js_interop';
import 'dart:ui';

import 'package:web/web.dart' as web;

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

// Keeps the browser chrome (theme-color, iOS status bar area) and the page
// behind the canvas matching the active theme, and remembers the color so
// index.html can paint the next cold start's splash in it before Flutter
// has loaded.
void applyWebShellColor(Color background) {
  final hex = _hex(background);
  web.document.querySelector('meta[name="theme-color"]')?.setAttribute('content', hex);
  web.document.body?.style.backgroundColor = hex;
  try {
    web.window.localStorage.setItem('kalibra-bg', hex);
  } catch (_) {
    // Private mode / blocked storage: the splash just falls back to dark.
  }
}

// Asks the browser not to evict this origin's IndexedDB under storage
// pressure — the diary lives only there. Best effort: Safari may decline.
void requestPersistentStorage() {
  try {
    web.window.navigator.storage.persist().toDart.ignore();
  } catch (_) {}
}
