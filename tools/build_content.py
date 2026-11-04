# -*- coding: utf-8 -*-
"""Genera assets/data/content.json (banco de contenidos) y los videos de cada lección.
Uso (opcional, el repositorio ya trae los archivos generados):
    python3 tools/build_content.py
Requiere: Pillow y ffmpeg."""
import json, random, os, subprocess, textwrap, shutil, tempfile
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rnd = random.Random(2026)

def Q(q, ok, wrong, e):
    opts = [ok] + wrong
    rnd.shuffle(opts)
    return {"q": q, "o": opts, "a": opts.index(ok), "e": e}

AREAS = [
 {"id":"mat","name":"Matemáticas","icon":"calculate","color":"#1E88E5","image":"assets/images/area_mat.jpg","lessons":[
  {"id":"mat9a","grade":9,"title":"Ecuaciones cuadráticas",
   "summary":"Una ecuación cuadrática tiene la forma ax² + bx + c = 0 (a ≠ 0). Se resuelve por factorización o con la fórmula general. El discriminante indica cuántas soluciones reales existen.",
   "points":["Forma general: ax² + bx + c = 0","Fórmula general: x = (−b ± √(b² − 4ac)) / 2a","Discriminante b² − 4ac: positivo → 2 soluciones reales; cero → 1; negativo → ninguna real"],
   "example":"x² − 5x + 6 = 0 → (x − 2)(x − 3) = 0 → x = 2 o x = 3.","yt":"ecuaciones cuadráticas factorización fórmula general",
   "questions":[
    Q("¿Cuáles son las soluciones de x² − 5x + 6 = 0?","x = 2 y x = 3",["x = −2 y x = −3","x = 1 y x = 6","x = 5 y x = 1"],"Se factoriza como (x − 2)(x − 3) = 0, entonces x = 2 o x = 3."),
    Q("¿Cuánto vale el discriminante de x² + 4x + 4 = 0?","0",["8","16","−8"],"b² − 4ac = 16 − 16 = 0, por eso hay una única solución real (x = −2)."),
    Q("Si el discriminante de una ecuación cuadrática es negativo, entonces…","no tiene soluciones reales",["tiene dos soluciones reales","tiene una solución real","siempre tiene solución x = 0"],"Con discriminante negativo la raíz cuadrada no es un número real.")]},
  {"id":"mat9b","grade":9,"title":"Teorema de Pitágoras",
   "summary":"En un triángulo rectángulo, el cuadrado de la hipotenusa es igual a la suma de los cuadrados de los catetos. La hipotenusa es el lado opuesto al ángulo recto y el más largo.",
   "points":["c² = a² + b²","La hipotenusa es el lado más largo","Sirve para calcular distancias, alturas y diagonales"],
   "example":"Catetos 3 y 4 → c² = 9 + 16 = 25 → c = 5.","yt":"teorema de pitágoras ejercicios",
   "questions":[
    Q("Un triángulo rectángulo tiene catetos de 6 y 8. ¿Cuánto mide la hipotenusa?","10",["14","12","100"],"6² + 8² = 36 + 64 = 100, y √100 = 10."),
    Q("Una escalera de 5 m se apoya en una pared y su base está a 3 m de ella. ¿Qué altura alcanza?","4 m",["2 m","8 m","34 m"],"h² = 5² − 3² = 25 − 9 = 16, entonces h = 4 m."),
    Q("¿Cuál de estas ternas forma un triángulo rectángulo?","5, 12, 13",["4, 5, 6","2, 3, 4","6, 7, 8"],"5² + 12² = 25 + 144 = 169 = 13².")]},
  {"id":"mat10a","grade":10,"title":"Funciones lineales",
   "summary":"Una función lineal se escribe y = mx + b. El valor m es la pendiente (inclinación de la recta) y b es el punto donde la recta corta el eje y.",
   "points":["Pendiente entre dos puntos: m = (y₂ − y₁) / (x₂ − x₁)","b es el intercepto con el eje y","m > 0 la recta sube; m < 0 la recta baja"],
   "example":"Puntos (1, 3) y (3, 7): m = (7 − 3)/(3 − 1) = 2, y la recta es y = 2x + 1.","yt":"función lineal pendiente intercepto",
   "questions":[
    Q("¿Cuál es la pendiente de la recta que pasa por (0, 1) y (2, 5)?","2",["4","1/2","−2"],"m = (5 − 1)/(2 − 0) = 4/2 = 2."),
    Q("En y = −3x + 5, ¿dónde corta la recta al eje y?","en y = 5",["en y = −3","en y = 3","en el origen"],"El término independiente b = 5 es el intercepto con el eje y."),
    Q("Una recta con pendiente negativa…","baja de izquierda a derecha",["sube de izquierda a derecha","es horizontal","es vertical"],"Si m < 0, al aumentar x el valor de y disminuye.")]},
  {"id":"mat10b","grade":10,"title":"Razones trigonométricas",
   "summary":"En un triángulo rectángulo, las razones relacionan un ángulo con los lados: seno, coseno y tangente. Los ángulos de 30°, 45° y 60° aparecen con mucha frecuencia.",
   "points":["sen θ = cateto opuesto / hipotenusa","cos θ = cateto adyacente / hipotenusa","tan θ = cateto opuesto / cateto adyacente"],
   "example":"Si el cateto opuesto mide 3 y la hipotenusa 5, entonces sen θ = 3/5 = 0,6.","yt":"razones trigonométricas seno coseno tangente",
   "questions":[
    Q("El coseno de un ángulo agudo se define como…","cateto adyacente / hipotenusa",["cateto opuesto / hipotenusa","cateto opuesto / cateto adyacente","hipotenusa / cateto adyacente"],"cos θ = adyacente / hipotenusa."),
    Q("Un triángulo rectángulo tiene catetos iguales a 4 y 4. ¿Cuánto vale tan θ?","1",["0","4","16"],"tan θ = 4/4 = 1 (ángulo de 45°)."),
    Q("¿Cuánto vale sen 30°?","1/2",["√3/2","1","√2/2"],"Es un valor notable: sen 30° = 1/2.")]},
  {"id":"mat11a","grade":11,"title":"Estadística y probabilidad",
   "summary":"La media es el promedio de los datos, la mediana es el valor central cuando se ordenan y la moda es el dato que más se repite. La probabilidad mide qué tan posible es un evento.",
   "points":["Media = suma de datos / cantidad de datos","Probabilidad = casos favorables / casos posibles","La probabilidad siempre está entre 0 y 1"],
   "example":"Datos 2, 3, 3, 5, 7 → media 4, mediana 3 y moda 3.","yt":"media mediana moda probabilidad básica",
   "questions":[
    Q("¿Cuál es la media de 4, 6, 8 y 10?","7",["6","8","28"],"(4 + 6 + 8 + 10) / 4 = 28 / 4 = 7."),
    Q("Al lanzar un dado, ¿cuál es la probabilidad de obtener un número par?","1/2",["1/6","1/3","2/3"],"Hay 3 pares (2, 4, 6) entre 6 resultados posibles: 3/6 = 1/2."),
    Q("¿Cuál es la mediana de 9, 2, 7, 4 y 5?","5",["4","7","9"],"Ordenados: 2, 4, 5, 7, 9. El valor central es 5.")]},
  {"id":"mat11b","grade":11,"title":"Exponenciales y logaritmos",
   "summary":"La función exponencial y = aˣ crece o decrece muy rápido. El logaritmo es su operación inversa: log_a(x) = y significa que aʸ = x.",
   "points":["log₂(8) = 3 porque 2³ = 8","log(x·y) = log x + log y","log(xⁿ) = n · log x"],
   "example":"log₁₀(100) = 2 porque 10² = 100.","yt":"logaritmos propiedades exponenciales",
   "questions":[
    Q("¿Cuánto vale log₁₀(1000)?","3",["2","10","100"],"10³ = 1000, entonces el logaritmo es 3."),
    Q("Una población de 100 bacterias se duplica cada hora. ¿Cuántas habrá a las 3 horas?","800",["300","600","1000"],"100 · 2³ = 100 · 8 = 800."),
    Q("log(a · b) es igual a…","log a + log b",["log a · log b","log a − log b","(log a) / (log b)"],"El logaritmo de un producto es la suma de los logaritmos.")]}]},
 {"id":"fis","name":"Física","icon":"bolt","color":"#43A047","image":"assets/images/area_fis.jpg","lessons":[
  {"id":"fis9a","grade":9,"title":"Movimiento rectilíneo uniforme",
   "summary":"En el MRU el cuerpo se mueve en línea recta con velocidad constante, es decir, sin aceleración. La distancia recorrida es proporcional al tiempo.",
   "points":["v = d / t","d = v · t","La aceleración es igual a cero"],
   "example":"Un ciclista a 5 m/s durante 20 s recorre 100 m.","yt":"movimiento rectilíneo uniforme MRU",
   "questions":[
    Q("Una moto va a 20 m/s durante 10 s. ¿Qué distancia recorre?","200 m",["30 m","2 m","20 m"],"d = v · t = 20 · 10 = 200 m."),
    Q("En un movimiento rectilíneo uniforme, la aceleración es…","cero",["constante y distinta de cero","creciente","negativa"],"La velocidad no cambia, por lo tanto a = 0."),
    Q("Un carro recorre 150 km en 3 h con velocidad constante. ¿Cuál es su velocidad?","50 km/h",["450 km/h","153 km/h","30 km/h"],"v = d / t = 150 / 3 = 50 km/h.")]},
  {"id":"fis9b","grade":9,"title":"Leyes de Newton",
   "summary":"Newton explicó cómo las fuerzas cambian el movimiento. La primera ley habla de la inercia, la segunda relaciona fuerza, masa y aceleración, y la tercera describe pares de acción y reacción.",
   "points":["1ª ley: sin fuerza neta, el movimiento no cambia (inercia)","2ª ley: F = m · a","3ª ley: a toda acción corresponde una reacción igual y opuesta"],
   "example":"Una fuerza de 10 N sobre una masa de 2 kg produce una aceleración de 5 m/s².","yt":"leyes de newton explicación",
   "questions":[
    Q("¿Qué aceleración produce una fuerza de 20 N sobre una masa de 4 kg?","5 m/s²",["80 m/s²","16 m/s²","0,2 m/s²"],"a = F / m = 20 / 4 = 5 m/s²."),
    Q("Cuando un bus frena de golpe, los pasajeros se inclinan hacia adelante. Esto se explica por…","la ley de la inercia",["la ley de acción y reacción","la gravitación universal","la ley de Ohm"],"Los cuerpos tienden a conservar su movimiento (primera ley)."),
    Q("Al empujar una pared, sientes que ella te empuja. Esto es…","la tercera ley de Newton",["la primera ley de Newton","la segunda ley de Newton","la ley de Hooke"],"Acción y reacción: fuerzas iguales y opuestas sobre cuerpos distintos.")]},
  {"id":"fis10a","grade":10,"title":"Caída libre",
   "summary":"En caída libre, sin resistencia del aire, todos los cuerpos aceleran hacia la Tierra con la misma aceleración g ≈ 9,8 m/s² (se usa 10 m/s² para cálculos rápidos).",
   "points":["v = v₀ + g · t","h = ½ · g · t²","La masa no cambia el tiempo de caída en el vacío"],
   "example":"Una piedra soltada cae 2 s: v = 9,8 · 2 = 19,6 m/s y h = ½ · 9,8 · 4 = 19,6 m.","yt":"caída libre física ejercicios",
   "questions":[
    Q("Un objeto se suelta desde el reposo. Con g = 10 m/s², ¿qué velocidad tiene a los 3 s?","30 m/s",["10 m/s","13 m/s","90 m/s"],"v = g · t = 10 · 3 = 30 m/s."),
    Q("Sin resistencia del aire, una pluma y una piedra soltadas a la vez…","caen con la misma aceleración",["la piedra cae más rápido","la pluma cae más rápido","no caen"],"La aceleración de la gravedad no depende de la masa."),
    Q("¿Qué altura recorre un objeto en 2 s de caída libre (g = 10 m/s²)?","20 m",["10 m","40 m","5 m"],"h = ½ · 10 · 2² = 20 m.")]},
  {"id":"fis10b","grade":10,"title":"Trabajo y energía",
   "summary":"El trabajo es la fuerza aplicada en la dirección del movimiento multiplicada por la distancia. La energía se transforma, pero no se crea ni se destruye.",
   "points":["W = F · d (se mide en julios, J)","Energía cinética: Ec = ½ · m · v²","Energía potencial: Ep = m · g · h"],
   "example":"Una caja de 2 kg a 3 m de altura (g = 10) tiene Ep = 2 · 10 · 3 = 60 J.","yt":"trabajo energía cinética potencial",
   "questions":[
    Q("¿Qué trabajo realiza una fuerza de 50 N que mueve un objeto 4 m en su misma dirección?","200 J",["54 J","12,5 J","46 J"],"W = F · d = 50 · 4 = 200 J."),
    Q("¿Cuál es la energía cinética de un cuerpo de 2 kg que se mueve a 3 m/s?","9 J",["6 J","18 J","3 J"],"Ec = ½ · 2 · 3² = 9 J."),
    Q("En una montaña rusa, cuando el carrito baja, la energía potencial se transforma en…","energía cinética",["energía nuclear","masa","fuerza"],"Al bajar pierde altura (Ep) y gana velocidad (Ec).")]},
  {"id":"fis11a","grade":11,"title":"Ley de Ohm y circuitos",
   "summary":"La ley de Ohm relaciona voltaje, corriente y resistencia. En un circuito en serie las resistencias se suman y la corriente es la misma en todo el circuito.",
   "points":["V = I · R","En serie: R total = R₁ + R₂","Potencia eléctrica: P = V · I"],
   "example":"Una batería de 12 V conectada a 4 Ω produce I = 12 / 4 = 3 A.","yt":"ley de ohm circuitos serie paralelo",
   "questions":[
    Q("¿Qué corriente circula por una resistencia de 3 Ω conectada a 9 V?","3 A",["27 A","12 A","6 A"],"I = V / R = 9 / 3 = 3 A."),
    Q("Dos resistencias de 5 Ω y 10 Ω en serie equivalen a…","15 Ω",["50 Ω","3,3 Ω","5 Ω"],"En serie se suman: 5 + 10 = 15 Ω."),
    Q("¿Qué potencia consume un aparato de 10 V por el que circulan 2 A?","20 W",["5 W","12 W","8 W"],"P = V · I = 10 · 2 = 20 W.")]},
  {"id":"fis11b","grade":11,"title":"Ondas y sonido",
   "summary":"Una onda transporta energía sin transportar materia. El sonido es una onda mecánica longitudinal: necesita un medio (aire, agua, sólidos) y no se propaga en el vacío.",
   "points":["v = λ · f","La frecuencia se mide en hercios (Hz)","El sonido en el aire viaja a unos 340 m/s"],
   "example":"Con f = 170 Hz y v = 340 m/s, la longitud de onda es λ = 340 / 170 = 2 m.","yt":"ondas sonido frecuencia longitud de onda",
   "questions":[
    Q("¿En cuál de estos lugares NO se propaga el sonido?","en el vacío",["en el aire","en el agua","en una pared de concreto"],"El sonido necesita un medio material para propagarse."),
    Q("Una onda de 50 Hz tiene longitud de onda de 4 m. ¿Cuál es su velocidad?","200 m/s",["12,5 m/s","54 m/s","46 m/s"],"v = λ · f = 4 · 50 = 200 m/s."),
    Q("La frecuencia de una onda se mide en…","hercios (Hz)",["julios (J)","newtons (N)","vatios (W)"],"1 Hz equivale a un ciclo por segundo.")]}]},
 {"id":"esp","name":"Español y Lectura Crítica","icon":"menu_book","color":"#FB8C00","image":"assets/images/area_esp.jpg","lessons":[
  {"id":"esp9a","grade":9,"title":"Tipos de texto",
   "summary":"El texto narrativo cuenta hechos con personajes, tiempo y espacio. El expositivo informa o explica. El argumentativo defiende una tesis con razones. El instructivo indica pasos para hacer algo.",
   "points":["Narrativo: cuenta una historia","Expositivo: explica o informa","Argumentativo: defiende una idea · Instructivo: da pasos"],
   "example":"«Para preparar arroz, primero lave el grano…» es un texto instructivo.","yt":"tipos de texto narrativo expositivo argumentativo",
   "questions":[
    Q("Un texto que defiende una opinión con razones es…","argumentativo",["narrativo","instructivo","descriptivo"],"El texto argumentativo busca convencer con argumentos."),
    Q("«Había una vez un niño que vivía junto al río…» es el inicio de un texto…","narrativo",["expositivo","instructivo","argumentativo"],"Presenta personajes, tiempo y espacio propios de una narración."),
    Q("Una receta de cocina es un texto…","instructivo",["narrativo","argumentativo","lírico"],"Da pasos ordenados para lograr un resultado.")]},
  {"id":"esp9b","grade":9,"title":"Figuras literarias",
   "summary":"Las figuras literarias embellecen el lenguaje. La metáfora identifica dos elementos sin «como»; el símil los compara con «como» o «cual»; la hipérbole exagera; la personificación da cualidades humanas a cosas o animales.",
   "points":["Metáfora: «tus ojos son luceros»","Símil: «fuerte como un roble»","Hipérbole: exageración · Personificación: cualidades humanas"],
   "example":"«El viento susurraba entre los árboles» es una personificación.","yt":"figuras literarias metáfora símil hipérbole",
   "questions":[
    Q("«Es fuerte como un roble» es un ejemplo de…","símil",["metáfora","hipérbole","personificación"],"Compara usando la palabra «como»."),
    Q("«Te lo he dicho un millón de veces» es una…","hipérbole",["metáfora","personificación","antítesis"],"Exagera para dar énfasis."),
    Q("«Tus ojos son dos luceros» es una…","metáfora",["símil","hipérbole","onomatopeya"],"Identifica los ojos con luceros sin usar «como».")]},
  {"id":"esp10a","grade":10,"title":"Idea principal y propósito",
   "summary":"La idea principal es la información más importante del texto; las ideas secundarias la apoyan. El propósito comunicativo puede ser informar, persuadir, entretener o instruir.",
   "points":["Idea principal: resume el mensaje central","Propósito: informar, persuadir, entretener o instruir","Pregúntate: ¿qué quiere lograr el autor?"],
   "example":"Un aviso que dice «Vote este domingo, su voto cuenta» tiene propósito persuasivo.","yt":"idea principal propósito comunicativo lectura crítica",
   "questions":[
    Q("La idea principal de un texto es…","la que resume su mensaje central",["el primer párrafo siempre","un ejemplo cualquiera","el título únicamente"],"Las demás ideas giran alrededor de ella."),
    Q("Un aviso que dice «Vote este domingo, su voto cuenta» busca principalmente…","persuadir",["narrar","describir","instruir"],"Intenta convencer al lector de actuar."),
    Q("Una noticia que reporta un hecho tiene como propósito…","informar",["persuadir","entretener","burlarse"],"La noticia comunica hechos de actualidad.")]},
  {"id":"esp10b","grade":10,"title":"Conectores y cohesión",
   "summary":"Los conectores unen ideas y dan coherencia al texto: adición (además), oposición (sin embargo, pero), causa (porque, ya que), consecuencia (por lo tanto, así que) y ejemplo (por ejemplo).",
   "points":["Adición: además, también","Oposición: pero, sin embargo","Causa: porque · Consecuencia: por lo tanto"],
   "example":"«Estudié mucho; por lo tanto, aprobé el examen» usa un conector de consecuencia.","yt":"conectores textuales cohesión coherencia",
   "questions":[
    Q("«Quería salir, ____ estaba lloviendo.» ¿Qué conector completa mejor la frase?","sin embargo",["además","por ejemplo","es decir"],"Expresa oposición entre querer salir y la lluvia."),
    Q("«Por lo tanto» es un conector de…","consecuencia",["causa","oposición","ejemplo"],"Introduce el resultado de lo dicho antes."),
    Q("«Llegué tarde ____ se dañó el bus.» ¿Qué conector expresa causa?","porque",["aunque","pero","sin embargo"],"«Porque» introduce la razón del hecho.")]},
  {"id":"esp11a","grade":11,"title":"El texto argumentativo",
   "summary":"Un texto argumentativo tiene tesis (la postura del autor), argumentos (razones, datos, ejemplos, citas de autoridad) y conclusión. Evaluar su calidad implica revisar si los argumentos realmente apoyan la tesis.",
   "points":["Tesis: la postura que se defiende","Argumentos: de datos, de autoridad, de ejemplo","Conclusión: cierra y refuerza la tesis"],
   "example":"Tesis: «Los colegios deben dar más tiempo a la lectura». Argumento: «Leer mejora la comprensión de textos».","yt":"texto argumentativo tesis argumentos",
   "questions":[
    Q("La tesis de un texto argumentativo es…","la postura que defiende el autor",["un dato estadístico","el final de la historia","una definición del diccionario"],"Es la idea central que se quiere demostrar."),
    Q("«Según expertos en salud, dormir 8 horas mejora el rendimiento» es un argumento…","de autoridad",["de ejemplo","emocional","de contradicción"],"Se apoya en la opinión de especialistas."),
    Q("Usar cifras de una encuesta para apoyar una idea es un argumento…","de datos (estadístico)",["de autoridad","de analogía","de ironía"],"Se apoya en información numérica verificable.")]},
  {"id":"esp11b","grade":11,"title":"Falacias y lectura crítica",
   "summary":"Una falacia es un razonamiento que parece válido pero no lo es. Leer críticamente es cuestionar la fuente, la intención del autor y la evidencia que presenta.",
   "points":["Ad hominem: atacar a la persona y no a su argumento","Generalización apresurada: concluir con muy pocos casos","Lectura crítica: evaluar fuente, intención y evidencia"],
   "example":"«No creas su propuesta porque es muy joven» es una falacia ad hominem.","yt":"falacias lógicas lectura crítica ICFES",
   "questions":[
    Q("«Dos estudiantes de ese colegio copiaron, así que todos son tramposos». Esto es una…","generalización apresurada",["falacia ad hominem","metáfora","tesis"],"Se concluye sobre todos con solo dos casos."),
    Q("Leer críticamente implica…","evaluar la fuente, la intención y las evidencias",["memorizar el texto","aceptar todo lo que dice el autor","leer solo el título"],"Se analiza y cuestiona lo que se lee."),
    Q("Una falacia ad hominem consiste en…","atacar a la persona y no a su argumento",["usar datos confiables","citar a un experto","resumir el texto"],"Se desvía la discusión hacia quien habla.")]}]},
 {"id":"soc","name":"Ciencias Sociales","icon":"public","color":"#8E24AA","image":"assets/images/area_soc.jpg","lessons":[
  {"id":"soc9a","grade":9,"title":"Constitución de 1991",
   "summary":"La Constitución Política de 1991 definió a Colombia como Estado social de derecho, democrático y participativo. Creó la acción de tutela y varios mecanismos de participación ciudadana.",
   "points":["Acción de tutela: protege derechos fundamentales","Mecanismos: voto, plebiscito, referendo, consulta popular, cabildo abierto, revocatoria","Colombia: Estado social de derecho"],
   "example":"Si un servicio urgente de salud es negado, se puede presentar una acción de tutela.","yt":"constitución 1991 mecanismos de participación ciudadana",
   "questions":[
    Q("¿Qué mecanismo permite proteger de forma rápida un derecho fundamental?","la acción de tutela",["el cabildo abierto","el plebiscito","el decreto"],"La tutela se resuelve en pocos días."),
    Q("¿En qué año se expidió la actual Constitución Política de Colombia?","1991",["1886","1950","2001"],"La Asamblea Nacional Constituyente la expidió en 1991."),
    Q("La revocatoria del mandato permite a los ciudadanos…","terminar el mandato de un alcalde o gobernador elegido",["elegir al presidente","aprobar el presupuesto","crear impuestos"],"Es un mecanismo de control político de los votantes.")]},
  {"id":"soc9b","grade":9,"title":"La Revolución Industrial",
   "summary":"Comenzó en Gran Bretaña a mediados del siglo XVIII. Las máquinas y las fábricas reemplazaron gran parte del trabajo artesanal. Trajo urbanización, una nueva clase obrera y también explotación laboral.",
   "points":["Origen: Gran Bretaña, siglo XVIII","Invento clave: la máquina de vapor","Consecuencias: ciudades, clase obrera y movimientos sindicales"],
   "example":"Las fábricas textiles pasaron de talleres artesanales a producción con máquinas.","yt":"revolución industrial causas consecuencias",
   "questions":[
    Q("¿En qué país comenzó la Revolución Industrial?","Gran Bretaña",["Colombia","Japón","Brasil"],"Allí se concentraron carbón, capital y nuevas máquinas."),
    Q("¿Qué invento fue clave para mover máquinas y trenes?","la máquina de vapor",["el computador","la imprenta","el telégrafo"],"Permitió mecanizar la producción y el transporte."),
    Q("Una consecuencia social de la Revolución Industrial fue…","el crecimiento de las ciudades y de la clase obrera",["la desaparición del comercio","el fin de las fábricas","la reducción de la población urbana"],"Muchas personas migraron del campo a las ciudades para trabajar.")]},
  {"id":"soc10a","grade":10,"title":"La Guerra Fría",
   "summary":"Entre 1947 y 1991 aproximadamente, Estados Unidos (capitalismo) y la Unión Soviética (comunismo) compitieron por influencia mundial sin enfrentarse directamente: carrera armamentista, carrera espacial y guerras indirectas.",
   "points":["Superpotencias: EE. UU. y URSS","Hechos: crisis de los misiles (1962), guerras de Corea y Vietnam","Fin: caída del Muro de Berlín (1989) y disolución de la URSS (1991)"],
   "example":"La carrera espacial incluyó el lanzamiento del Sputnik (1957) y la llegada a la Luna (1969).","yt":"guerra fría resumen",
   "questions":[
    Q("¿Qué dos potencias protagonizaron la Guerra Fría?","Estados Unidos y la Unión Soviética",["Francia y Alemania","China y Japón","Reino Unido y España"],"Representaban capitalismo y comunismo."),
    Q("¿Qué hecho simboliza el fin de la Guerra Fría?","la caída del Muro de Berlín",["la Revolución Francesa","la Primera Guerra Mundial","el Tratado de Versalles"],"Ocurrió en 1989."),
    Q("Se llamó «fría» porque…","no hubo un enfrentamiento militar directo entre las dos potencias",["hizo mucho frío","no hubo conflictos en el mundo","terminó en invierno"],"La confrontación fue indirecta e ideológica.")]},
  {"id":"soc10b","grade":10,"title":"Derechos Humanos y DIH",
   "summary":"Los derechos humanos pertenecen a toda persona por el solo hecho de serlo. La Declaración Universal se adoptó en 1948. El Derecho Internacional Humanitario (Convenios de Ginebra) protege a la población civil durante los conflictos armados.",
   "points":["DDHH: universales, inalienables e indivisibles","Declaración Universal: 1948 (ONU)","DIH: limita la guerra y protege a civiles, heridos y prisioneros"],
   "example":"Atacar a un hospital en medio de una guerra viola el DIH.","yt":"derechos humanos DIH diferencias",
   "questions":[
    Q("¿En qué año se adoptó la Declaración Universal de los Derechos Humanos?","1948",["1789","1991","2000"],"Fue aprobada por la ONU tras la Segunda Guerra Mundial."),
    Q("El Derecho Internacional Humanitario se aplica principalmente en…","conflictos armados",["elecciones","competencias deportivas","negociaciones comerciales"],"Regula la conducción de las hostilidades."),
    Q("Que los derechos humanos sean «universales» significa que…","corresponden a todas las personas sin discriminación",["solo aplican en algunos países","se compran","dependen del gobierno de turno"],"Nadie puede ser excluido de ellos.")]},
  {"id":"soc11a","grade":11,"title":"Globalización",
   "summary":"La globalización es la creciente interconexión económica, cultural, política y tecnológica entre los países. Ofrece oportunidades de comercio e información, pero también genera desigualdades y riesgos para las culturas locales.",
   "points":["Ejemplos: internet, tratados de libre comercio, empresas multinacionales","Ventajas: comercio, acceso a información, intercambio cultural","Retos: desigualdad, dependencia y pérdida de identidad cultural"],
   "example":"Un celular se diseña en un país, se arma en otro y se vende en todo el mundo.","yt":"globalización ventajas desventajas",
   "questions":[
    Q("La globalización es…","la creciente interconexión entre países",["el aislamiento económico","un tipo de gobierno","un fenómeno solo climático"],"Abarca economía, cultura, política y tecnología."),
    Q("¿Cuál es un ejemplo de globalización económica?","un tratado de libre comercio",["una fiesta local","una ley municipal","un censo escolar"],"Facilita el intercambio de bienes entre países."),
    Q("Una posible desventaja de la globalización es…","la pérdida de identidad cultural y el aumento de desigualdades",["menos información disponible","menos comercio","ninguna, no tiene desventajas"],"Las culturas locales pueden verse desplazadas por modelos externos.")]},
  {"id":"soc11b","grade":11,"title":"Ramas del poder público",
   "summary":"En Colombia el poder público se divide en tres ramas: legislativa (hace las leyes), ejecutiva (gobierna y ejecuta) y judicial (administra justicia). Además existen órganos de control y organismos electorales.",
   "points":["Legislativa: Congreso (Senado y Cámara)","Ejecutiva: Presidente, gobernadores y alcaldes","Judicial: jueces y altas cortes · Control: Procuraduría, Contraloría, Defensoría"],
   "example":"Una ley aprobada por el Congreso es sancionada por el Presidente y aplicada por los jueces.","yt":"ramas del poder público colombia",
   "questions":[
    Q("¿Qué rama del poder público crea las leyes?","la legislativa",["la ejecutiva","la judicial","la electoral"],"El Congreso de la República hace las leyes."),
    Q("La rama judicial se encarga de…","administrar justicia",["hacer las leyes","recaudar impuestos","organizar elecciones"],"Los jueces y las cortes aplican la ley."),
    Q("¿Qué entidad defiende y promueve los derechos humanos de los ciudadanos?","la Defensoría del Pueblo",["la Contraloría","el Senado","la Registraduría"],"Hace parte del Ministerio Público junto con la Procuraduría.")]}]}
]

def main():
    out = os.path.join(ROOT, "assets", "data"); os.makedirs(out, exist_ok=True)
    for a in AREAS:
        for l in a["lessons"]:
            l["video"] = f"assets/videos/{l['id']}.mp4"
            for q in l["questions"]:
                assert len(q["o"]) == 4 and 0 <= q["a"] < 4
    with open(os.path.join(out, "content.json"), "w", encoding="utf-8") as f:
        json.dump({"version": 1, "areas": AREAS}, f, ensure_ascii=False, indent=1)
    build_videos()

FB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
W, H = 960, 540

def hex2rgb(h): h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def wrap(d, text, font, maxw):
    words, lines, cur = text.split(), [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if d.textlength(t, font=font) <= maxw: cur = t
        else: lines.append(cur); cur = w
    if cur: lines.append(cur)
    return lines

def slide(color, title, body_lines, path, logo):
    c = hex2rgb(color)
    im = Image.new("RGB", (W, H), (13, 27, 94)); d = ImageDraw.Draw(im)
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=tuple(int(13 * (1 - t) + c[i] * t * 0.9 + 0) if False else int((13, 27, 94)[i] * (1 - t * 0.7) + c[i] * t * 0.7) for i in range(3)))
    d.rounded_rectangle([40, 40, W - 40, H - 40], 28, fill=(255, 255, 255))
    d.rectangle([40, 40, 56, H - 40], fill=c)
    d.text((90, 70), title, font=ImageFont.truetype(FB, 40), fill=(13, 27, 94))
    f = ImageFont.truetype(FR, 30); y = 150
    for item in body_lines:
        for k, ln in enumerate(wrap(d, item, f, W - 260)):
            d.text((90 + (0 if k == 0 else 28), y), ("• " if k == 0 else "") + ln if k == 0 else ln, font=f, fill=(40, 40, 60)); y += 42
        y += 12
    lg = logo.resize((110, 110)); im.paste(lg, (W - 170, H - 170))
    im.save(path)

def build_videos():
    logo = Image.open(os.path.join(ROOT, "assets/images/logo.png")).convert("RGB")
    vdir = os.path.join(ROOT, "assets", "videos"); os.makedirs(vdir, exist_ok=True)
    for a in AREAS:
        for l in a["lessons"]:
            tmp = tempfile.mkdtemp()
            slides = [
                (a["name"] + " · Grado " + str(l["grade"]), [l["title"], "Aprende jugando, supera cada reto"]),
                ("Idea clave", [l["summary"]]),
                ("Recuerda", l["points"]),
                ("Ejemplo", [l["example"]]),
                ("¡Ahora a practicar!", ["Responde el reto de esta lección y suma puntos en EduPlay."]),
            ]
            lst = []
            for i, (t, b) in enumerate(slides):
                p = os.path.join(tmp, f"s{i}.png"); slide(a["color"], t, b, p, logo)
                lst.append(f"file '{p}'\nduration {6 if i in (1, 2) else 4}")
            lst.append(f"file '{os.path.join(tmp, 's4.png')}'")
            with open(os.path.join(tmp, "l.txt"), "w") as f: f.write("\n".join(lst))
            subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", os.path.join(tmp, "l.txt"),
                            "-vf", "scale=640:360,format=yuv420p", "-r", "5", "-c:v", "libx264", "-preset", "fast", "-crf", "30",
                            os.path.join(vdir, l["id"] + ".mp4")], check=True)
            shutil.rmtree(tmp)

if __name__ == "__main__":
    main()
