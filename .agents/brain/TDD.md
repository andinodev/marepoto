# Documento de Diseño Técnico (TDD) - Tomanji Godot 4.6

## 1. Arquitectura General

El proyecto utilizará una estructura de nodos modular en Godot 4.6, centrada en una escena principal que gestiona el flujo de estados.

### Stack Tecnológico

- **Engine**: Godot 4.6 (Stable)
- **Lenguaje**: GDScript 2.0 (Tipado estático recomendado)
- **Resolución Base**: 1080x1920 (Portrait Mobile) o 1920x1080 (Landscape) - _Se desarrollará en 1080x1920 (Portrait) para celular, con soporte de UI responsive._
- **Input**: `InputEventScreenTouch` (simulado con Mouse en PC).

## 2. Estructura de Escenas (.tscn)

### `Main.tscn` (Root)

Controlador principal del flujo.

- `Control` (Root UI)
  - `Background` (TextureRect + Shader neón/selva)
  - `SetupUI` (Control - Fase 1)
  - `GameUI` (Control - Fase 2)
    - `Header` (Turno actual)
    - `Roulette` (Control custom)
    - `SpinButton` (Button)
  - `ChallengeModal` (Control - Popup, inicialmente oculto)
  - `AudioStreamPlayer` (Música de fondo)

### `Roulette.tscn` (Componente)

Escena instanciable para la ruleta.

- `Node2D` (Pivote de rotación)
  - `WheelSprite` (Sprite2D o Control con `_draw`)
  - `Segments` (Node2D container para etiquetas de texto)
- `Pointer` (Sprite2D fijo en la parte superior/lateral, fuera del pivote rotatorio).

## 3. Autoloads (Singletons)

### `GameManager.gd`

Gestiona el estado global del juego.

- `state`: Enum { SETUP, PLAYING, CHALLENGE_VIEW }
- `players`: Array[Dictionary] { id, name, color, sips }
- `current_player_index`: int
- `func add_player(name)`
- `func next_turn()`
- `func get_current_player()`

### `ChallengeDB.gd`

Base de datos de retos.

- `challenges_player`: Array[Dictionary] (Cargado desde JSON)
- `challenges_all`: Array[Dictionary]
- `used_ids`: Array[int]
- `func get_random_challenge(target_type: String) -> Dictionary`
- `func load_challenges()`: Lee `res://data/challenges.json`.

### `AudioManager.gd`

- `play_sfx(stream_name)`
- `play_music(stream_name)`
- `toggle_mute()`

## 4. Lógica de Componentes

### Ruleta (`Roulette.gd`)

- **Visualización**: Dibuja sectores dinámicamente según `GameManager.players.size()`.
- **Giro**: Usa `create_tween()` para interpolar la propiedad `rotation` del contenedor.
  - `Tween.EASE_OUT`, `Tween.TRANS_CUBIC`.
  - Duración: ~3-4 segundos.
  - Rotación total: `current_rotation + (360 * 5) + random_offset`.
- **Cálculo**: Al terminar el tween, normaliza el ángulo para determinar el ganador.
  - _Nota_: Godot maneja rotación en radianes, convertir a grados `rad_to_deg`.

### Modal de Reto (`ChallengeModal.gd`)

- Muestra `TitleLabel`, `StoryLabel`, `ActionLabel`.
- Recibe el diccionario del reto desde `Main` en señal `spin_completed`.
- Reemplaza placeholders `{J1}`, `{J2}` con nombres reales.

## 5. Datos (JSON)

Formato de `challenges.json`:

```json
{
  "player": [
    {
      "id": 101,
      "title": "...",
      "story": "...",
      "action": "...",
      "timer": 60,
      "sips": [{ "amount": 3, "condition": "Si falla...", "target": "SELF" }]
    }
  ],
  "all": [
    {
      "id": 201,
      "title": "...",
      "story": "...",
      "action": "...",
      "sips": [{ "amount": 1, "condition": "Todos", "target": "ALL" }]
    }
  ]
}
```

### Enums

- **SipTarget**: `SELF` (Jugador actual), `ALL` (Todos), `DISTRIBUTE` (Jugador reparte), `NEXT` (Siguiente), `PREVIOUS` (Anterior), `SPECIFIC` (Otro específico).

```

## 6. Assets Necesarios

- **Fuentes**: Una fuente "Adventure" o "Tribal" para títulos, Sans-serif limpia para textos.
- **Imágenes**: Fondo de selva oscura, textura de madera/piedra para UI, icono de sonido.
- **Sonidos**: `roulette_spin.wav`, `win_jingle.wav`, `click.wav`, `jungle_ambient.ogg`.
```
