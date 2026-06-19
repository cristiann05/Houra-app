# Houra — Pack de marca

Color de acento **Lima `#C4F042`** · tinta oscura `#0C1005` · menta `#7DD3A8` · fondo `#0A0C0A`
Tipografía: **Space Grotesk** (700 display) · cuerpo Space Grotesk · mono JetBrains Mono

## Carpetas
- `/` (raíz) → **SVG** vectoriales (escalan sin perder calidad — úsalos siempre que puedas)
- `/png` → **PNG** con transparencia, listos para Android/iOS/web
- `/jpg` → **JPG** (sin transparencia, fondo sólido) por si algún sitio te lo pide
- `/iconos` → 25 iconos de interfaz en SVG (trazo 2px, `currentColor`)

## Qué archivo usar

### Icono de app
| Archivo | Para qué |
|---|---|
| `svg/houra-appicon-1024.svg` | fuente vectorial editable |
| `png/houra-appicon-512.png` | **Play Store** (icono 512×512) |
| `png/houra-appicon-192.png` | Android `xxxhdpi` / PWA |
| `png/houra-appicon-180.png` | iOS app icon (@3x) |
| `png/houra-appicon-144/96/72/48.png` | densidades Android (xxhdpi…mdpi) |
| `jpg/houra-appicon-1024.jpg` | si necesitas JPG (sin transparencia) |

### Logo
| Archivo | Para qué |
|---|---|
| `houra-logo-horizontal.svg` | logo + texto (fondo transparente) |
| `png/houra-logo-horizontal.png` | logo sobre transparente (cabeceras claras) |
| `png/houra-logo-horizontal-dark.png` | logo sobre fondo oscuro de marca |
| `houra-logomark.svg` / `png/houra-logomark-512.png` | solo la marca (avatar, favicon) |

## Notas
- Los iconos de interfaz usan `currentColor`: les pones el color por CSS (`color: #C4F042`).
- El logo en SVG lleva el texto en Space Grotesk; si lo abres en una herramienta sin esa fuente, conviértelo a contornos. Los PNG ya lo llevan rasterizado.
- Para generar otros tamaños, parte siempre del SVG.
