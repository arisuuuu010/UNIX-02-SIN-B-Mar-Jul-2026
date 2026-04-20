# EVALUACIÓN PRÁCTICA — Versión 1 (Grupo 1)
### Proyecto: `nebula` | Usuario adicional: `aurora` | Duración: 40 min

---

## INSTRUCCIONES GENERALES

### Recursos permitidos
- Terminal Linux (Codespaces), `man`, páginas de internet, herramientas de IA
- **PROHIBIDO**: comunicación con compañeros, compartir pantalla o soluciones

### Sistema de calificación

| Resultado | Símbolo | Puntaje |
|-----------|---------|---------|
| Respuesta correcta | ✅ | `+P` puntos |
| Intento incorrecto | ❌ | `-P/2` puntos |
| Sin respuesta / sin cambio | ⬜ | `0` puntos |

> El script detecta automáticamente si hubo un **intento fallido** comparando
> el estado actual contra el estado inicial roto. Si no tocas algo, no se descuenta.

### Flujo de trabajo obligatorio

```bash
# 1. Resuelve cada problema y haz UN COMMIT por problema (puede ser usada la interfaz gráfica o los comandos):
git add .
git commit -m "Fix problema 1: <descripción breve>"
```
---

## PROBLEMAS A RESOLVER

> **Hay 10 fallos distribuidos en 8 problemas (13 sub-verificaciones, total 10 puntos).**
> El enunciado indica cuántos fallos hay en cada problema.
> Se penaliza el intento incorrecto con `-P/2`. Si no tocas algo, recibes `0`.

---

### Problema 1 — Estructura de directorios · **(1.5 pts máx · 2 fallos)**

Dentro de `nebula/` hay **exactamente 2 errores** relacionados con directorios:

- Hay un directorio con **nombre incorrecto**; el nombre correcto es `bitacoras`.
  Renómbralo (no lo borres y crees uno nuevo: el contenido debe moverse con él).
- Falta un directorio que **debería existir**: `borradores`.

```bash
git add .
git commit -m "Fix problema 1: estructura de directorios corregida"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 1a. `bitacoras` existe y `registros` no | +0.75 | -0.25 | 0 |
| 1b. `borradores` existe | +0.75 | — | 0 |

---

### Problema 2 — Archivos mal ubicados y renombrados · **(1 pt máx · 2 fallos)**

Dentro de `nebula/` hay **exactamente 2 errores** de nombre o ubicación de archivos:

- Un archivo de texto con datos de telemetría está en la **ubicación incorrecta**;
  debería estar dentro de `bitacoras/`. Muévelo (no lo copies).
- Un archivo de configuración tiene **extensión incorrecta** (`.bak`);
  su nombre correcto es `estrella.conf`.

```bash
git add .
git commit -m "Fix problema 2: archivos movidos y renombrados"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 2a. `cosmos.txt` en `bitacoras/` (movido, no copiado) | +0.50 | -0.25 | 0 |
| 2b. `estrella.conf` existe, `estrella.bak` no | +0.50 | -0.25 | 0 |

---

### Problema 3 — Permisos numéricos con `chmod` · **(1 pt máx · 1 fallo)**

El archivo `cosmos.txt` (ahora en `bitacoras/`) tiene **un fallo de permisos**.
Sus permisos actuales son demasiado permisivos. Los permisos correctos son:

- **Dueño**: lectura y escritura
- **Grupo**: solo lectura
- **Otros**: ningún permiso

Aplica el permiso correcto usando **notación numérica (octal)**.

```bash
git add .
git commit -m "Fix problema 3: permisos numericos 640 en cosmos.txt"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 3. `cosmos.txt` tiene exactamente permisos `640` | +1.00 | -0.50 | 0 |

---

### Problema 4 — Permisos simbólicos con `chmod` · **(1 pt máx · 2 fallos)**

Hay **2 fallos** que deben corregirse usando **notación simbólica** (`u+x`, `o-w`, etc.):

- `galaxia.sh` no tiene permiso de ejecución para su **dueño**. Añádelo.
- `estrella.conf` tiene permiso de **escritura para `others`**. Quítalo.

> ⚠️ Usa solo notación simbólica. No uses números para este problema.

```bash
git add .
git commit -m "Fix problema 4: permisos simbolicos corregidos"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 4a. `galaxia.sh` tiene bit `u+x` | +0.50 | -0.25 | 0 |
| 4b. `estrella.conf` no tiene bit `o+w` | +0.50 | -0.25 | 0 |

---

### Problema 5 — Bit SUID · **(1 pt máx · 1 fallo)**

`galaxia.sh` debe ejecutarse siempre con los privilegios del **dueño del archivo**,
independientemente de quién lo invoque. Hay **1 fallo** de permisos especiales.

Activa el bit **SUID** en `galaxia.sh`.
Verifica con `ls -l` que la posición de ejecución del dueño muestre `s`.

> ⚠️ Nota académica: el SUID en scripts de shell tiene restricciones en Linux moderno,
> pero el ejercicio evalúa que sepas aplicar el bit correctamente.

```bash
git add .
git commit -m "Fix problema 5: SUID activado en galaxia.sh"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 5. `galaxia.sh` tiene bit SUID activo | +1.00 | -0.50 | 0 |

---

### Problema 6 — Sticky bit · **(1 pt máx · 1 fallo)**

El directorio `/tmp/nebula_zone` es un espacio compartido entre usuarios.
Tiene **1 fallo**: le falta el **sticky bit**, lo que permite que cualquier usuario
elimine archivos ajenos.

Activa el sticky bit. Verifica con `ls -ld /tmp/nebula_zone` que aparezca `t`
al final de los permisos (ejemplo: `drwxrwxrwt`).

> Nota: `/tmp/nebula_zone` no vive en el repositorio git, pero el verificador lo comprueba.

```bash
git add .
git commit -m "Fix problema 6: sticky bit en /tmp/nebula_zone"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 6. `/tmp/nebula_zone` tiene sticky bit | +1.00 | -0.50 | 0 |

---

### Problema 7 — GPG: generación de llaves y cifrado · **(1.5 pts máx)**

**7a. Genera un par de llaves GPG** para:
- Nombre real: `aurora`
- Email: `aurora@nebula.lab`
- **Sin passphrase** (presiona Enter dos veces cuando te la pida,
  o usa el método batch del Apéndice A al final del enunciado)

**7b. Cifra** `nebula/bitacoras/cosmos.txt` usando esa llave pública.
El archivo cifrado debe llamarse `cosmos.txt.gpg` en la misma carpeta.

> 💡 Usa `--encrypt --recipient aurora@nebula.lab`, no `--symmetric`.

```bash
git add .
git commit -m "Fix problema 7: llave GPG generada y cosmos.txt cifrado"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 7a. Llave `aurora@nebula.lab` en el llavero | +0.50 | — | 0 |
| 7b. `cosmos.txt.gpg` cifrado asimétricamente | +1.00 | -0.50 | 0 |

---

### Problema 8 — GPG: firmas digitales · **(2 pts máx · 2 fallos detectables)**

**8a. Firma `estrella.conf` con `--clearsign`.**
El archivo firmado debe llamarse `estrella.conf.asc` y quedar en `nebula/`.

**8b. Detecta y corrige la firma corrompida de `galaxia.sh`.**
El archivo `nebula/galaxia.sh.sig` existe pero su firma fue **alterada intencionalmente**.
Verifica el fallo con:

```bash
gpg --verify nebula/galaxia.sh.sig nebula/galaxia.sh
# Debe mostrar: BAD signature
```

Luego **re-firma** `galaxia.sh` usando `--detach-sign`, sobreescribiendo el `.sig` corrupto.
La nueva firma debe quedar como `nebula/galaxia.sh.sig`.

> 💡 Usa tu propia llave (la creada en el problema 7) para ambas firmas.

```bash
git add .
git commit -m "Fix problema 8: firmas GPG corregidas y creadas"
```

| Sub-check | Correcto | Intento fallido | Sin respuesta |
|-----------|----------|-----------------|---------------|
| 8a. `estrella.conf.asc` con firma clearsign válida | +1.00 | -0.50 | 0 |
| 8b. `galaxia.sh.sig` con firma detached válida | +1.00 | 0 | 0 |

> `galaxia.sh.sig` eliminado sin re-firmar cuenta como intento fallido: `-0.50`.

---
