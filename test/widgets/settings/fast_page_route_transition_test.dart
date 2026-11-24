import 'package:arclauncher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastPageRoute transitions', () {
    testWidgets('outgoing and incoming routes never overlap in opacity during push', (tester) async {
      final animationController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 220),
      );

      // When pushing Page B on top of Page A:
      // Page B's entry is driven by animation: 0.0 -> 1.0.
      // Page A's exit is driven by secondaryAnimation: 0.0 -> 1.0.
      final progress = animationController;

      Widget buildOutgoing(Animation<double> secondary) {
        return FastPageRoute.buildPageTransitions(
          tester.element(find.byType(Container)),
          const AlwaysStoppedAnimation(1.0),
          secondary,
          const Text('Page A'),
        );
      }

      Widget buildIncoming(Animation<double> anim) {
        return FastPageRoute.buildPageTransitions(
          tester.element(find.byType(Container)),
          anim,
          kAlwaysDismissedAnimation,
          const Text('Page B'),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(),
                buildOutgoing(progress),
                buildIncoming(progress),
              ],
            ),
          ),
        ),
      );

      double getOutgoingOpacity() {
        // The outgoing route's secondary fade is the outer FadeTransition
        final fades = tester.widgetList<FadeTransition>(find.ancestor(
          of: find.text('Page A'),
          matching: find.byType(FadeTransition),
        )).toList();
        // fades[0] is secondaryFade, fades[1] is primaryFade (which is 1.0)
        return fades[0].opacity.value * fades[1].opacity.value;
      }

      double getIncomingOpacity() {
        final fades = tester.widgetList<FadeTransition>(find.ancestor(
          of: find.text('Page B'),
          matching: find.byType(FadeTransition),
        )).toList();
        return fades[0].opacity.value * fades[1].opacity.value;
      }

      // t = 0.0: Page A is fully visible, Page B is fully invisible
      animationController.value = 0.0;
      await tester.pump();
      expect(getOutgoingOpacity(), 1.0);
      expect(getIncomingOpacity(), 0.0);

      // t = 0.20: Page A is fading out, Page B is strictly 0.0
      animationController.value = 0.20;
      await tester.pump();
      expect(getOutgoingOpacity(), lessThan(1.0));
      expect(getOutgoingOpacity(), greaterThan(0.0));
      expect(getIncomingOpacity(), 0.0);

      // t = 0.42: Page A is completely faded out, Page B is still 0.0
      animationController.value = 0.42;
      await tester.pump();
      expect(getOutgoingOpacity(), 0.0);
      expect(getIncomingOpacity(), 0.0);

      // t = 0.70: Page A is strictly 0.0, Page B is fading in
      animationController.value = 0.70;
      await tester.pump();
      expect(getOutgoingOpacity(), 0.0);
      expect(getIncomingOpacity(), greaterThan(0.0));
      expect(getIncomingOpacity(), lessThan(1.0));

      // t = 1.0: Page A is 0.0, Page B is fully visible
      animationController.value = 1.0;
      await tester.pump();
      expect(getOutgoingOpacity(), 0.0);
      expect(getIncomingOpacity(), 1.0);

      animationController.dispose();
    });

    testWidgets('outgoing and incoming routes never overlap in opacity during pop', (tester) async {
      final animationController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 180),
      );

      // When popping Page B to return to Page A:
      // Page B's exit is driven by animation: 1.0 -> 0.0.
      // Page A's return is driven by secondaryAnimation: 1.0 -> 0.0.
      final progress = animationController;

      Widget buildParent(Animation<double> secondary) {
        return FastPageRoute.buildPageTransitions(
          tester.element(find.byType(Container)),
          const AlwaysStoppedAnimation(1.0),
          secondary,
          const Text('Page A'),
        );
      }

      Widget buildPopped(Animation<double> anim) {
        return FastPageRoute.buildPageTransitions(
          tester.element(find.byType(Container)),
          anim,
          kAlwaysDismissedAnimation,
          const Text('Page B'),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(),
                buildParent(progress),
                buildPopped(progress),
              ],
            ),
          ),
        ),
      );

      double getParentOpacity() {
        final fades = tester.widgetList<FadeTransition>(find.ancestor(
          of: find.text('Page A'),
          matching: find.byType(FadeTransition),
        )).toList();
        return fades[0].opacity.value * fades[1].opacity.value;
      }

      double getPoppedOpacity() {
        final fades = tester.widgetList<FadeTransition>(find.ancestor(
          of: find.text('Page B'),
          matching: find.byType(FadeTransition),
        )).toList();
        return fades[0].opacity.value * fades[1].opacity.value;
      }

      // t = 1.0: Page B is fully visible, Page A is invisible
      animationController.value = 1.0;
      await tester.pump();
      expect(getPoppedOpacity(), 1.0);
      expect(getParentOpacity(), 0.0);

      // t = 0.70: Page B is fading out, Page A is strictly 0.0
      animationController.value = 0.70;
      await tester.pump();
      expect(getPoppedOpacity(), lessThan(1.0));
      expect(getPoppedOpacity(), greaterThan(0.0));
      expect(getParentOpacity(), 0.0);

      // t = 0.42: Page B is completely faded out, Page A has not started fading in yet
      animationController.value = 0.42;
      await tester.pump();
      expect(getPoppedOpacity(), 0.0);
      expect(getParentOpacity(), 0.0);

      // t = 0.20: Page B is strictly 0.0, Page A is fading in
      animationController.value = 0.20;
      await tester.pump();
      expect(getPoppedOpacity(), 0.0);
      expect(getParentOpacity(), greaterThan(0.0));
      expect(getParentOpacity(), lessThan(1.0));

      // t = 0.0: Page B is 0.0, Page A is fully visible
      animationController.value = 0.0;
      await tester.pump();
      expect(getPoppedOpacity(), 0.0);
      expect(getParentOpacity(), 1.0);

      animationController.dispose();
    });

    testWidgets('navigator push and pop transitions with FastPageRoute execute cleanly', (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Navigator(
              key: navKey,
              onGenerateRoute: (settings) {
                if (settings.name == '/sub') {
                  return FastPageRoute(builder: (_) => const Text('Submenu Content'));
                }
                return FastPageRoute(builder: (_) => const Text('Main Menu Content'));
              },
            ),
          ),
        ),
      );

      expect(find.text('Main Menu Content'), findsOneWidget);
      expect(find.text('Submenu Content'), findsNothing);

      // Push submenu
      navKey.currentState!.pushNamed('/sub');
      await tester.pump(); // animation starts (t = 0)

      // Halfway through push (around 110ms out of 220ms)
      await tester.pump(const Duration(milliseconds: 110));
      // Neither text should be colliding at high opacity
      // Complete the push transition
      await tester.pumpAndSettle();
      expect(find.text('Submenu Content'), findsOneWidget);

      // Pop back to main menu
      navKey.currentState!.pop();
      await tester.pump(); // reverse starts

      // Halfway through pop (around 90ms out of 180ms)
      await tester.pump(const Duration(milliseconds: 90));

      // Complete the pop transition
      await tester.pumpAndSettle();
      expect(find.text('Main Menu Content'), findsOneWidget);
      expect(find.text('Submenu Content'), findsNothing);
    });
  });
}
