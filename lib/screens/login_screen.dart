import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false, _hide = true;

  Future<void> _login() async {
    if (!_key.currentState!.validate()) return;
    final s = context.read<AppState>();
    setState(() => _loading = true);
    try {
      await s.login(_email.text, _pass.text);
    } catch (e) {
      if (mounted) snack(context, s.authError(e));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _reset() async {
    final s = context.read<AppState>();
    if (_email.text.trim().isEmpty) {
      snack(context, 'Escribe tu correo y vuelve a tocar «¿Olvidaste tu contraseña?»');
      return;
    }
    try {
      await s.resetPassword(_email.text);
      if (mounted) snack(context, 'Te enviamos un correo para restablecer la contraseña.');
    } catch (e) {
      if (mounted) snack(context, s.authError(e));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _key,
                  child: Column(children: [
                    Image.asset('assets/images/logo.png', height: 210),
                    const Text('Inicia sesión',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: C.navy)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Correo no válido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hide = !_hide)),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: _reset, child: const Text('¿Olvidaste tu contraseña?'))),
                    FilledButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Entrar', style: TextStyle(fontSize: 17))),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('¿No tienes cuenta? Regístrate')),
                  ]),
                ),
              ),
            ),
            const CreditFooter(),
          ]),
        ),
      );
}
