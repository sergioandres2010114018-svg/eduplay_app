import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});
  final Widget next;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.next,
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child)));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                  child: FadeTransition(
                      opacity: _c,
                      child: Image.asset('assets/images/logo.png', width: 280)),
                ),
              ),
            ),
            const CircularProgressIndicator(color: C.green),
            const CreditFooter(),
          ]),
        ),
      );
}
