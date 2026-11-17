# Contribuir

Modifica el generador y sus pruebas, no hashes publicados a mano. Usa tags
exactos, firma verificada de SHA256SUMS y ambos ejecutables de cada arquitectura.
Ejecuta `python3 -B tools/test_update.py` y pruebas Homebrew nativas.

No añadas mirrors, omitas verificaciones, ejecutes un binario antes de comprobarlo
ni introduzcas tokens de producción. Solo se actualiza tras las pruebas y la
comprobación optimista de main; una release incompleta deja la fórmula intacta.

El código del producto va en [IRMind](https://github.com/ns2switch/irmind) y las
metodologías en [irmind-skills](https://github.com/ns2switch/irmind-skills).
