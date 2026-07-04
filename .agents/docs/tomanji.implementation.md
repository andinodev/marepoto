# Prompt de Implementación Godot 4.6 - Tomanji

**Rol**: Eres un Senior Game Developer experto en Godot 4.6 y "Juice" (Game Feel).

**Objetivo**: Crear el proyecto "Tomanji" desde cero en Godot 4.6 siguiendo la documentación adjunta.

## Instrucciones para el Agente (Claude Opus)

1.  **Lectura de Documentación**:
    - Lee `brain/GDD.md` para entender la visión y el "flow" del juego.
    - Lee `brain/TDD.md` para la arquitectura técnica y estructura de `Main.tscn` y `Autoloads`.
    - Lee `brain/Content_Tomanji.md` para obtener el JSON de retos (con `sips` estructurados, `target` Enums y `timer`).

2.  **Configuración del Proyecto**:
    - Crea un nuevo proyecto Godot 4.6.
    - Configura la resolución a **1080x1920 (Portrait)** (Testable en PC).
    - Configura el input para simular toque con mouse.

3.  **Implementación Fase 1: Core Systems**:
    - Crea `GameManager.gd` y `AudioManager.gd` (Autoloads).
    - Crea `ChallengeDB.gd` y copia el contenido JSON de `brain/Content_Tomanji.md` en `res://data/challenges.json`.
    - **Importante**: Parsea los arrays `sips`. Usa el campo `target` para la lógica de quién toma:
      - `SELF`: Jugador actual.
      - `ALL`: Todos los jugadores.
      - `DISTRIBUTE`: El jugador actual selecciona a otro(s) para que tomen.
      - `SPECIFIC`: Otro jugador específico (ej. el de la derecha, o el perdedor del duelo).

4.  **Implementación Fase 2: UI & Game Loop**:
    - Implementa `Main.tscn` con los estados SETUP y PLAYING.
    - Crea la `Roulette.tscn` con dibujo dinámico (`_draw`) de segmentos según la cantidad de jugadores.
    - **ChallengeModal**:
      - Muestra título, historia y acción.
      - **Sorbos**: Muestra visualmente la cantidad y condición. Si `target` es `DISTRIBUTE`, muestra una UI para seleccionar jugadores (opcional en Fase 2, pero prepara la lógica).
      - **Timer**: Si el reto tiene el atributo `timer` (segundos), muestra un Temporizador visual (barra o números). Debe ser activable por el usuario (Botón "Iniciar Tiempo") para mejor UX.

5.  **Implementación Fase 3: Juice & Polish**:
    - Asegúrate de que la estética sea "Neón Selvático" (Background oscuro, bordes neón).
    - Agrega feedback visual (escalas, colores) al ganar/perder.
    - Agrega sonido de Tic-Tac al Timer y una alarma final.

## Notas Importantes

- **No inventes retos nuevos**: Usa estrictamente los que están en `brain/Content_Tomanji.md`.
- **Estilo**: El código debe ser limpio, tipado (`func name() -> void:`) y modular.
- **Chilenismos**: Mantén los textos tal cual están en el JSON, son parte de la identidad del juego, pero analiza si se siente forzado el "chilenismo" en los textos, para mejorarlos.

¡Manos a la obra!
