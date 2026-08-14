import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_motion.dart';
import '../features/diario/screens/diario_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/perfil/screens/about_screen.dart';
import '../features/perfil/screens/appearance_screen.dart';
import '../features/perfil/screens/goal_screen.dart';
import '../features/perfil/screens/my_data_screen.dart';
import '../features/perfil/screens/notifications_screen.dart';
import '../features/perfil/screens/nutrition_goals_screen.dart';
import '../features/perfil/screens/perfil_screen.dart';
import '../features/perfil/screens/settings_screen.dart';
import '../features/perfil/screens/units_screen.dart';
import '../features/progreso/screens/progress_screen.dart';
import '../features/recetas/screens/recetas_screen.dart';
import '../features/recetas/screens/recipe_detail_screen.dart';
import '../features/recetas/screens/recipe_editor_screen.dart';

// Branch indices — used to keep the shell's nav-bar wiring and the route
// table in sync instead of hard-coding raw ints everywhere.
const _diarioBranch = 0;
const _recetasBranch = 1;
const _progresoBranch = 2;
const _perfilBranch = 3;

// Built once in main() with the initial location resolved from whether
// onboarding has been completed, so a first-time install lands on
// /onboarding instead of racing a redirect against the DB read.
GoRouter buildAppRouter({required String initialLocation}) => GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => _AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/diario', builder: (context, state) => const DiarioScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/recetas',
                builder: (context, state) => const RecetasScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const RecipeEditorScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        RecipeDetailScreen(recipeId: int.parse(state.pathParameters['id']!)),
                  ),
                  GoRoute(
                    path: ':id/editar',
                    builder: (context, state) => RecipeEditorScreen(
                      recipeId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/progreso', builder: (context, state) => const ProgressScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/perfil',
                builder: (context, state) => const PerfilScreen(),
                routes: [
                  GoRoute(path: 'objetivo', builder: (context, state) => const GoalScreen()),
                  GoRoute(path: 'mis-datos', builder: (context, state) => const MyDataScreen()),
                  GoRoute(
                    path: 'objetivos-nutricionales',
                    builder: (context, state) => const NutritionGoalsScreen(),
                  ),
                  GoRoute(path: 'unidades', builder: (context, state) => const UnitsScreen()),
                  GoRoute(
                    path: 'notificaciones',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(path: 'apariencia', builder: (context, state) => const AppearanceScreen()),
                  GoRoute(path: 'configuracion', builder: (context, state) => const SettingsScreen()),
                  GoRoute(path: 'sobre', builder: (context, state) => const AboutScreen()),
                ],
              ),
            ]),
          ],
        ),
      ],
    );

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelect: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _items = [
    _NavItem(_diarioBranch, Icons.book_outlined, Icons.book, 'Diario'),
    _NavItem(_recetasBranch, Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Recetas'),
    _NavItem(_progresoBranch, Icons.show_chart_outlined, Icons.show_chart, 'Progreso'),
    _NavItem(_perfilBranch, Icons.person_outline, Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelect,
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: Icon(item.icon, key: ValueKey(item.branchIndex)),
            ),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.branchIndex, this.icon, this.selectedIcon, this.label);

  final int branchIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
