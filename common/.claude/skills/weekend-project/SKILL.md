---
name: weekend-project
description: Captura lo investigado o discutido en la conversación actual como un documento de "weekend project" en ~/Projects/@mariocesar/Weekends — un punto de re-entrada en español idiomático que permite retomar la idea en frío meses después. Úsalo siempre que el usuario diga "guárdalo para el finde", "weekend project", "proyecto de fin de semana", "apunta esto para después", "quiero volver a esto", "para que no se me olvide", "save this so I can work on it later", o cuando acabe de terminar una investigación, comparativa o exploración técnica y quiera conservar el contexto para trabajar en ella más tarde. También aplica cuando pida actualizar, revisar o retomar un weekend project que ya existe.
---

# Weekend project

Convierte lo que ya se estableció en esta conversación en un documento que
permita retomar la idea **en frío**, meses después, sin volver a derivar nada.

## Para quién escribes

El lector es el usuario dentro de tres meses, que **ha olvidado la conversación
entera**. No recuerda qué se verificó y qué se supuso, ni por qué descartasteis
una opción, ni cuál era el siguiente paso obvio.

Esto no es un resumen. Un resumen comprime lo que pasó; esto reconstruye el
estado mental necesario para seguir trabajando. La diferencia es práctica: un
resumen te deja diciendo «ah sí, esto», y el documento correcto te deja
abriendo la terminal.

De ahí salen las tres cosas que hacen bueno a un documento así:

1. **Nada que ya se derivó se vuelve a derivar.** Specs, versiones, comandos,
   precios, límites, formas de una API: si costó averiguarlo, se copia.
2. **El siguiente paso es ejecutable, no aspiracional.** «Investigar las
   alternativas» no sirve; «`git log -p --since='1 month ago' | wc -c`, media
   hora, si sale por debajo de 200k tokens el troceado sobra» sí.
3. **Lo que sabes y lo que supones no se confunden nunca.** Dentro de tres meses
   no distinguirás tu propia aritmética de un benchmark medido, y actuar sobre
   la equivocada te cuesta el fin de semana entero.

## Antes de escribir

**Fecha real.** Ejecuta `date +%Y-%m-%d`. Las fechas van absolutas, nunca
relativas — «hace tres días» es inútil dentro de tres meses.

**Ubicación.** Por defecto `~/Projects/@mariocesar/Weekends/` (créala si no
existe). Si el usuario nombra otra ruta, o si la idea pertenece claramente a un
proyecto que ya tiene su sitio, usa esa.

**Nombre del fichero.** kebab-case, descriptivo del tema, sin prefijo de fecha:
`qwen3.8-27b-local-m5-pro.md`, `django-ltree-materialized-paths.md`. Se busca por
tema, no por cuándo lo escribiste.

**Idioma.** Prosa en español idiomático; identificadores, comandos, nombres de
producto y rutas en inglés. Escribe español que suene a persona, no a traducción
del inglés.

**Si ya existe un documento sobre el tema**, edítalo en vez de crear otro: mueve
lo superado a su sitio, integra lo nuevo donde corresponde, y actualiza `Estado`
y fecha. Un hallazgo que invalida un cálculo anterior se arregla **en el
cálculo**, no se añade como nota suelta al final — si no, el documento acaba
contradiciéndose y no sabrás qué parte creer.

## La estructura

Columna vertebral. El cuerpo central se adapta al tema — una comparativa lleva
tablas, una idea de producto lleva el problema y a quién le duele, una técnica
lleva el mecanismo. Las secciones de los extremos casi siempre se ganan su sitio.

```markdown
# <Título: la cosa, no la pregunta>

> **Estado:** <en qué punto está: idea cruda sin investigar / investigado sin implementar / prototipo a medias / bloqueado por X>
> **Fecha:** <YYYY-MM-DD>
> **Veredicto corto:** <una frase; la conclusión, no el suspense>

---

## Por qué existe esta nota

<De dónde salió la idea y qué la hizo interesante. Si hubo una sorpresa —algo
que resultó no ser lo que parecía— cuéntala aquí: es lo primero que se olvida
y lo que más confunde al releer.>

## El contexto que no quiero volver a derivar

<Los hechos que costó establecer: specs, versiones, límites, precios, cómo se
llama realmente la cosa. Tabla si son más de tres.>

## <Cuerpo — tantas secciones como pida el tema>

<La sustancia. Números con sus unidades. Tablas para comparar opciones.>

## Qué podría matar esto

<El mejor argumento en contra, y el eslabón más débil de la tesis. Ver abajo.>

## Por dónde empezar

<Plan numerado y falsable. Ver abajo.>

## Preguntas abiertas

<Lo que quedó sin resolver, ordenado por interés. Una línea cada una.>

## Lo descartado y la caducidad

<Callejones ya explorados, y a partir de cuándo habría que reverificar.>

## Fuentes

<Primarias primero. Marca las obsoletas o desmentidas y por qué.>
```

## Las dos secciones que más se agradecen al volver

### Qué podría matar esto

Cuando vuelves a una idea tuya después de meses, vuelves enamorado de ella: el
documento la vendió y no queda nadie que la discuta. Un párrafo escrito cuando
todavía tenías el tema fresco —el mejor argumento en contra, o la parte de la
tesis que peor aguanta— es lo que evita gastar un sábado en algo que ya sabías
que no iba a funcionar.

Búscalo de verdad, aunque la conversación no lo haya planteado. Si la idea es
«el diff no miente y los mensajes de commit sí», el contraargumento es que el
diff dice *qué* cambió pero no *por qué*, y que un renombrado masivo puede
parecer un arreglo de seguridad. Ese tipo de objeción.

Si de verdad no encuentras ninguna, dilo — también es información.

### Por dónde empezar

Un plan numerado, no una intención. Cada paso lleva tres cosas:

1. **Qué haces**, concreto y con comandos copiables si los hay.
2. **Cuánto cuesta**, en órdenes de magnitud (media hora, una tarde).
3. **Qué resultado lo confirma o lo mata.** Esto es lo que lo hace útil: un paso
   sin criterio de parada se convierte en un sábado entero de trastear.

Pon primero lo que puede matar el proyecto barato. Media hora buscando si ya
existe vale más que una tarde escribiendo el prototipo de algo que ya existe.

## Cómo se marca lo que no sabes

**Un solo sitio: junto a la afirmación.** Cuando algo no se verificó, se marca
donde aparece, no en una lista al final:

```markdown
> ❓ **Sin verificar:** <lo que no se comprobó>. Comprobar con <cómo>.
```

Las *Preguntas abiertas* recogen esos huecos en una línea cada uno y siguen
adelante; no repiten el razonamiento que ya está arriba. Escribir la misma duda
en tres sitios distintos —marca, sección de fiabilidad, preguntas abiertas— es
la forma más fácil de hinchar el documento sin añadir nada.

Etiqueta el **origen** de cada número importante donde lo escribes, en tres
palabras: `medido`, `según su web`, `cálculo mío, sin medir`. Eso hace
innecesaria una sección aparte de fiabilidad y evita la confusión que de verdad
duele al releer.

**No rellenes huecos con conocimiento general que suene plausible.** Es lo que
envenena el documento, porque dentro de tres meses parecerá tan verificado como
el resto. Si el usuario dice que no habéis mirado la competencia, no nombres
competidores; si no habéis mirado el coste, no des cifras. Un hueco honesto es
una pregunta abierta más; un hueco rellenado a ojo es una trampa.

## Una medición agregada no se atribuye a la parte interesante

Cuando un número mide varias cosas a la vez, dilo en vez de asignárselo a la
causa más llamativa. Si el usuario observa 18,7 GB residentes en un proceso que
carga 16,08 GB de pesos, el delta incluye lo que le interese *y* el overhead del
runtime; escribir «la torre de visión ocupa 2,6 GB» inventa una precisión que la
medición no tiene.

La forma correcta es nombrar lo que el número contiene: «2,6 GB por encima de
los pesos, que incluye la torre de visión y el overhead del runtime, sin
separar». Cuesta media línea y evita construir encima de un dato falso.

## Extensión

Tan corto como permita retomar el trabajo. La medida no es la exhaustividad sino
si el sábado por la mañana puedes empezar: si un párrafo no cambia lo que harías,
sobra. La fuente de bulto más común es decir lo mismo en dos secciones distintas.

## Cierra el círculo

Añade una línea al índice en `<carpeta>/README.md` (créalo si no existe):

```markdown
- [Título](fichero.md) — <gancho de una línea> · <estado> · <YYYY-MM-DD>
```

Sin el índice, la carpeta se vuelve un cementerio de ficheros a los tres o cuatro
documentos. Con él, es una lista de cosas que podrías hacer este sábado.

## Al terminar

Dile al usuario dónde quedó el fichero y, en dos o tres líneas, qué contiene y
cuál es el primer experimento que harías. Esa última frase es la que hace que el
documento se abra el sábado en vez de quedarse en la carpeta.
