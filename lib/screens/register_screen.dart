import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  int _grade = 9;
  bool _accept = false, _loading = false, _hide = true;

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;
    if (!_accept) {
      snack(context, 'Debes aceptar el tratamiento de datos para continuar.');
      return;
    }
    final s = context.read<AppState>();
    setState(() => _loading = true);
    try {
      await s.register(_name.text, _email.text, _pass.text, _grade);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) {
        snack(context, s.authError(e));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _key,
                  child: Column(children: [
                    Image.asset('assets/images/logo.png', height: 130),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                          labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => (v == null || v.trim().length < 3) ? 'Escribe tu nombre' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Correo no válido' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _grade,
                      decoration: const InputDecoration(
                          labelText: 'Grado', prefixIcon: Icon(Icons.school_outlined)),
                      items: const [9, 10, 11]
                          .map((g) => DropdownMenuItem(value: g, child: Text('Grado $g°')))
                          .toList(),
                      onChanged: (v) => setState(() => _grade = v ?? 9),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        labelText: 'Contraseña (mín. 6 caracteres)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hide = !_hide)),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass2,
                      obscureText: _hide,
                      decoration: const InputDecoration(
                          labelText: 'Repite la contraseña', prefixIcon: Icon(Icons.lock_outline)),
                      validator: (v) => v != _pass.text ? 'Las contraseñas no coinciden' : null,
                    ),
                    CheckboxListTile(
                      value: _accept,
                      onChanged: (v) => setState(() => _accept = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                          'Autorizo el tratamiento de mis datos (nombre, correo, grado y progreso) con fines educativos. Si soy menor de edad, cuento con la autorización de mi acudiente.',
                          style: TextStyle(fontSize: 12.5)),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Registrarme', style: TextStyle(fontSize: 17))),
                  ]),
                ),
              ),
            ),
            const CreditFooter(),
          ]),
        ),
      );
}
