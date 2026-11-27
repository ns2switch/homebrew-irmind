# Tap Homebrew de IRMind

Binarios publicados de [IRMind](https://github.com/ns2switch/irmind) y su auxiliar
EVTX aislado. Licencia MIT OR Apache-2.0. [English](README.md).

## Instalar, actualizar y desinstalar

Con Homebrew ya instalado:

```sh
brew install ns2switch/irmind/irmind
irmind --version
irmind demo
brew upgrade ns2switch/irmind/irmind
brew uninstall ns2switch/irmind/irmind
```

La fórmula elige assets separados de macOS arm64, macOS Intel, Linux x86_64 o
Linux arm64. Solo descarga los dos ejecutables de la release GitHub indicada y
verifica sus SHA-256. No compila IRMind ni descarga modelos o evidencia. Actualizar
es una acción explícita de Homebrew; IRMind no se actualiza solo. Conserva los
binarios verificados de la versión creadora fuera de Homebrew antes de actualizar
si necesitas casos pre-1.0: Homebrew puede eliminar versiones antiguas y las
versiones menores de IRMind pueden cambiar formatos sin migración.

## Confianza y pruebas nativas

El actualizador autentica SHA256SUMS con cosign, fijando repositorio, workflow,
tag y emisor OIDC exactos, antes de generar la fórmula. Rechaza arquitecturas
incompletas, hashes inválidos o duplicados, recetas modificadas y retrocesos de
versión. Homebrew verifica cada descarga; el CI comprueba además los hashes de
los bytes instalados. Consulta la [verificación independiente](https://github.com/ns2switch/irmind/blob/main/docs/es/platforms.md)
y la [política de firma](https://github.com/ns2switch/irmind/blob/main/CODE_SIGNING.es.md).

El CI nativo cubre macOS arm64, macOS Intel y Linux x86_64: `brew audit --strict`,
instalación, `brew test`, versión exacta, demo en PTY 80x24 y desinstalación. El
smoke usa presentación acelerada, sale después de la primera escena y comprueba
la limpieza y la conservación de un directorio de datos preexistente. Las pruebas
de release de IRMind recorren la presentación completa.

En macOS se exige que ninguno de los ejecutables instalados tenga
`com.apple.quarantine`, sin eliminar ese atributo. La versión y la demo deben
ejecutarse sin avisos de arranque. Son comprobaciones en runners nativos sin
interfaz gráfica; no prueban Developer ID, notarización ni una descarga desde
navegador con cuarentena.

## Automatización

`update.yml` recibe la etiqueta exacta de una versión estable publicada mediante `workflow_dispatch`. IRMind lo
invoca tras publicar una etiqueta usando `HOMEBREW_TAP_TOKEN` desde su environment
protegido `release`. Ese token necesita Actions write en el tap, no publica la
fórmula. Los jobs de lectura autentican y prueban la candidata. Un job separado
publica mediante el GITHUB_TOKEN efímero del tap y una actualización atómica sin
force; después, runners nuevos instalan el tap publicado y comparan su receta.
Las PR no publican y su fórmula debe coincidir byte a byte con la receta
regenerada desde los hashes autenticados. No hay actualización programada ni
alternativa de compilación desde código.

Asigna a STABLE_TAG una etiqueta estable publicada antes de lanzar el workflow:

```sh
gh workflow run update.yml -R ns2switch/homebrew-irmind --ref main -f tag="$STABLE_TAG"
```

Desarrollo: Python 3.11+, `gh` y cosign 3.1.4 o posterior:

```sh
python3 -B tools/test_update.py
python3 tools/update.py --tag "$STABLE_TAG" --output Formula/irmind.rb
```

Véase [CONTRIBUTING](CONTRIBUTING.es.md). Nunca sustituyas los hashes por los de otra
arquitectura ni omitas la verificación de identidad.

Las versiones recientes de Homebrew pueden pedir confianza explícita antes de instalar una fórmula externa. Revisa `Formula/irmind.rb` y, si se solicita, ejecuta `brew trust --formula ns2switch/irmind/irmind`. Las pruebas nativas confían solo en esta fórmula tras autenticarla; no desactivan las comprobaciones de confianza globales.
