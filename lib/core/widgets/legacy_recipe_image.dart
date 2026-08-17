// Recipes saved before web support stored their photo as a file path into
// the native app's own document storage (Recipes.imagePath) — a concept
// that doesn't exist on web. New photos on every platform go into
// Recipes.imageBytes instead (works identically everywhere, no filesystem
// needed), but old rows still carrying only imagePath need to keep
// rendering on native. Conditionally implemented per platform: a real
// Image.file lookup on native, a no-op on web.
//
// Returns null when there's no file at that path (or on web, always) so
// callers can fall back to a placeholder.
export 'legacy_recipe_image_stub.dart' if (dart.library.io) 'legacy_recipe_image_io.dart';
