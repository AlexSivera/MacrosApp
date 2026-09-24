import 'package:flutter/material.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/database/enums.dart';

// What the user picked from the add-entry menu. Only the choice is returned
// here — the caller (whose context outlives this transient sheet) drives the
// follow-up flow (search, quantity entry, etc). Awaiting a further sheet's
// result *inside* this sheet's own onTap would leave `context` pointing at
// an already-popped, unmounted widget by the time that result comes back.
//
// No "crear alimento personalizado" entry here — that shortcut duplicated
// the one already at the bottom of FoodSearchSheet (reached via "Añadir
// alimento" → buscar → sin resultados), which is where it belongs since you
// always land there right after confirming a search has nothing to offer.
enum AddEntryAction { food, recipe }

// The fast add-entry entry point tapped from a meal section's "+ Añadir",
// titled with the meal being filled.
class AddEntryOptionsSheet extends StatelessWidget {
  const AddEntryOptionsSheet({super.key, required this.mealType});

  final MealType mealType;

  static Future<AddEntryAction?> show(BuildContext context, {required MealType mealType}) {
    return showModalBottomSheet<AddEntryAction>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AddEntryOptionsSheet(mealType: mealType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Text('Añadir a ${mealType.label}', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_outlined),
              title: const Text('Añadir alimento'),
              onTap: () => Navigator.of(context).pop(AddEntryAction.food),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Añadir receta'),
              subtitle: const Text('Tus recetas y comidas guardadas'),
              onTap: () => Navigator.of(context).pop(AddEntryAction.recipe),
            ),
          ],
        ),
      ),
    );
  }
}
