# AttackEntry02 — falsificación C2 de `corpus/knowledge/adjacency-scope.md`

Asiento: `KagiR22.AttackEntry02` (revisor, hoja). Ejes: **calibración y frescura**.
Entrada asignada: `corpus/knowledge/adjacency-scope.md` (c2cab35 como BEFORE histórico; árbol bajo ataque congelado por `integration-manifest.json`).

## Identidades observadas

| fuente | valor |
|---|---|
| Árbol actual | `d61751014d4bb7e19d6420140771e55cce31df589148bb21cb6ad4570a96bbf2` · 325 líneas · 22.717 bytes |
| Manifest (entrada congelada, mismo path) | `d6175101…bbf2` · 325 líneas · 22.717 bytes → **idéntico al árbol actual** |
| BEFORE histórico (commit c2cab35) | `45ced1ed96ff888d71b392ba40357d02e20ed0c2e1d005e9d943374d8d5c0284` · 312 líneas · 21.973 bytes (coincide con lo registrado en `build/Entry02.md`) |
| HEAD leído | `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (landing round-22, "feature-bound review capability and audited revision repairs") |
| Fila en `corpus/stamps.tsv` actual (línea 12) | `corpus/knowledge/adjacency-scope.md<TAB>d6175101…bbf2<TAB>325<TAB>22717` |
| Fila en stamps en `8ada17a` | idéntica a la actual |
| Not in `before.json` stale_stamps | correcto: la lista de 6 no incluye este path |

## Prefijo sin cambios — prueba

`sha256` de los primeros 21.200 bytes: BEFORE (`bc1af88:…`) y árbol actual → **`e80e0a1c2346c69269838f8756aaaaa305dbaae5cd0fe29885b97914a849002b` en ambos**. 21.200 ≥ 21.973 − 15 líneas añadidas × ~50 bytes promedio, y `git diff bc1af88 -- <path>` muestra **2 líneas eliminadas**: el encabezado `---` y la línea de contenido `-  run tripped over.` (división de la línea 311 por el salto de la nueva sección; su texto reaparece intacto como `> falsify\`'s first / >   run tripped over.`). **Cero contenido original fue modificado o eliminado.** El delta completo es el apéndice de líneas 314–325.

## Edición identificada — erratum anexo, sin lavado

Sección anexada: `## Erratum (round 22 — historical host counts and resolver)`, comienza tras línea en blanco tras el último bullet original y termina sin newline final (mismo estilo que el original). Cubre los 6 defectos del audit de build (F1–F6):

1. F1 (base `lane:` `~/projects` inexistente) → "resolves sibling lanes from its script-derived fleet parent, not lowercase `~/projects/shokunin`" ✓
2. F2 ("Current gates:" presentado como vigente) → "the CLEAN output … describe the recorded 2026-09-29 observation, not this host now" ✓
3. F3 (conteos de children en presente) → encabezado "historical host counts" + "before using any old host count" ✓
4. F4 (reverify con substrate ausente) → "Substrate deferral is not a new pass" + recheck condicionado al retorno del substrate ✓
5. F5 (anclas README:76/:161 muertas) → "Historical README line anchors are not current locators" ✓
6. F6 (conteo de casos del selftest) → "The selftest's helper-call count is not its entire case count" ✓

Ninguna lectura falsa queda sin marcar; el texto original se conserva íntegro y el erratum lo reclasifica como histórico sin borrarlo ni revalidarlo por hash. Provenance exacta vía `build/Entry02.md`, que contiene el hash viejo `45ced1ed…`, los contadores y la tabla de evidencia. No hay fila nueva en claim-ledger ni cambio de vocabulario.

## Frescura del puntero (distinción)

- **Puntero (stamps.tsv): íntegro y sincronizado.** La fila fue re-pinada en el mismo commit del landing `8ada17a` con el hash/bytes/líneas actuales; `git log -S` muestra solo introducción (`8a6ec16`) + re-pin (`8ada17a`), sin eliminaciones. No es uno de los 6 stale de `before.json`.
- **Hechos de fuente: no disponibles / no afirmados.** El erratum no ejecuta el gate ni reclama CLEAN actual; declara deferral explícita y condiciona el recheck a la vuelta del substrate. Los conteos de host de 2026-09-29 quedan históricos. Correcto: un hash fresco no convierte hechos históricos en actuales (QM14).
- Los registros de migración (`historical-migrations.json`: sin `deleted_stamps`, 1 fila de claim reescrita; `historical-correction-pins.json`: 9 `changed_stamp_records`, 0 `removed_members`) no incluyen este path — coherente, porque aquí el cambio es la propia corrección anexa del landing con re-pin atómico, no una migración de expectativa pendiente.

## Veredicto de admisibilidad

**ADMISIBLE.** El cambio es append-only verificado (prefijo de 21.200 bytes idéntico por hash), el erratum marca todas las lecturas falsas detectadas por el asiento de build sin reescribir historia ni restampar para "fabricar" frescura, y el re-pin del stamp ocurrió atómicamente con la corrección en el landing `8ada17a`. Sin lavado, sin deleción silenciosa, sin reclamos de hechos de fuente no observados.

## Límites y verificación residual (para el padre)

- No se ejecutaron gates en vivo (scope-gate, claim-ledger verify/docs, selftest/falsify) — prohibido en esta ola.
- No se re-midieron conteos de host; el erratum no los afirma como actuales.
- Rerun del revision-audit: única vez, a cargo del padre (este asiento solo analizó esta entrada).
- Checks que el padre puede correr tras integración: `git diff bc1af88 -- corpus/knowledge/adjacency-scope.md` (solo adiciones), igualdad fila stamp↔bytes, `claim-ledger.sh docs` (`unpinned=0`).

Sin instalaciones. Sin escrituras en producción ni en estado de lanes ajenas.
