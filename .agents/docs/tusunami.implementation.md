# Documentación Técnica: Juego "Tusunami"

Este documento detalla la implementación del nuevo modo de juego "Tusunami" (anteriormente referido como Tsunam) dentro del ecosistema de **Marepoto**. Se han aplicado principios de diseño AAA y patrones de ingeniería robustos en Godot 4.

---

## 🎮 Concepto del Juego (Game Concept Advisor)

**Tusunami** es un juego de cartas de alta tensión y acumulación de riesgo. El objetivo es adivinar el color de la carta antes de revelarla. Cada acierto aumenta la presión sobre el siguiente jugador, creando una "ola" de tragos que eventualmente romperá sobre alguien.

### Reglas Básicas:

- **Tablero:** Una cuadrícula de 2 filas x 3 columnas (+ mazo central).
- **Cartas:** Lado posterior Verde; Lado frontal Rojo o Azul.
- **Dinámica:**
  1. Turno rotativo (inicia aleatoriamente).
  2. El jugador elige una carta boca abajo.
  3. **Modal de Predicción:** El jugador elige "Rojo" o "Azul".
  4. **Revelación:** Si acierta, pasa el turno y se acumula +1 sorbo.
  5. **Impacto:** Si falla, el jugador debe beber el total acumulado + 1. El contador se reinicia.
- **Reposición:** Las cartas se reponen del mazo central solo después de que alguien "pierde" y bebe.
- **Modo Supervivencia:** Si la cuadrícula se vacía, se juega directamente desde el mazo.

---

## 🛠️ Arquitectura de Ingeniería (Game Engineering Team)

### Integración en el Estado Global (`GameManager.gd`)

Reutilizaremos la lógica de jugadores y turnos existente. Añadiremos nuevos estados al `enum State`:

- `GAME_SELECTION`: Pantalla intermedia para elegir entre Marepoto o Tusunami.
- `PLAYING_Tusunami`: Estado activo del minijuego de cartas.

### Flujo de Interfaz (`Main.gd`)

Utilizaremos el patrón de `_slide_transition` existente para movernos entre:
`SetupUI` ➔ `GameSelectionUI` ➔ `TusunamiUI`

---

## 🎨 Diseño Visual y Experiencia (Visual Artist & Fun Advisor)

### Paleta de Colores

Siguiendo la estética **Neón Selvático**:

- **Dorso de Carta:** Verde Esmeralda Vibrante (#22c55e).
- **Frente Rojo:** Coral Intenso (#ff415c).
- **Frente Azul:** Cian Eléctrico (#3689ac).
- **Feedback:** Shaders de destello (Sunburst) al acertar y shader de "Defeat" (distorsión roja) al fallar.

### Interacciones de Deleite (Juiciness)

- **Animación de Flip:** Rotación en el eje Y mediante `Tween` con interpolación `TRANS_BACK`.
- **Acumulador de Sorbos:** Un contador gigante en la GUI que vibra y crece con cada acierto, aumentando la percepción de riesgo.

---

## 📋 Plan de Implementación (Godot GDScript Patterns)

### 1. Componente `TusunamiCard` (Control)

- **Nodos:** `TextureRect` para el frente y el dorso.
- **Lógica:**
  ```gdscript
  func flip(to_color: Color):
      var tween = create_tween()
      # Escalar a 0 para simular rotación 3D
      tween.tween_property(self, "scale:x", 0.0, 0.15)
      tween.tween_callback(func(): front.modulate = to_color; back.hide())
      tween.tween_property(self, "scale:x", 1.0, 0.15)
  ```

### 2. Controlador `TusunamiManager`

- Administrará un `Array` de colores mezclado aleatoriamente (Mazo).
- Gestionará el `GridContainer` de las 6 cartas activas.
- Conectará con el `GameManager` para rotar turnos.

### 3. Selección de Juego

En `Main.gd`, el botón de `Start` ahora enviará al estado `GAME_SELECTION`.

- **Botón Marepoto:** Dispara `GameManager.start_game()` (Roulette mode).
- **Botón Tusunami:** Dispara `GameManager.start_Tusunami()`.

---

## 💡 Recomendaciones del Fun Advisor

Para maximizar la diversión:

- **Efectos de sonido:** Un sonido de "campanilla" ascendente por cada acierto, y un sonido de "choque de olas" estruendoso al fallar.
- **Tensión Visual:** Cuando el acumulador de sorbos llega a 5+, añadir partículas de fuego o humo al contador para indicar el peligro.

---

> [!NOTE]
> Este diseño permite una escalabilidad total, permitiendo añadir más tipos de juegos en el futuro simplemente extendiendo la pantalla de selección y el `GameManager`.
