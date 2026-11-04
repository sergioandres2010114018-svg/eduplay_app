import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _block(String t, String body) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.navy)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.4)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const values = {
      'Innovación': 'Buscamos nuevas formas de enseñar y aprender usando la tecnología y el juego.',
      'Compromiso con la educación': 'Trabajamos para que cada estudiante mejore su aprendizaje y sus resultados.',
      'Calidad': 'Ofrecemos contenidos claros, correctos y validados por docentes.',
      'Inclusión': 'Una aplicación sencilla, gratuita y accesible para todos los estudiantes.',
      'Responsabilidad': 'Protegemos los datos de los usuarios y cumplimos lo que prometemos.',
      'Creatividad': 'Convertimos los temas académicos en retos atractivos y motivadores.',
      'Trabajo en equipo': 'Sumamos los aportes de aprendices, instructor, docentes y estudiantes.',
      'Honestidad': 'Promovemos el esfuerzo propio y la transparencia en los resultados.',
      'Respeto': 'Valoramos la diversidad, los ritmos de aprendizaje y las opiniones de cada usuario.',
      'Aprendizaje continuo': 'Mejoramos la aplicación a partir de la experiencia y la retroalimentación.',
    };
    const team = [
      'Ana Lia Tovar Gutiérrez',
      'Esleidris Catalina Luque Ortiz',
      'Oriana Paba Ortiz',
      'Luisa Fernanda Oliveros López',
      'Yeiner Andrés Martínez Alvarado',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de EduPlay')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: Image.asset('assets/images/logo.png', height: 200)),
        const Center(
            child: Text('Versión 1.0.0 · Producto Mínimo Viable',
                style: TextStyle(fontSize: 12))),
        const SizedBox(height: 10),
        _block('¿Qué es EduPlay?',
            'Aplicación móvil educativa para estudiantes de los grados 9°, 10° y 11° que integra contenidos por áreas, retos interactivos, cuestionarios, simulacros tipo ICFES, niveles, logros y recompensas. Metodología: aprendizaje por retos (Challenge-Based Learning) y gamificación.'),
        _block('Misión',
            'Brindar una plataforma educativa innovadora que combine contenidos académicos de calidad con herramientas de gamificación, permitiendo a los estudiantes aprender de manera dinámica, fortalecer sus competencias y prepararse para los desafíos académicos del presente y del futuro.'),
        _block('Visión',
            'Para el año 2030, ser una aplicación educativa líder en Colombia para estudiantes de educación media, reconocida por transformar el aprendizaje mediante experiencias interactivas, contenidos actualizados y desafíos académicos que promuevan el desarrollo integral de los estudiantes.'),
        const SectionTitle('Valores corporativos'),
        ...values.entries.map((e) => _block(e.key, e.value)),
        const SectionTitle('Organigrama'),
        ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/images/organigrama.png')),
        const SectionTitle('Equipo de aprendices'),
        Card(
            child: Column(
                children: team
                    .map((n) => ListTile(dense: true, leading: const Icon(Icons.person, color: C.blue), title: Text(n)))
                    .toList())),
        _block('Instituciones',
            'Institución Educativa Técnica Departamental Pijiño del Carmen (Magdalena)\nCentro Acuícola y Agroindustrial de Gaira – SENA\nPrograma: Técnico en Programación de Aplicaciones para Dispositivos Móviles · Proyecto SenaTic\nInstructor: Sergio Andrés Caro Arrieta'),
        const SizedBox(height: 10),
        const Divider(),
        Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(creditText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: C.navy)),
        )),
      ]),
    );
  }
}
