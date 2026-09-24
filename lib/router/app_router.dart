import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_motion.dart';
import '../features/diario/screens/diario_screen.dart';
import '../features/listas/screens/custom_list_detail_screen.dart';
import '../features/listas/screens/listas_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/perfil/screens/about_screen.dart';
import '../features/perfil/screens/appearance_screen.dart';
import '../features/perfil/screens/goal_screen.dart';
import '../features/perfil/screens/my_data_screen.dart';
import '../features/perfil/screens/nutrition_goals_screen.dart';
import '../features/perfil/screens/perfil_screen.dart';
import '../features/perfil/screens/settings_screen.dart';
import '../features/plan_semanal/providers/meal_plan_providers.dart';
import '../features/plan_semanal/screens/plan_day_screen.dart';
import '../features/plan_semanal/screens/plan_semanal_screen.dart';
import '../features/plan_semanal/screens/shopping_list_screen.dart';
import '../features/progreso/screens/progress_screen.dart';
import '../features/recetas/screens/recetas_screen.dart';
import '../features/recetas/screens/recipe_detail_screen.dart';
import '../features/recetas/screens/recipe_editor_screen.dart';

// Branch indices — used to keep the shell's nav-bar wiring and the route
// table in sync instead of hard-coding raw ints everywhere.
const _diarioBranch = 0;
const _recetasBranch = 1;
const _planBranch = 2;
const _listasBranch = 3;
const _perfilBranch = 4;

// Built once in main() with the initial location resolved from whether
// onboarding has been completed, so a first-time install lands on
// /onboarding instead of racing a redirect against the DB read.
GoRouter buildAppRouter({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    StatefulShellRoute(
      builder: (context, state, navigationShell) => _AppShell(navigationShell: navigationShell),
      // Same keep-every-tab-alive IndexedStack as .indexedStack, plus a
      // short cross-fade so switching tabs isn't a hard cut.
      navigatorContainerBuilder: (context, navigationShell, children) =>
          _FadeIndexedStack(index: navigationShell.currentIndex, children: children),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/diario', builder: (context, state) => const DiarioScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recetas',
              builder: (context, state) => const RecetasScreen(),
              routes: [
                GoRoute(path: 'nuevo', builder: (context, state) => const RecipeEditorScreen()),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      RecipeDetailScreen(recipeId: int.parse(state.pathParameters['id']!)),
                ),
                GoRoute(
                  path: ':id/editar',
                  builder: (context, state) =>
                      RecipeEditorScreen(recipeId: int.parse(state.pathParameters['id']!)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plan',
              builder: (context, state) => const PlanSemanalScreen(),
              routes: [
                GoRoute(
                  path: 'dia/:fecha',
                  builder: (context, state) =>
                      PlanDayScreen(date: parsePlanDayPathSegment(state.pathParameters['fecha']!)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/listas',
              builder: (context, state) => const ListasScreen(),
              routes: [
                GoRoute(path: 'compra', builder: (context, state) => const ShoppingListScreen()),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      CustomListDetailScreen(listId: int.parse(state.pathParameters['id']!)),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
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
                GoRoute(path: 'progreso', builder: (context, state) => const ProgressScreen()),
                GoRoute(path: 'apariencia', builder: (context, state) => const AppearanceScreen()),
                GoRoute(path: 'configuracion', builder: (context, state) => const SettingsScreen()),
                GoRoute(path: 'sobre', builder: (context, state) => const AboutScreen()),
              ],
            ),
          ],
        ),
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
    _NavItem(_planBranch, Icons.calendar_month_outlined, Icons.calendar_month, 'Plan'),
    _NavItem(_listasBranch, Icons.checklist_outlined, Icons.checklist, 'Listas'),
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
            icon: Icon(item.icon),
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

class _FadeIndexedStack extends StatefulWidget {
  const _FadeIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.fast,
    value: 1,
  );

  @override
  void didUpdateWidget(_FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _controller.duration = AppMotion.of(context, AppMotion.fast);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: AppMotion.curve),
      child: IndexedStack(
        index: widget.index,
        children: [
          // Hidden tabs stay mounted but paused, exactly like go_router's own
          // indexedStack container (no shimmer/ticker running off-screen).
          for (var i = 0; i < widget.children.length; i++)
            Offstage(
              offstage: i != widget.index,
              child: TickerMode(enabled: i == widget.index, child: widget.children[i]),
            ),
        ],
      ),
    );
  }
}
