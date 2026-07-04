## Propuesta: Enfoque "Party Game" Local

### 1. Valor Estratégico dentro del Ecosistema

El objetivo de este proyecto es desarrollar un minijuego de Air Hockey competitivo (1 contra 1) en Godot 4.6, optimizado para dispositivos móviles con pantallas táctiles.

Este minijuego se integra perfectamente al ecosistema de tu videojuego móvil. Aporta una experiencia competitiva rápida y directa que contrasta muy bien con la mecanica base del juego.

### 2. Requisitos Críticos de UX y Ergonomía (Modo "Tabletop")

Dado que dos personas interactuarán con la misma pantalla al mismo tiempo, el diseño debe contemplar que el teléfono probablemente estará apoyado sobre una mesa o sostenido de forma poco convencional:

- **Interfaz Bidireccional:** Cualquier texto, puntuación o temporizador en la pantalla durante el juego debe ser legible para ambos jugadores. No puede haber un "arriba" o "abajo" definitivo; la UI de la mitad superior debe estar rotada 180 grados.
- **Zonas Muertas Intencionales:** Es vital definir una zona neutral en el centro de la cancha (la línea divisoria) donde los mazos (paddles) no puedan cruzar. Esto no solo obedece a las reglas del Air Hockey, sino que evita que los dedos de los jugadores choquen físicamente en la pantalla.
- **Gestión del "Multi-touch":** A nivel técnico (aunque sin entrar en código), la gerencia debe exigir que las pruebas de QA aseguren que los toques simultáneos y los gestos de arrastre rápidos no confundan al sistema operativo del teléfono, evitando que se cierren aplicaciones por accidente o se bloquee la entrada de uno de los jugadores.

### 3. Flujo de Perfiles y Variables (`player1`, `player2`)

Al ser una experiencia local, el flujo de entrada a la escena debe ser extremadamente rápido para mantener el ritmo de un "party game":

- **Inyección Ágil:** Cuando salga un challenge dentro de la base de datos de retos con el atributo minigame que seria un objeto el cual contiene el type (enum, por ahora solo HOCKEY, tambien tiene que tener rounds el cual va a ser la cantidad de victorias en el minijuego que necesita un jugador para ganar
- **Fin del minijuego:** Al terminar la partida, tiene que devolver a la escena `Main.tscn` con el challenge modal aun activo, tiene que aparecer un modal por encima el cual muestre al ganador y al perdedor en rojo con una calaca 💀

### 4. UI del minijuego

Los assets tienen que tener un aspecto minimalista con luces de neon las cuales al interactuar con la bola (paredes, jugadores, arco) tiene que aumentar brevemente la intencidad del glow de las luces de neon en el lugar donde chocaron, esto es importante para el aspecto estetico porque le daria un gran plus.

Recuerda
