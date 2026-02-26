# 🌴 MAREPOTO

**Marepoto** es un juego de carrete (fiesta) para Android, construido con **Godot Engine 4.6**. Los jugadores giran una ruleta para recibir desafíos, pruebas y preguntas incómodas con castigos de _sorbos_ de copete. Ideal para fiestas, juntas y previas.

> **Package ID:** `cl.andinodev.marepoto`
> **Plataforma:** Android (arm64-v8a)
> **Resolución base:** 1080 × 1920 (Portrait)

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Autoloads (Singletons)](#-autoloads-singletons)
- [Escenas](#-escenas)
- [Sistema de Desafíos](#-sistema-de-desafíos)
- [UI y Safe Zone](#-ui-y-safe-zone)
- [Assets](#-assets)
- [Configuración del Proyecto](#-configuración-del-proyecto)
- [Build y Exportación](#-build-y-exportación)
- [Desarrollo Local](#-desarrollo-local)

---

## ✨ Características

- **Ruleta interactiva** con segmentos dinámicos por jugador y un segmento "TODOS"
- **+80 desafíos** organizados en categorías (acciones, confesiones, cadenas de nombres, castigos extremos)
- **Sistema CRUD completo** para administrar desafíos desde la app
- **Soporte para timer** en desafíos que requieren tiempo límite
- **Sistema de sorbos** con targets configurables (`SELF`, `SPECIFIC`, `ALL`, `DISTRIBUTE`)
- **Persistencia** de jugadores y desafíos personalizados en `user://`
- **Safe Zone** para notch/punch-hole en dispositivos modernos
- **Tema "Neón Selvático"** con colores vibrantes y estilo neon-tropical
- **Efectos de sonido** para giro de ruleta y selección
- **Soporte para hasta 12 jugadores** con colores asignados automáticamente
- **Soft-delete** en desafíos (borrado lógico con posibilidad de restaurar)

---

## 🏗 Arquitectura

```
┌─────────────────────────────────────────────┐
│                   Main.tscn                 │
│  (Root Control — gestiona 3 pantallas)      │
│                                             │
│  ┌──────────┐ ┌──────────┐ ┌─────────────┐ │
│  │ SetupUI  │ │ GameUI   │ │ChallengeModal│ │
│  │(jugadores│ │(ruleta + │ │  (desafío   │ │
│  │  + config)│ │ spin btn)│ │   activo)   │ │
│  └──────────┘ └──────────┘ └─────────────┘ │
└─────────────────────────────────────────────┘
         ▲              ▲             ▲
         │              │             │
    ┌────┴────┐  ┌──────┴──────┐  ┌──┴───┐
    │GameManager│ │ChallengeDB │ │Audio │
    │(state,   │  │(CRUD,random)│  │Mgr  │
    │players,  │  └─────────────┘  └──────┘
    │turns)    │
    └──────────┘
```

### Flujo del Juego

1. **SETUP** → Los jugadores se agregan por nombre
2. **PLAYING** → Se gira la ruleta; al detenerse se selecciona un jugador o "TODOS"
3. **CHALLENGE_VIEW** → Se muestra un desafío aleatorio con su historia, acción, sorbos y timer (si aplica)
4. **Vuelta al paso 2** con el siguiente turno

---

## 📁 Estructura del Proyecto

```
marepoto/
├── project.godot              # Configuración del proyecto
├── export_presets.cfg          # Presets de exportación Android (APK + AAB)
├── data/
│   └── challenges.json        # Base de datos de desafíos (res://)
├── fonts/
│   ├── Roboto-VariableFont_wdth,wght.ttf
│   ├── Roboto-Italic-VariableFont_wdth,wght.ttf
│   └── NotoColorEmoji-Regular.ttf
├── scenes/
│   ├── Main.tscn              # Escena principal
│   └── ChallengeManager.tscn  # CRUD de desafíos
├── scripts/
│   ├── Main.gd                # Controlador principal UI
│   ├── Roulette.gd            # Componente de ruleta (drawing custom)
│   ├── ChallengeManager.gd    # UI CRUD para administrar desafíos
│   └── autoloads/
│       ├── GameManager.gd     # Estado global, jugadores, turnos
│       ├── ChallengeDB.gd     # Carga, CRUD y servicio de desafíos
│       ├── AudioManager.gd    # Reproductor de SFX
│       ├── ThemeManager.gd    # Carga y aplica el theme global
│       └── SafeZoneManager.gd # Insets para notch/cutout
├── sounds/
│   ├── spin-wheel.mp3         # SFX giro de ruleta
│   └── player-selected.wav    # SFX selección de jugador
├── sprites/
│   └── ui/                    # Assets de UI (banners, panels, theme.tres)
└── build/
    ├── marepoto.apk            # Export APK
    └── marepoto.aab            # Export AAB (Google Play)
```

---

## 🔧 Autoloads (Singletons)

Todos los autoloads se registran en `project.godot` bajo `[autoload]` y están disponibles globalmente.

### GameManager

| Aspecto             | Detalle                                            |
| ------------------- | -------------------------------------------------- |
| **Archivo**         | `scripts/autoloads/GameManager.gd`                 |
| **Responsabilidad** | Estado del juego, gestión de jugadores y turnos    |
| **Estados**         | `SETUP`, `PLAYING`, `CHALLENGE_VIEW`               |
| **Señales**         | `state_changed`, `players_changed`, `turn_changed` |
| **Persistencia**    | `user://players.json`                              |
| **Límite**          | Máximo 12 jugadores                                |
| **Colores**         | 12 colores predefinidos asignados cíclicamente     |

### ChallengeDB

| Aspecto             | Detalle                                                               |
| ------------------- | --------------------------------------------------------------------- |
| **Archivo**         | `scripts/autoloads/ChallengeDB.gd`                                    |
| **Responsabilidad** | CRUD completo de desafíos + servicio de desafíos aleatorios           |
| **Datos base**      | `res://data/challenges.json` (solo lectura)                           |
| **Datos usuario**   | `user://challenges.json` (lectura/escritura)                          |
| **Soft-delete**     | Los desafíos eliminados se marcan con `"deleted": true`               |
| **Anti-repetición** | Mantiene `_used_ids` para evitar repetir desafíos en la misma partida |

### AudioManager

| Aspecto             | Detalle                                           |
| ------------------- | ------------------------------------------------- |
| **Archivo**         | `scripts/autoloads/AudioManager.gd`               |
| **Responsabilidad** | Pool de `AudioStreamPlayer` para SFX concurrente  |
| **Pool**            | 4 reproductores simultáneos máximo                |
| **API**             | `play_sfx(stream, volume_db)`, `stop_sfx(stream)` |

### ThemeManager

| Aspecto             | Detalle                                                   |
| ------------------- | --------------------------------------------------------- |
| **Archivo**         | `scripts/autoloads/ThemeManager.gd`                       |
| **Responsabilidad** | Carga `res://sprites/ui/theme.tres` y lo aplica al `root` |

### SafeZoneManager

| Aspecto             | Detalle                                                                |
| ------------------- | ---------------------------------------------------------------------- |
| **Archivo**         | `scripts/autoloads/SafeZoneManager.gd`                                 |
| **Responsabilidad** | Calcula insets de safe area para notch/punch-hole                      |
| **API**             | `DisplayServer.get_display_safe_area()`                                |
| **Señales**         | `safe_area_changed(top, bottom, left, right)`                          |
| **Helper**          | `apply_to_margin(container, pad_top, pad_bottom, pad_left, pad_right)` |
| **Escalado**        | Convierte de píxeles físicos a viewport automáticamente                |

---

## 🎬 Escenas

### Main.tscn

Escena principal del juego. Contiene tres paneles hijos mutuamente exclusivos:

- **SetupUI** → Pantalla de configuración con input de nombres, lista de jugadores, botón de inicio y acceso al admin de desafíos. Wraped en `SafeMargin` (`MarginContainer`).
- **GameUI** → Pantalla de juego con `TopBar` (turno actual + botón volver), `Roulette` (componente de ruleta custom draw) y `SpinBtn`. Wrapped en `SafeMargin`.
- **ChallengeModal** → Modal central mostrando título, historia, acción, sorbos y timer del desafío actual.

### ChallengeManager.tscn

Escena instanciada dinámicamente desde `Main.gd` para administrar desafíos. Genera toda su UI programáticamente con:

- Tabs por categoría (`player` / `all`)
- Lista paginada (25 por página) con scroll
- Formulario de creación/edición con campos: título, historia, acción, target, sorbos, timer
- Soft-delete con confirmación
- Toast de feedback

---

## 🎯 Sistema de Desafíos

### Estructura JSON

```json
{
  "player": [
    {
      "id": 101,
      "title": "Posesión",
      "story": "{J1} ha sido poseído por el espíritu de {J2}.",
      "action": "Los jugadores se tienen que cambiar una prenda...",
      "timer": 30,
      "sips": [
        {
          "amount": 3,
          "condition": "Si no se cambian ropa",
          "target": "SPECIFIC"
        }
      ]
    }
  ],
  "all": [...]
}
```

### Campos

| Campo     | Tipo     | Requerido | Descripción                                                                         |
| --------- | -------- | --------- | ----------------------------------------------------------------------------------- |
| `id`      | `int`    | Sí (auto) | Identificador único, auto-generado                                                  |
| `title`   | `string` | Sí        | Nombre del desafío                                                                  |
| `story`   | `string` | Sí        | Contexto narrativo. Puede usar `{J1}` (jugador actual) y `{J2}` (jugador aleatorio) |
| `action`  | `string` | Sí        | Instrucción de lo que se debe hacer                                                 |
| `timer`   | `int`    | No        | Segundos del temporizador. Si se omite, no hay timer                                |
| `sips`    | `array`  | Sí        | Lista de penalizaciones de sorbos                                                   |
| `deleted` | `bool`   | No        | Flag de soft-delete                                                                 |

### Targets de Sorbos

| Target       | Descripción                     |
| ------------ | ------------------------------- |
| `SELF`       | El jugador actual bebe          |
| `SPECIFIC`   | Un jugador específico bebe      |
| `ALL`        | Todos beben                     |
| `DISTRIBUTE` | Se reparten sorbos entre varios |

### Categorías

| Categoría  | Key JSON   | Descripción                                         |
| ---------- | ---------- | --------------------------------------------------- |
| **Player** | `"player"` | Desafíos para el jugador seleccionado por la ruleta |
| **All**    | `"all"`    | Desafíos para cuando la ruleta cae en "TODOS"       |

---

## 🖼 UI y Safe Zone

### Tema Visual: "Neón Selvático"

La UI aplica un tema programático en `Main.gd` → `_apply_neon_theme()`:

| Elemento                        | Color                     |
| ------------------------------- | ------------------------- |
| Fondo principal                 | `#0f0f1a` (casi negro)    |
| Fondo secundario                | `#1a1a2e` (azul oscuro)   |
| Acento primario (bordes, texto) | `#22c55e` (verde neón)    |
| Acento secundario               | `#facc15` (amarillo neón) |
| Texto                           | Blanco sobre oscuro       |

### Safe Zone (Notch / Cutout)

El `SafeZoneManager` autoload protege la UI de notches y punch-holes:

1. Consulta `DisplayServer.get_display_safe_area()` al inicio y en cada resize
2. Escala los insets de píxeles físicos a viewport
3. Aplica márgenes a `MarginContainer` wrappers en cada pantalla
4. **En desktop:** insets = 0 (sin cambio visual)
5. **En Android con notch:** el contenido se aparta automáticamente del cutout

---

## 🎨 Assets

### Fuentes

| Fuente               | Uso                                                 |
| -------------------- | --------------------------------------------------- |
| **Roboto Variable**  | Fuente principal de la UI                           |
| **Noto Color Emoji** | Fallback para renderizar emojis en todos los Labels |

### Sonidos

| Archivo               | Uso                                          |
| --------------------- | -------------------------------------------- |
| `spin-wheel.mp3`      | Loop durante el giro de la ruleta            |
| `player-selected.wav` | Al detenerse la ruleta y seleccionar jugador |

### Sprites UI

El directorio `sprites/ui/` contiene assets de [Kenney's UI Pack](https://kenney.nl/) incluyendo banners, paneles, barras de progreso, scrollbars, etc. El theme visual se define en `sprites/ui/theme.tres`.

---

## ⚙ Configuración del Proyecto

```ini
# project.godot
[application]
config/name = "Marepoto"
run/main_scene = "res://scenes/Main.tscn"
config/features = PackedStringArray("4.6", "Mobile")

[display]
window/size/viewport_width = 1080
window/size/viewport_height = 1920
window/handheld/orientation = 1  # Portrait

[rendering]
renderer/rendering_method = "mobile"
```

### Autoloads registrados

```ini
GameManager    = "*res://scripts/autoloads/GameManager.gd"
ChallengeDB    = "*res://scripts/autoloads/ChallengeDB.gd"
AudioManager   = "*res://scripts/autoloads/AudioManager.gd"
ThemeManager   = "*res://scripts/autoloads/ThemeManager.gd"
SafeZoneManager = "*res://scripts/autoloads/SafeZoneManager.gd"
```

---

## 📦 Build y Exportación

### Export Presets

| Preset               | Formato | Gradle | Uso                            |
| -------------------- | ------- | ------ | ------------------------------ |
| **Android PROD**     | APK     | No     | Testing directo en dispositivo |
| **Android PROD AAB** | AAB     | Sí     | Publicación en Google Play     |

### Configuración común

- **Arquitectura:** arm64-v8a (64-bit)
- **Package:** `cl.andinodev.marepoto`
- **Modo inmersivo:** Activado
- **Pantalla completa:** Sí
- **Script export mode:** Compilado (modo 2)
- **Output APK:** `build/marepoto.apk`
- **Output AAB:** `build/marepoto.aab`

### Exportar desde línea de comandos

```bash
# APK para testing
godot --headless --export-debug "Android PROD" build/marepoto.apk

# AAB para Google Play
godot --headless --export-release "Android PROD AAB" build/marepoto.aab
```

---

## 🛠 Desarrollo Local

### Requisitos

- [Godot Engine 4.6](https://godotengine.org/download) (Mobile renderer)
- Android SDK + NDK (para exportar a Android)
- Dispositivo Android o emulador para testing

### Abrir el proyecto

```bash
git clone https://github.com/andinodev/marepoto-godot.git
cd marepoto-godot
# Abrir con Godot Editor
godot project.godot
```

### Probar Safe Zone en editor

Para simular notch en desktop, editar temporalmente `SafeZoneManager.gd`:

```gdscript
func _ready() -> void:
    top_inset = 120  # Simular notch de 120px
    _recalculate()
    get_viewport().size_changed.connect(_recalculate)
```

### Agregar nuevos desafíos

1. Editar `data/challenges.json` directamente, o
2. Usar el panel **"⚙ Administrar Retos"** desde la app (los cambios se guardan en `user://challenges.json`)

---

## 📄 Licencia

Desarrollado por [AndinoDev](https://github.com/andinodev).

Los assets de UI son de [Kenney.nl](https://kenney.nl/) — licencia CC0.
