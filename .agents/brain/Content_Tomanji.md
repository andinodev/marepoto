# Contenido para Importar en Tomanji (Godot)

Este archivo contiene la base de datos de retos en formato JSON para ser utilizada directamente en `res://data/challenges.json`.

```json
{
  "player": [
    {
      "id": 101,
      "title": "Intercambio de Pieles",
      "story": "{J1} ha sido poseído por el espíritu de {J2}.",
      "action": "¡Córtala y cámbiense una prenda de ropa al tiro po! Si no, los dos se mandan 3 sorbos de copete.",
      "sips": [
        {
          "amount": 3,
          "condition": "Si no se cambian ropa",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 102,
      "title": "El Mimo Mudo",
      "story": "Una maldición te roba la voz.",
      "action": "{J1} tiene que actuar una peli sin hablar ni una weá. El primero que cache reparte 2 tragos. Si nadie cacha en 1 min, {J1} se manda 4 al seco.",
      "timer": 60,
      "sips": [
        {
          "amount": 2,
          "condition": "Repartir (Al que adivine)",
          "target": "SPECIFIC"
        },
        {
          "amount": 4,
          "condition": "Castigo (Si nadie adivina)",
          "target": "SELF"
        }
      ]
    },
    {
      "id": 103,
      "title": "Jeta de Chancho",
      "story": "¡Una criatura horrorosa aparece!",
      "action": "¡Pégate el show! Haz la cara más horrorosa que podai delante de todos. El grupo vota: si no da risa, tómate 3 al seco po.",
      "sips": [{ "amount": 3, "condition": "Si no da risa", "target": "SELF" }]
    },
    {
      "id": 104,
      "title": "Baile de la Lluvia",
      "story": "La sequía amenaza la jungla.",
      "action": "{J1} tiene que bailar perreo intenso contra la pared por 15 segundos. Todos juzgan: si está pa'l gato, toma 3 copetes.",
      "timer": 15,
      "sips": [{ "amount": 3, "condition": "Si baila mal", "target": "SELF" }]
    },
    {
      "id": 105,
      "title": "Estatua de Piedra",
      "story": "Medusa te ha mirado.",
      "action": "{J1} se queda tieso como palo hasta su próximo turno. Si se mueve, habla o se caga de la risa, toma 2 sorbos cada vez, cachai.",
      "sips": [
        {
          "amount": 2,
          "condition": "Por cada movimiento/habla",
          "target": "SELF"
        }
      ]
    },
    {
      "id": 106,
      "title": "El Perkin",
      "story": "Caíste en la trampa y {J2} te salvó el pellejo.",
      "action": "{J1} es el perkin de {J2} por 2 rondas. Tiene que servirle el copete, abanicarlo o hacerle masajitos. Si se pone choro, fondo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si desobedece (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 107,
      "title": "Llamada de Auxilio",
      "story": "Estái perdido, necesitai ayuda.",
      "action": "Llama a un contacto random (o a tu ex pololo/a) y dile que estái perdido en la selva y cuelga al tiro. Si no lo hacís, 4 sorbos po weón.",
      "sips": [{ "amount": 4, "condition": "Si no llama", "target": "SELF" }]
    },
    {
      "id": 108,
      "title": "Duelo de Pulgares",
      "story": "Disputa territorial.",
      "action": "{J1} reta a {J2} a una guerra de pulgares. El que pierde se manda 3 sorbos al seco.",
      "sips": [
        { "amount": 3, "condition": "Al perdedor", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 110,
      "title": "Gemelos Siameses",
      "story": "Una liana los dejó amarrados.",
      "action": "{J1} elige a un weón/weona. Tienen que estar pegados mejilla con mejilla hasta el siguiente turno de {J1}. Si se separan, toman los dos, corta.",
      "sips": [
        {
          "amount": 1,
          "condition": "Ambos si se separan",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 111,
      "title": "Acento Extranjero",
      "story": "Un combo en la cabeza te cambió el idioma.",
      "action": "Habla con acento (argentino, español, ruso, lo que sea) hasta tu próximo turno. Si se te olvida, tomai po.",
      "sips": [
        { "amount": 1, "condition": "Si olvida el acento", "target": "SELF" }
      ]
    },
    {
      "id": 112,
      "title": "Caminata de Cangrejo",
      "story": "Te transformaste en crustáceo.",
      "action": "Pega una vuelta a la mesa caminando como cangrejo. Si te ponís choro y no querís, tomai 3.",
      "sips": [{ "amount": 3, "condition": "Si se niega", "target": "SELF" }]
    },
    {
      "id": 113,
      "title": "El Fotógrafo Ciego",
      "story": "Se te fueron las luces.",
      "action": "{J1} se venda los ojos y tiene que servirle un copete a {J2} sin derramar ni una gota. Si derrama, se toma lo que cayó o un castigo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si derrama (Castigo)", "target": "SELF" }
      ]
    },
    {
      "id": 114,
      "title": "Tarzán",
      "story": "Sentís el llamado de la selva.",
      "action": "Súbete a una silla y pega tu mejor grito de Tarzán. El grupo califica del 1 al 10. Si sacai menos de 5, tomai la diferencia.",
      "sips": [
        { "amount": 1, "condition": "Por punto faltante", "target": "SELF" }
      ]
    },
    {
      "id": 115,
      "title": "Interrogatorio Policial",
      "story": "Te acusan de haberte choreado los plátanos.",
      "action": "{J2} te hace 3 preguntas rápidas. Tenís que contestar pura mentira. Si decís la firme o dudai, tomai.",
      "sips": [
        { "amount": 1, "condition": "Si duda o dice verdad", "target": "SELF" }
      ]
    },
    {
      "id": 116,
      "title": "Maquillaje Tribal",
      "story": "Prepárate pa' la guerra.",
      "action": "Deja que el grupo te pinte la jeta con un marcador o labial con marcas tribales. Si no querís, fondo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si se niega (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 117,
      "title": "El Bardo",
      "story": "Tenís que entretener a la tribu.",
      "action": "Inventa y canta una canción corta sobre el weón/weona de tu derecha. Si no rima, tomai 2.",
      "sips": [{ "amount": 2, "condition": "Si no rima", "target": "SELF" }]
    },
    {
      "id": 118,
      "title": "Equilibrista",
      "story": "Cruzai un tronco flaquito.",
      "action": "Mantén tu vaso en la cabeza mientras recitai el abecedario al revés (o hasta donde lleguís). Si se cae, tomai po.",
      "sips": [
        { "amount": 1, "condition": "Si se cae el vaso", "target": "SELF" }
      ]
    },
    {
      "id": 119,
      "title": "Beso de la Muerte",
      "story": "Un ritual de amor.",
      "action": "Dale un beso en la mejilla (o en la boca si se atreven) a {J2} o tomai 3 sorbos, no seai cobarde.",
      "sips": [
        { "amount": 3, "condition": "Si no da el beso", "target": "SELF" }
      ]
    },
    {
      "id": 120,
      "title": "El Bebé",
      "story": "Rejuveneciste mágicamente.",
      "action": "Tomai tu copete como si fuera mamadera (chupando el borde o con bombilla) hasta tu próximo turno, pa' la caña.",
      "sips": [
        { "amount": 0, "condition": "Beber como bebé (Modo)", "target": "SELF" }
      ]
    },
    {
      "id": 121,
      "title": "Títere",
      "story": "Una fuerza te controla.",
      "action": "{J2} te mueve como títere por 1 minuto. Tú dejate llevar no más po, sin alegar.",
      "timer": 60,
      "sips": []
    },
    {
      "id": 122,
      "title": "Cambio de Nombre",
      "story": "Se te olvidó quién erís.",
      "action": "El grupo te pone un nombre ridículo. Si alguien te llama por tu nombre real, esa persona toma. Tú respondís al nuevo, cachai.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que se equivoque de nombre",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 123,
      "title": "La Momia",
      "story": "Te envuelven pal entierro.",
      "action": "Déjate envolver en confort por el grupo. Después rompí la 'momia' bailando como si estuvierai en el carrete.",
      "sips": []
    },
    {
      "id": 124,
      "title": "Cata a Ciegas",
      "story": "Prueba los frutos del bosque.",
      "action": "Cierra los ojos. {J2} te da a probar algo de la cocina. Si cachai qué es, {J2} toma. Si no, tomai tú.",
      "sips": [
        {
          "amount": 1,
          "condition": "A {J2} si adivina o a ti si fallas",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 125,
      "title": "El Predicador",
      "story": "Viste la luz po.",
      "action": "Párate y manda un discursito de 1 minuto sobre las virtudes del copete. ¡Salud! Todos toman 1.",
      "timer": 60,
      "sips": [{ "amount": 1, "condition": "Todos toman", "target": "ALL" }]
    },
    {
      "id": 301,
      "title": "Primer Amor",
      "story": "Recordar es volver a vivir.",
      "action": "¿Quién fue tu primer beso y qué nota le ponís? Si no respondís, tomai 3 po.",
      "sips": [{ "amount": 3, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 302,
      "title": "Confesión Vergonzosa",
      "story": "Los espíritus lo ven todo.",
      "action": "Confiesa la weá más vergonzosa que hai hecho a escondidas. Si no respondís, tomai 5 sorbos al seco.",
      "sips": [{ "amount": 5, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 303,
      "title": "El Crush",
      "story": "Amor prohibido.",
      "action": "¿Cuál de los presentes te parece más rico/a? (Vale decir nadie, pero tomai 1). Si decís nombre, esa persona toma.",
      "sips": [
        { "amount": 1, "condition": "Si dice 'nadie'", "target": "SELF" },
        {
          "amount": 1,
          "condition": "Elegido si dice nombre",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 304,
      "title": "La Mentira",
      "story": "Confesión.",
      "action": "¿Cuál es la caña más grande que le hai metido a tus viejos? Responde o tomai po.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 305,
      "title": "Vergüenza",
      "story": "Tierra trágame.",
      "action": "Cuenta tu condoro más grande en público o tomai 3.",
      "sips": [{ "amount": 3, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 306,
      "title": "Crimen",
      "story": "Fuera de la ley.",
      "action": "¿Hai choreado algo alguna vez? ¿Qué fue? Responde o tomai po.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 307,
      "title": "Talento Oculto",
      "story": "Nadie lo cacha.",
      "action": "¿Cuál es tu talento más inútil? Demuéstralo o tomai.",
      "sips": [
        { "amount": 1, "condition": "Si no lo demuestra", "target": "SELF" }
      ]
    },
    {
      "id": 308,
      "title": "El Ex",
      "story": "Fantasmas del pasado.",
      "action": "¿Volverías con tu ex pololo/a? ¿Por qué? Responde o fondo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si no responde (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 309,
      "title": "Antipatía",
      "story": "Malas vibras.",
      "action": "¿Quién te cae como patá en la guata de este grupo? (Si es nadie, toma por sapo o da un argumento bacán).",
      "sips": [
        { "amount": 1, "condition": "Si no dice a nadie", "target": "SELF" }
      ]
    },
    {
      "id": 310,
      "title": "Higiene",
      "story": "Olores de la selva.",
      "action": "¿Cuánto es lo máximo que hai estado sin pegarte una ducha? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 311,
      "title": "Ropa Interior",
      "story": "Secretos íntimos.",
      "action": "¿De qué color son tus chores/calzones hoy? Muestra el borde o tomai 3.",
      "sips": [{ "amount": 3, "condition": "Si no muestra", "target": "SELF" }]
    },
    {
      "id": 312,
      "title": "Celos",
      "story": "Monstruo verde.",
      "action": "¿Cuál es la escena de celos más intensa que hai pegado? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 313,
      "title": "Fantasía",
      "story": "Sueños prohibidos.",
      "action": "Cuenta una fantasía que no hai cumplido (puede ser viajar, lo que sea, pero que sea bacán). O tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 314,
      "title": "Miedo",
      "story": "Terror nocturno.",
      "action": "¿A qué le tenís miedo irracionalmente? Responde o tomai po.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 315,
      "title": "El Cahuín",
      "story": "Secretos oscuros.",
      "action": "Cuenta el último cahuín que anduviste contando por ahí. Si no querís, tomai 5 sorbos al seco, sapo/a culiao/a.",
      "sips": [{ "amount": 5, "condition": "Si no cuenta", "target": "SELF" }]
    },
    {
      "id": 316,
      "title": "Lágrimas",
      "story": "Sentimientos.",
      "action": "¿Cuándo fue la última vez que lloraste y por qué? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 317,
      "title": "Arrepentimiento",
      "story": "Si pudiera volver atrás...",
      "action": "¿De qué te arrepentís más en tu vida? Algo profundo. Responde o tomai doble.",
      "sips": [{ "amount": 2, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 318,
      "title": "Apodo",
      "story": "Nombre clave.",
      "action": "¿Cuál es el apodo más ridículo que te han puesto? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 319,
      "title": "Seducción",
      "story": "Técnicas de caza.",
      "action": "¿Cuál es tu técnica pa' tirar los cagaos? Explícala o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no explica", "target": "SELF" }]
    },
    {
      "id": 320,
      "title": "Fiesta",
      "story": "Noche loca.",
      "action": "¿Qué es lo peor que hai hecho curao/curá? Responde o tomai 4.",
      "sips": [{ "amount": 4, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 321,
      "title": "Dinero",
      "story": "Codicia.",
      "action": "¿Qué harías por 1 palo verde que sea ilegal? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 322,
      "title": "Cuerpo",
      "story": "Vanidad.",
      "action": "¿Qué parte de tu cuerpo te cambiarías? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 323,
      "title": "Venganza",
      "story": "Rencor.",
      "action": "¿Te hai vengado de alguien? ¿Cómo? Responde o tomai.",
      "sips": [{ "amount": 1, "condition": "Si no responde", "target": "SELF" }]
    },
    {
      "id": 324,
      "title": "Infidelidad",
      "story": "Traición.",
      "action": "¿Hai sido infiel o te han gorreado? Cuenta la historia o tomai 5.",
      "sips": [{ "amount": 5, "condition": "Si no cuenta", "target": "SELF" }]
    },
    {
      "id": 325,
      "title": "Este Juego",
      "story": "Opinión honesta.",
      "action": "¿Qué te parece este juego hasta ahora? Si mentís, tomai po.",
      "sips": [{ "amount": 1, "condition": "Si miente", "target": "SELF" }]
    },
    {
      "id": 401,
      "title": "Marcas de Autos",
      "story": "Rugido de motores.",
      "action": "Nombra marcas de autos (Toyota, Ford...). El que repita o dude, toma al tiro.",
      "sips": [
        { "amount": 1, "condition": "Al que repita/dude", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 402,
      "title": "Marcas de Cigarros",
      "story": "Humo en la selva.",
      "action": "Nombra marcas de cigarros. El que repita o dude, toma po.",
      "sips": [
        { "amount": 1, "condition": "Al que repita/dude", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 403,
      "title": "Posiciones del Kamasutra",
      "story": "Conocimiento ancestral.",
      "action": "Nombra posiciones, cachai. El que se ría, repita o dude, toma.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que se ría/repita/dude",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 404,
      "title": "Capitales del Mundo",
      "story": "Geografía.",
      "action": "Nombra capitales del mundo. El que se mande un condoro, toma.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que se equivoque",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 405,
      "title": "Superhéroes",
      "story": "Poderes.",
      "action": "Nombra superhéroes de Marvel o DC. El que quede en blanco, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 406,
      "title": "Marcas de Cerveza",
      "story": "El elixir de la vida.",
      "action": "Nombra marcas de chela. El que repita o dude, toma un sorbo de la suya.",
      "sips": [
        { "amount": 1, "condition": "Al que repita/dude", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 407,
      "title": "Personajes de Harry Potter",
      "story": "Magia.",
      "action": "Nombra personajes de la saga. El que quede pa'l gato, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 408,
      "title": "Equipos de Fútbol",
      "story": "Pasión de multitudes.",
      "action": "Nombra equipos de fútbol internacionales. El que se mande un condoro, toma.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que se equivoque",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 409,
      "title": "Razas de Perros",
      "story": "El mejor amigo.",
      "action": "Nombra razas de perros. El que quede pegao, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 410,
      "title": "Ingredientes de Pizza",
      "story": "Comida italiana.",
      "action": "Nombra ingredientes de pizza. El que se repita o dude, toma po.",
      "sips": [
        { "amount": 1, "condition": "Al que repita/dude", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 411,
      "title": "Lenguajes de Programación",
      "story": "Código.",
      "action": "Nombra lenguajes de programación (JS, Python...). El que quede en blanco, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 412,
      "title": "Géneros Musicales",
      "story": "Ritmo.",
      "action": "Nombra estilos de música. El que se quede callao, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 413,
      "title": "Películas de Disney",
      "story": "Infancia.",
      "action": "Nombra clásicos de Disney. El que quede pa'l loli, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 414,
      "title": "Colores en Inglés",
      "story": "Bilingüe.",
      "action": "Nombra colores en inglés. El que se mande un condoro, toma.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que se equivoque",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 415,
      "title": "Partes del Cuerpo",
      "story": "Anatomía.",
      "action": "Nombra partes del cuerpo humano. El que se repita o dude, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que repita/dude", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 416,
      "title": "Frutas",
      "story": "Naturaleza.",
      "action": "Nombra tipos de frutas. El que quede pegao, toma po.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 417,
      "title": "Videojuegos",
      "story": "Gamer.",
      "action": "Nombra franquicias de videojuegos famosas. El que quede en blanco, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 418,
      "title": "Marcas de Ropa",
      "story": "Moda.",
      "action": "Nombra marcas de ropa deportiva o casual. El que se repita, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que repita", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 419,
      "title": "Copetes Chilenos",
      "story": "¡Salud de Chile!",
      "action": "Nombra tragos o copetes típicos chilenos (terremoto, piscola, jote...). El que repita o dude, toma al seco.",
      "sips": [
        {
          "amount": 5,
          "condition": "Al que repita/dude (Seco)",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 420,
      "title": "Planetas",
      "story": "Espacio exterior.",
      "action": "Nombra planetas (o ex-planetas) del sistema solar. El que se mande un condoro, toma.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que se equivoque",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 421,
      "title": "Programas de la Tele",
      "story": "Caja chica.",
      "action": "Nombra programas o series de televisión clásicos. El que se repita o quede callao, toma po.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que repita/calle",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 422,
      "title": "Cantantes de Reggaetón",
      "story": "Perreo.",
      "action": "Nombra cantantes del género urbano. El que se quede callao, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 423,
      "title": "Pokémon",
      "story": "Atrápalos a todos.",
      "action": "Nombra criaturas Pokémon. El que quede pegao, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 424,
      "title": "Verduras",
      "story": "Saludable.",
      "action": "Nombra verduras u hortalizas. El que se repita, toma po.",
      "sips": [
        { "amount": 1, "condition": "Al que repita", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 425,
      "title": "Juegos de Mesa",
      "story": "Diversión análoga.",
      "action": "Nombra juegos de mesa (Monopoly, Ludo...). El que quede en blanco, toma.",
      "sips": [
        { "amount": 1, "condition": "Al que no sepa", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 501,
      "title": "El Limón",
      "story": "Ácido como tu ex.",
      "action": "Cómete una rodaja de limón (o cucharada de vinagre) sin hacer muecas. Si hacís mueca, tomai po.",
      "sips": [{ "amount": 1, "condition": "Si hace mueca", "target": "SELF" }]
    },
    {
      "id": 502,
      "title": "Fondo Blanco",
      "story": "La sequía termina.",
      "action": "{J1} se manda todo lo que le queda en el vaso. Al seco, sin respirar weón.",
      "sips": [
        { "amount": 5, "condition": "Fondo obligatorio", "target": "SELF" }
      ]
    },
    {
      "id": 503,
      "title": "Strip Poker",
      "story": "Hace calor.",
      "action": "Sácate una prenda de ropa (zapatos y calcetines no valen po) o tomai 5 sorbos.",
      "sips": [
        { "amount": 5, "condition": "Si no se quita prenda", "target": "SELF" }
      ]
    },
    {
      "id": 504,
      "title": "Llamada Incómoda",
      "story": "Peligro social.",
      "action": "Llama a tu vieja o viejo y dile 'Estoy embarazado/a' o 'Voy a ser papá' y cuelga al tiro. Si no, fondo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si no llama (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 505,
      "title": "El Hielo",
      "story": "Frío polar.",
      "action": "Ponte un cubo de hielo dentro de la ropa (espalda o pantalón) hasta que se derrita. Si lo sacai, fondo al seco.",
      "sips": [
        {
          "amount": 5,
          "condition": "Si se saca el hielo (Fondo)",
          "target": "SELF"
        }
      ]
    },
    {
      "id": 506,
      "title": "Azotes",
      "story": "Castigo tribal.",
      "action": "Déjate dar una palmá en el poto por cada jugador de la mesa. Si te ponís choro, tomai 4.",
      "sips": [{ "amount": 4, "condition": "Si se niega", "target": "SELF" }]
    },
    {
      "id": 507,
      "title": "La Mezcla",
      "story": "Poción venenosa.",
      "action": "Cada weón vierte un poco de su copete en tu vaso. Te tomai 3 sorbos de esa mezcla asquerosa.",
      "sips": [
        { "amount": 3, "condition": "Obligatorio (Mezcla)", "target": "SELF" }
      ]
    },
    {
      "id": 508,
      "title": "La Plancha",
      "story": "Entrenamiento duro.",
      "action": "Haz la posición de plancha (plank) por 45 segundos. Si caís antes, tomai 3.",
      "timer": 45,
      "sips": [{ "amount": 3, "condition": "Si no aguanta", "target": "SELF" }]
    },
    {
      "id": 509,
      "title": "Condimento",
      "story": "Sabor intenso.",
      "action": "Cómete una cucharada de mayonesa, ketchup o ají sola. O fondo al seco, corta.",
      "sips": [
        { "amount": 5, "condition": "Si no come (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 510,
      "title": "Sin Manos 2.0",
      "story": "Invalidez temporal.",
      "action": "No podís usar las manos pa' nada hasta tu próximo turno. Si lo hacís, tomai 2 cada vez.",
      "sips": [
        { "amount": 2, "condition": "Cada vez que use manos", "target": "SELF" }
      ]
    },
    {
      "id": 511,
      "title": "A Ciegas",
      "story": "Oscuridad total.",
      "action": "Ponte una venda en los ojos hasta tu próximo turno. Si te la sacai, fondo al seco.",
      "sips": [
        {
          "amount": 5,
          "condition": "Si se saca la venda (Fondo)",
          "target": "SELF"
        }
      ]
    },
    {
      "id": 512,
      "title": "El Lienzo",
      "story": "Arte corporal.",
      "action": "Deja que el weón/weona de la derecha te dibuje un bigote o monóculo con marcador. Déjatelo todo el juego.",
      "sips": []
    },
    {
      "id": 513,
      "title": "Susurros",
      "story": "Silencio mortal.",
      "action": "Tenís que hablar susurrando hasta tu próximo turno. Si alzai la voz, tomai.",
      "sips": [{ "amount": 1, "condition": "Si alza la voz", "target": "SELF" }]
    },
    {
      "id": 514,
      "title": "El Flamenco",
      "story": "Equilibrio vital.",
      "action": "Tenís que estar parao en un solo pie hasta que te toque de nuevo. Si tocai el suelo, tomai 3.",
      "sips": [
        { "amount": 3, "condition": "Si toca el suelo", "target": "SELF" }
      ]
    },
    {
      "id": 515,
      "title": "Nombre Prohibido",
      "story": "Identidad borrada.",
      "action": "Elige un nombre. Cada vez que alguien lo diga (incluso tú), toman. Dura 3 rondas, cachai.",
      "sips": [
        {
          "amount": 1,
          "condition": "Al que diga el nombre",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 516,
      "title": "Esclavo Total",
      "story": "Servidumbre.",
      "action": "Erís el perkin del grupo por 5 minutos. Rellena vasos, trae copetito y snacks. Si alegai, tomai.",
      "timer": 300,
      "sips": [{ "amount": 1, "condition": "Si reclama", "target": "SELF" }]
    },
    {
      "id": 517,
      "title": "Brazos de T-Rex",
      "story": "Evolución regresiva.",
      "action": "Tenís que tomar con los codos pegados a las costillas (como T-Rex) por el resto del juego. Pasarlo chancho.",
      "sips": []
    },
    {
      "id": 518,
      "title": "Mareado",
      "story": "Vórtice.",
      "action": "Da 10 vueltas sobre tu eje y después intenta caminar en línea recta. Si quedai pa'l gato, tomai.",
      "sips": [{ "amount": 1, "condition": "Si marea/cae", "target": "SELF" }]
    },
    {
      "id": 519,
      "title": "Karaoke Vergonzoso",
      "story": "¡Pégate el show!",
      "action": "Párate y cántale una serenata al weón/weona de tu derecha mirándole a los ojos. Si no lo hacís, fondo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si no canta (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 520,
      "title": "Cambio de Camisa",
      "story": "Trueque.",
      "action": "Intercambia tu camiseta con la persona de tu izquierda. Si no quieren, ambos toman 3 po.",
      "sips": [
        { "amount": 3, "condition": "Ambos si se niegan", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 521,
      "title": "Ráfaga",
      "story": "Ametralladora.",
      "action": "Tómate 5 sorbos chicos seguidos lo más rápido posible. ¡Al seco po!",
      "sips": [{ "amount": 5, "condition": "Obligatorio", "target": "SELF" }]
    },
    {
      "id": 522,
      "title": "Verdad o Dolor",
      "story": "Ultimátum.",
      "action": "El grupo te hace una pregunta MUY íntima. Si no respondís, te comís un coscacho de la persona que elijai.",
      "sips": []
    },
    {
      "id": 523,
      "title": "Limpieza",
      "story": "Humillación.",
      "action": "Lame la mesa (un pedacito no más) o fondo al seco.",
      "sips": [
        { "amount": 5, "condition": "Si no lame (Fondo)", "target": "SELF" }
      ]
    },
    {
      "id": 524,
      "title": "Fetiche",
      "story": "Olores.",
      "action": "Huele la pata (con o sin calcetín) del jugador de tu derecha o tomai 4 sorbos. Mala cueva.",
      "sips": [{ "amount": 4, "condition": "Si se niega", "target": "SELF" }]
    },
    {
      "id": 525,
      "title": "Suelo de Lava",
      "story": "Extremo.",
      "action": "No podís tocar el suelo hasta tu próximo turno. Súbete a la silla o sillón. Si tocai suelo, tomai po.",
      "sips": [{ "amount": 1, "condition": "Si toca suelo", "target": "SELF" }]
    }
  ],
  "all": [
    {
      "id": 201,
      "title": "Brindis por el Líder",
      "story": "Saludamos al jefe de la tribu.",
      "action": "Todos brindan y toman por {J1}. ¡Salud po!",
      "sips": [{ "amount": 1, "condition": "Todos toman", "target": "ALL" }]
    },
    {
      "id": 202,
      "title": "La Cascada",
      "story": "El río fluye sin parar.",
      "action": "Todos empiezan a tomar a la vez. Nadie para hasta que pare el de su derecha. Empieza {J1}. ¡Al seco!",
      "sips": [
        {
          "amount": 5,
          "condition": "Todos (Variable según aguante)",
          "target": "ALL"
        }
      ]
    },
    {
      "id": 203,
      "title": "Hidratación",
      "story": "El calor está asqueroso.",
      "action": "Todos se mandan 2 sorbos grandes de copete (o agua pa' los débiles) pa' seguir vivos.",
      "sips": [{ "amount": 2, "condition": "Todos toman", "target": "ALL" }]
    },
    {
      "id": 204,
      "title": "Compañeros de Viaje",
      "story": "No estái solo en esto.",
      "action": "{J1} elige a un compinche. Cada vez que {J1} tome, el compinche también toma (dura 3 turnos). Así se comparte la caña.",
      "sips": [
        {
          "amount": 1,
          "condition": "Compinche toma cuando {J1} toma",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 205,
      "title": "Tribu de Bajitos",
      "story": "Solo los peques caben en la cueva.",
      "action": "El jugador más petiso del grupo reparte 3 sorbos. ¡Manda tú po!",
      "sips": [
        {
          "amount": 3,
          "condition": "Reparte el más bajo",
          "target": "DISTRIBUTE"
        }
      ]
    },
    {
      "id": 206,
      "title": "Tribu de Gigantes",
      "story": "Alcanzai los frutos más altos.",
      "action": "El jugador más alto del grupo reparte 3 sorbos a los demás.",
      "sips": [
        {
          "amount": 3,
          "condition": "Reparte el más alto",
          "target": "DISTRIBUTE"
        }
      ]
    },
    {
      "id": 207,
      "title": "Dios de la Lluvia",
      "story": "Tus plegarias fueron escuchadas.",
      "action": "{J1} reparte 5 sorbos entre los weones como quiera. ¡A discreción!",
      "sips": [
        { "amount": 5, "condition": "Reparte {J1}", "target": "DISTRIBUTE" }
      ]
    },
    {
      "id": 208,
      "title": "La Ronda",
      "story": "Un círculo de protección.",
      "action": "Brindis cruzado. Choca tu vaso con todos sin cruzar los brazos. El último en lograrlo toma doble, corta.",
      "sips": [{ "amount": 2, "condition": "Al último", "target": "SPECIFIC" }]
    },
    {
      "id": 209,
      "title": "Medusa Inversa",
      "story": "No me mirís.",
      "action": "A la cuenta de 3, todos miran a alguien. Si cruzai mirada con alguien, ambos gritan '¡Medusa!' y toman.",
      "sips": [
        {
          "amount": 1,
          "condition": "A los que crucen mirada",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 210,
      "title": "Inmunidad",
      "story": "Encontraste un amuleto.",
      "action": "Te ganaste una tarjeta de 'Salvarse de Tomar'. Úsala cuando querái. (Un solo uso, no seai rata).",
      "sips": []
    },
    {
      "id": 211,
      "title": "El Bufón",
      "story": "Nos hiciste cagar de la risa.",
      "action": "Si {J1} ha hecho reír a alguien en los últimos 5 minutos, reparte 2 sorbos. Si no, toma 2 por fome.",
      "sips": [
        {
          "amount": 2,
          "condition": "Si hizo reír (Reparte)",
          "target": "DISTRIBUTE"
        },
        { "amount": 2, "condition": "Si fue fome (Toma)", "target": "SELF" }
      ]
    },
    {
      "id": 212,
      "title": "Rubias vs Morenas",
      "story": "Guerra de clanes.",
      "action": "Los que tienen pelo oscuro toman 1. Los que tienen pelo claro toman 2. Así es la vida po.",
      "sips": [
        { "amount": 1, "condition": "Pelo oscuro", "target": "SPECIFIC" },
        { "amount": 2, "condition": "Pelo claro", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 213,
      "title": "Cuatro Ojos",
      "story": "Visión mejorada.",
      "action": "Todos los que usen lentes (o lentes de contacto si confiesan) toman 2 sorbos.",
      "sips": [
        {
          "amount": 2,
          "condition": "Los que usan lentes",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 214,
      "title": "Solteros vs Pololeando",
      "story": "Estado civil.",
      "action": "Los solteros toman por su libertad. Los que tienen pololo/a toman por su condena (o felicidad, cachai).",
      "sips": [
        { "amount": 1, "condition": "Solteros", "target": "SPECIFIC" },
        { "amount": 1, "condition": "Con pololo/a", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 215,
      "title": "Sin Manos",
      "story": "Los brazos están entumecidos.",
      "action": "Todos deben tomar un sorbo sin usar las manos (vaso en la mesa o con los codos). El que derrame, toma doble.",
      "sips": [
        { "amount": 1, "condition": "Todos (Sin manos)", "target": "ALL" },
        { "amount": 2, "condition": "Si derrama", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 216,
      "title": "La Foto",
      "story": "Recuerdo grupal.",
      "action": "El que salga peor en la última foto de la galería de {J1} toma 3 sorbos. Mala cueva.",
      "sips": [
        { "amount": 3, "condition": "El que salga peor", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 217,
      "title": "Cumpleaños",
      "story": "Celebramos la vida.",
      "action": "El que tenga el cumpleaños más cercano (pasado o futuro) toma 3 sorbos. ¡Feliz cumple po!",
      "sips": [
        {
          "amount": 3,
          "condition": "Cumpleañero cercano",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 218,
      "title": "Duelo de Tallas",
      "story": "A ver quién es más chistoso.",
      "action": "{J1} y {J2} se tiran una talla cada uno. El grupo vota cuál fue más buena. El que pierde toma 3. Si empatan, toman los dos.",
      "sips": [
        {
          "amount": 3,
          "condition": "Al perdedor (o ambos si empate)",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 219,
      "title": "Monedas y Llaves",
      "story": "¿Qué llevai en los bolsillos?",
      "action": "El que tenga más monedas (o llaves) en los bolsillos reparte 3 sorbos. El que no tenga nada, toma 2 por andar livianito.",
      "sips": [
        {
          "amount": 3,
          "condition": "El con más cosas (Reparte)",
          "target": "DISTRIBUTE"
        },
        { "amount": 2, "condition": "El sin nada (Toma)", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 220,
      "title": "Aventurero Novato",
      "story": "El último en llegar.",
      "action": "El último weón que llegó a la fiesta hoy toma 3 sorbos. Por atrasao.",
      "sips": [
        {
          "amount": 3,
          "condition": "El último en llegar",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 221,
      "title": "El Vestido",
      "story": "Código de vestimenta.",
      "action": "El que lleve más colores en su ropa toma. Por llamativo po.",
      "sips": [
        { "amount": 1, "condition": "El con más colores", "target": "SPECIFIC" }
      ]
    },
    {
      "id": 222,
      "title": "Titanic",
      "story": "El barco se hunde.",
      "action": "Todos se toman lo que les queda en el vaso. (Si es mucho, negociar a 5 sorbos, no sean chantas).",
      "sips": [
        { "amount": 5, "condition": "Todos (Resto del vaso)", "target": "ALL" }
      ]
    },
    {
      "id": 223,
      "title": "El Francotirador",
      "story": "Tenís puntería.",
      "action": "{J1} simula disparar a alguien. Esa persona toma y 'dispara' a otro. Hasta que alguien quede pa'l gato o se niegue.",
      "sips": [
        {
          "amount": 1,
          "condition": "Cada victima toma 1",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 224,
      "title": "Zurdo",
      "story": "Mano cambiada.",
      "action": "Todos deben tomar con la mano izquierda (o la no dominante) el resto del juego. Quien use la derecha, toma penalización, cachai.",
      "sips": [
        {
          "amount": 1,
          "condition": "Penalización por mano derecha",
          "target": "SPECIFIC"
        }
      ]
    },
    {
      "id": 225,
      "title": "Aguas Termales",
      "story": "Relajación.",
      "action": "Todos masajean los hombros del weón/weona de su derecha y se mandan un trago de placer. Pasándola chancho.",
      "sips": [{ "amount": 1, "condition": "Todos toman", "target": "ALL" }]
    },
    {
      "id": 109,
      "title": "El Piso es Lava",
      "story": "¡El volcán entró en erupción!",
      "action": "El último weón en subirse a una silla o sofá toma 3 sorbos. (Cuenta hasta 5, ¡muévanse po!).",
      "timer": 5,
      "sips": [
        { "amount": 3, "condition": "El último en subir", "target": "SPECIFIC" }
      ]
    }
  ]
}
```
