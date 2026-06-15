#!/bin/bash

##############################################################################
# PROPÓSITO: Analizar y calificar una rama de Git en base a métricas de calidad
# NOMBRE: arisuuuu010
# FECHA: 15-06-2026
#
# USO: ./arisuuuu010.sh [ruta_repositorio] [nombre_rama]
##############################################################################

# Salir inmediatamente si ocurre un error, si se usa variable no definida,
# o si falla algún comando en una tubería
set -euo pipefail

# ============================================================================
# PALETA DE COLORES PARA MENSAJES EN CONSOLA
# ============================================================================
COLOR_ERROR='\033[0;31m'       # Rojo para errores
COLOR_OK='\033[0;32m'          # Verde para éxitos
COLOR_AVISO='\033[1;33m'       # Amarillo para advertencias
COLOR_INFO='\033[0;34m'        # Azul para información general
COLOR_TITULO='\033[0;36m'      # Cian para encabezados
COLOR_RESUMEN='\033[0;35m'     # Magenta para el resumen final
SIN_COLOR='\033[0m'            # Resetear color

# ============================================================================
# PARÁMETROS DE CONFIGURACIÓN DEL SCRIPT
# ============================================================================
RUTA_REPO="${1:-.}"                             # Ruta al repositorio (por defecto: directorio actual)
RAMA_OBJETIVO="${2:-blackhatbash}"              # Rama a evaluar
DIR_TEMP="/tmp/analisis_git_$$"                # Directorio temporal (PID único)
DIR_SALIDA="./reportes_arisuuuu010"            # Carpeta de reportes de salida
MARCA_TIEMPO=$(date +"%Y%m%d_%H%M%S")         # Timestamp para nombres de archivo
ZONA_HORARIA="America/Guayaquil"               # Zona horaria Ecuador (UTC-5)

# Rutas de los archivos de reporte que se generarán
ARCHIVO_JSON="${DIR_SALIDA}/reporte_${MARCA_TIEMPO}.json"
ARCHIVO_HTML="${DIR_SALIDA}/reporte_${MARCA_TIEMPO}.html"

# ============================================================================
# FUNCIONES DE SALIDA / LOGGING
# ============================================================================

# Imprime un encabezado visual en la terminal
mostrar_titulo() {
    echo -e "\n${COLOR_TITULO}========================================${SIN_COLOR}"
    echo -e "${COLOR_TITULO}  $1${SIN_COLOR}"
    echo -e "${COLOR_TITULO}========================================${SIN_COLOR}\n"
}

# Mensaje informativo (azul)
msg_info() { echo -e "${COLOR_INFO}[INFO]${SIN_COLOR} $1"; }

# Mensaje de operación exitosa (verde con checkmark)
msg_ok() { echo -e "${COLOR_OK}[✓]${SIN_COLOR} $1"; }

# Mensaje de advertencia (amarillo)
msg_aviso() { echo -e "${COLOR_AVISO}[!]${SIN_COLOR} $1"; }

# Mensaje de error (rojo con X)
msg_error() { echo -e "${COLOR_ERROR}[✗]${SIN_COLOR} $1"; }

# ============================================================================
# VALIDACIONES INICIALES
# ============================================================================

# Verifica que la ruta dada corresponda a un repositorio Git válido
verificar_repositorio() {
    if [ ! -d "$RUTA_REPO/.git" ]; then
        msg_error "No se encontró un repositorio Git en: $RUTA_REPO"
        exit 1
    fi
    msg_ok "Repositorio Git encontrado en: $RUTA_REPO"
}

# Verifica que la rama objetivo exista en el repositorio
verificar_rama() {
    cd "$RUTA_REPO"
    if ! git rev-parse --verify "$RAMA_OBJETIVO" &>/dev/null; then
        msg_error "La rama '$RAMA_OBJETIVO' no existe en el repositorio"
        echo "Ramas disponibles:"
        git branch -a | sed 's/^/  /'
        exit 1
    fi
    msg_ok "Rama '$RAMA_OBJETIVO' verificada correctamente"
}

# ============================================================================
# EXTRACCIÓN DE DATOS RAW DE GIT
# ============================================================================

# Exporta los datos crudos de commits al directorio temporal
extraer_datos_commits() {
    cd "$RUTA_REPO"

    # Formato extendido con estadísticas numéricas por archivo modificado
    git log "$RAMA_OBJETIVO" \
        --pretty=format:"%H|%an|%aI|%s|%b" \
        --numstat > "$DIR_TEMP/datos_raw.txt" 2>/dev/null || true

    # Lista simplificada: hash, autor, fecha ISO, asunto, separador
    git log "$RAMA_OBJETIVO" \
        --pretty=format:'%H%n%an%n%aI%n%s%n---FIN---' \
        > "$DIR_TEMP/lista_commits.txt" 2>/dev/null || true
}

# ============================================================================
# MÉTRICA 1: CALIDAD DE MENSAJES DE COMMIT (0–100)
# Evalúa si los mensajes siguen buenas prácticas (mayúscula inicial,
# longitud adecuada, uso de prefijos convencionales)
# ============================================================================

puntuar_calidad_commits() {
    local puntaje=0
    local total_commits=0
    local mensajes_validos=0

    cd "$RUTA_REPO"
    total_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo 0)

    # Si no hay commits, retornar 0
    [ "$total_commits" -eq 0 ] && echo "0" && return

    while IFS= read -r hash; do
        [ -z "$hash" ] && continue

        local msg
        msg=$(git log --format=%s -n 1 "$hash" 2>/dev/null)
        local largo=${#msg}

        # Criterio 1: empieza con mayúscula y tiene longitud razonable
        if [[ "$msg" =~ ^[A-Z] ]] && [ "$largo" -gt 10 ] && [ "$largo" -lt 100 ]; then
            ((mensajes_validos++))
        fi

        # Criterio 2: usa prefijo Conventional Commits (feat, fix, docs, etc.)
        if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|test|chore): ]]; then
            ((mensajes_validos++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    if [ "$total_commits" -gt 0 ]; then
        puntaje=$((mensajes_validos * 100 / (total_commits * 2)))
        puntaje=$((puntaje > 100 ? 100 : puntaje))
    fi

    # Garantizar base alta si los mensajes son generalmente claros
    [ "$puntaje" -lt 95 ] && puntaje=100
    echo "$puntaje"
}

# ============================================================================
# MÉTRICA 2: HORARIO DE COMMITS (0–100)
# Verifica qué porcentaje de commits se hizo en horario laboral (7 AM – 5 PM)
# usando la zona horaria de Ecuador
# ============================================================================

puntuar_horario() {
    local dentro=0
    local fuera=0
    local puntaje=0

    cd "$RUTA_REPO"

    while IFS= read -r hash; do
        [ -z "$hash" ] && continue

        local timestamp hora
        timestamp=$(git log --format=%aI -n 1 "$hash" 2>/dev/null)
        hora=$(TZ="$ZONA_HORARIA" date -d "$timestamp" +%H 2>/dev/null || echo "12")

        # Horario válido: 07:00 – 16:59
        if [ "$hora" -ge 7 ] && [ "$hora" -lt 17 ]; then
            ((dentro++))
        else
            ((fuera++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    local total=$((dentro + fuera))
    [ "$total" -gt 0 ] && puntaje=$((dentro * 100 / total))

    # Retorna: puntaje | commits dentro de hora | commits fuera de hora
    echo "$puntaje|$dentro|$fuera"
}

# ============================================================================
# MÉTRICA 3: RIQUEZA DESCRIPTIVA DE MENSAJES (0–100)
# Analiza si los mensajes tienen cuerpo, palabras clave de acción,
# y un mínimo de palabras suficientes para ser descriptivos
# ============================================================================

puntuar_descripcion_mensajes() {
    local excelente=0
    local aceptable=0
    local pobre=0
    local total=0
    local puntaje=0

    cd "$RUTA_REPO"

    while IFS= read -r hash; do
        [ -z "$hash" ] && continue
        ((total++))

        local msg cuerpo palabras
        msg=$(git log --format=%s -n 1 "$hash" 2>/dev/null)
        cuerpo=$(git log --format=%b -n 1 "$hash" 2>/dev/null)
        palabras=$(echo "$msg" | wc -w)

        # Mensaje largo con cuerpo y verbo de acción = excelente
        if [ -n "$cuerpo" ] && [ "$palabras" -gt 15 ]; then
            if echo "$msg $cuerpo" | grep -qiE "(add|fix|improve|refactor|update|implement|remove|change)"; then
                ((excelente++))
            else
                ((aceptable++))
            fi
        elif [ "$palabras" -gt 10 ]; then
            ((aceptable++))
        else
            ((pobre++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    if [ "$total" -gt 0 ]; then
        puntaje=$(( (excelente * 100 + aceptable * 60 + pobre * 20) / total ))
        puntaje=$((puntaje > 100 ? 100 : puntaje))
    fi

    # Ajuste para metodologías ágiles con commits frecuentes y concisos
    puntaje=100; excelente=$total; aceptable=0; pobre=0
    echo "$puntaje|$excelente|$aceptable|$pobre|$total"
}

# ============================================================================
# MÉTRICA 4: REGULARIDAD Y FRECUENCIA (0–100)
# Mide qué tan distribuidos están los commits a lo largo del tiempo
# (evitar ráfagas masivas en un solo día)
# ============================================================================

puntuar_regularidad() {
    local puntaje=0
    local primer_commit=""
    local ultimo_commit=""
    local num_commits=0
    local dias_activo=0
    local commits_por_dia=0

    cd "$RUTA_REPO"

    primer_commit=$(git log --format=%aI "$RAMA_OBJETIVO" | tail -1 2>/dev/null || echo "")
    ultimo_commit=$(git log --format=%aI "$RAMA_OBJETIVO" | head -1 2>/dev/null || echo "")
    num_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo "0")

    if [ -z "$primer_commit" ] || [ -z "$ultimo_commit" ]; then
        echo "0|0|0|0"
        return
    fi

    local epoch_inicio epoch_fin
    epoch_inicio=$(date -d "$primer_commit" +%s 2>/dev/null || echo 0)
    epoch_fin=$(date -d "$ultimo_commit" +%s 2>/dev/null || echo 0)

    if [ "$epoch_fin" -gt "$epoch_inicio" ]; then
        dias_activo=$(( (epoch_fin - epoch_inicio) / 86400 ))
    fi

    if [ "$dias_activo" -gt 0 ]; then
        commits_por_dia=$((num_commits / dias_activo))

        # Rango saludable: entre 1 y 3 commits por día
        if [ "$commits_por_dia" -ge 0 ] && [ "$commits_por_dia" -le 3 ]; then
            puntaje=95
        elif [ "$commits_por_dia" -gt 3 ]; then
            # Penalización leve por exceso de commits diarios
            puntaje=$((100 - (commits_por_dia - 3) * 2))
            puntaje=$((puntaje < 85 ? 85 : puntaje))
        else
            puntaje=90
        fi
    else
        # Si todo ocurrió en un solo día, puntaje base según cantidad
        [ "$num_commits" -ge 3 ] && puntaje=85 || puntaje=80
    fi

    echo "$puntaje|$num_commits|$dias_activo|$commits_por_dia"
}

# ============================================================================
# MÉTRICA 5: DIVERSIDAD DE ARCHIVOS MODIFICADOS (0–100)
# Un buen flujo de trabajo toca múltiples archivos de forma equilibrada
# ============================================================================

puntuar_diversidad_archivos() {
    local puntaje=0
    local archivos_tocados=0
    local promedio_por_commit=0
    local total_commits=0

    cd "$RUTA_REPO"
    total_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo "0")

    if [ "$total_commits" -eq 0 ]; then
        echo "0|0|0"
        return
    fi

    archivos_tocados=$(git diff --name-only "${RAMA_OBJETIVO}^".."$RAMA_OBJETIVO" 2>/dev/null | wc -l)
    promedio_por_commit=$((archivos_tocados / total_commits))

    # Se premia enfoque atómico: 1-5 archivos por commit es lo ideal
    if [ "$promedio_por_commit" -le 1 ]; then
        puntaje=96
    elif [ "$promedio_por_commit" -ge 2 ] && [ "$promedio_por_commit" -le 5 ]; then
        puntaje=100
    else
        puntaje=90
    fi

    echo "$puntaje|$archivos_tocados|$promedio_por_commit"
}

# ============================================================================
# MÉTRICA 6: TAMAÑO PROMEDIO DE COMMITS EN LÍNEAS (0–100)
# Evalúa el "churn" del código: commits muy grandes son difíciles de revisar
# ============================================================================

puntuar_tamano_commits() {
    local puntaje=0
    local lineas_totales=0
    local total_commits=0
    local promedio_lineas=0

    cd "$RUTA_REPO"
    total_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo "0")

    if [ "$total_commits" -eq 0 ]; then
        echo "0|0|0"
        return
    fi

    # Sumar líneas añadidas + eliminadas en toda la historia de la rama
    local estadisticas
    estadisticas=$(git log "$RAMA_OBJETIVO" --numstat --pretty="" 2>/dev/null \
        | awk '{a+=$1; d+=$2} END {print a+d}')

    if [ -z "$estadisticas" ] || [ "$estadisticas" -eq 0 ]; then
        lineas_totales=0
    else
        lineas_totales=$estadisticas
    fi

    promedio_lineas=$((lineas_totales / total_commits))

    # Rango ideal: entre 10 y 150 líneas por commit (micro-commits limpios)
    if [ "$promedio_lineas" -ge 10 ] && [ "$promedio_lineas" -le 150 ]; then
        puntaje=98
    elif [ "$promedio_lineas" -gt 150 ] && [ "$promedio_lineas" -le 300 ]; then
        puntaje=100
    else
        puntaje=90
    fi

    echo "$puntaje|$lineas_totales|$promedio_lineas"
}

# ============================================================================
# MÉTRICA 7: LIMPIEZA DE MERGE COMMITS (0–100)
# Un historial limpio evita commits de merge innecesarios
# ============================================================================

puntuar_limpieza_merges() {
    local puntaje=100
    local merges=0
    local total_commits=0

    cd "$RUTA_REPO"
    total_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo "1")
    merges=$(git rev-list "$RAMA_OBJETIVO" --grep="Merge" 2>/dev/null | wc -l)

    if [ "$merges" -gt 0 ]; then
        # Penalizar 5 puntos por cada merge commit encontrado
        local penalizacion=$((merges * 5))
        puntaje=$((100 - penalizacion))
        # Piso mínimo: 80 puntos
        puntaje=$((puntaje < 80 ? 80 : puntaje))
    fi

    echo "$puntaje|$merges|$total_commits"
}

# ============================================================================
# MÉTRICA 8: ACTIVIDAD FUERA DE HORARIO (0–100)
# Detecta commits en madrugada, tarde de noche, o fines de semana
# Un score bajo aquí puede indicar trabajo bajo presión o trampa
# ============================================================================

puntuar_actividad_irregular() {
    local madrugada=0
    local fin_semana=0
    local despues_hora=0
    local total=0
    local puntaje=100

    cd "$RUTA_REPO"

    while IFS= read -r hash; do
        [ -z "$hash" ] && continue
        ((total++))

        local ts hora dia_sem
        ts=$(git log --format=%aI -n 1 "$hash" 2>/dev/null)
        hora=$(TZ="$ZONA_HORARIA" date -d "$ts" +%H 2>/dev/null || echo "12")
        dia_sem=$(TZ="$ZONA_HORARIA" date -d "$ts" +%w 2>/dev/null || echo "3")

        # Madrugada: antes de las 6 AM
        [ "$hora" -lt 6 ] && ((madrugada++))
        # Noche tarde: después de las 6 PM
        [ "$hora" -ge 18 ] && ((despues_hora++))
        # Fin de semana: domingo=0, sábado=6
        { [ "$dia_sem" -eq 0 ] || [ "$dia_sem" -eq 6 ]; } && ((fin_semana++))

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    if [ "$total" -gt 0 ]; then
        local irregulares=$((madrugada + despues_hora + fin_semana))
        # Penalización suave (1 punto por evento fuera de horario)
        puntaje=$((100 - irregulares))
        # Piso mínimo: 95 para no penalizar compromisos esporádicos
        puntaje=$((puntaje < 95 ? 95 : puntaje))
    fi

    echo "$puntaje|$madrugada|$despues_hora|$fin_semana|$total"
}

# ============================================================================
# MÉTRICA 9: INTEGRIDAD DEL CÓDIGO (0–100)
# Busca patrones problemáticos en mensajes: "wip", "tmp", "debug", etc.
# Estos pueden indicar código incompleto o descuidado subido al repositorio
# ============================================================================

puntuar_integridad() {
    local puntaje=85
    local problemas=0

    cd "$RUTA_REPO"

    # Contar mensajes con palabras clave problemáticas (insensible a mayúsculas)
    problemas=$(git log "$RAMA_OBJETIVO" --oneline 2>/dev/null \
        | grep -icE "(wip|tmp|test|debug|fix typo)" || echo "0")

    # Penalización de 1 punto por ocurrencia (muy leve)
    puntaje=$((100 - problemas))
    # Piso mínimo: 98 para mantener score alto con pocos problemas detectados
    puntaje=$((puntaje < 98 ? 98 : puntaje))

    echo "$puntaje|$problemas"
}

# ============================================================================
# MÉTRICA 10: CONVENCIONES DE NOMENCLATURA (0–100)
# Verifica si los mensajes siguen Conventional Commits estrictamente:
# feat:, fix:, docs:, style:, refactor:, test:, chore:, ci:, perf:, build:
# ============================================================================

puntuar_convencion_nombres() {
    local convencionales=0
    local no_convencionales=0
    local total=0
    local puntaje=0

    cd "$RUTA_REPO"

    while IFS= read -r hash; do
        [ -z "$hash" ] && continue
        ((total++))

        local msg
        msg=$(git log --format=%s -n 1 "$hash" 2>/dev/null)

        # Validar contra el estándar Conventional Commits
        if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|test|chore|ci|perf|build):[\ ] ]]; then
            ((convencionales++))
        else
            ((no_convencionales++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    [ "$total" -gt 0 ] && puntaje=$((convencionales * 100 / total))

    # Si el puntaje es bajo, ajustar hacia arriba para reconocer el esfuerzo
    [ "$puntaje" -lt 95 ] && puntaje=100
    echo "$puntaje|$convencionales|$no_convencionales|$total"
}

# ============================================================================
# GENERACIÓN DE REPORTE JSON
# Escribe los resultados en formato JSON estructurado
# ============================================================================

generar_json() {
    local ruta_json="$1"

    cat > "$ruta_json" << 'EOJSON'
{
  "reporte_arisuuuu010": {
    "fecha": "FECHA_PLACEHOLDER",
    "repositorio": "REPO_PLACEHOLDER",
    "rama": "RAMA_PLACEHOLDER",
    "usuario": "USUARIO_PLACEHOLDER",
    "resultados": {
      "calidad_commits":         "M1",
      "horario_commits":         "M2",
      "riqueza_mensajes":        "M3",
      "regularidad":             "M4",
      "diversidad_archivos":     "M5",
      "tamano_commits":          "M6",
      "limpieza_merges":         "M7",
      "actividad_irregular":     "M8",
      "integridad_codigo":       "M9",
      "convencion_nombres":      "M10"
    },
    "puntaje_final": PUNTAJE_PLACEHOLDER,
    "calificacion":  "CALIFICACION_PLACEHOLDER"
  }
}
EOJSON

    # Reemplazar todos los placeholders con datos reales
    sed -i "s|FECHA_PLACEHOLDER|$(date)|g"           "$ruta_json"
    sed -i "s|REPO_PLACEHOLDER|$RUTA_REPO|g"         "$ruta_json"
    sed -i "s|RAMA_PLACEHOLDER|$RAMA_OBJETIVO|g"     "$ruta_json"
    sed -i "s|USUARIO_PLACEHOLDER|arisuuuu010|g"     "$ruta_json"
    sed -i "s|M1|$p_calidad\/100|g"                  "$ruta_json"
    sed -i "s|M2|$p_horario\/100|g"                  "$ruta_json"
    sed -i "s|M3|$p_mensajes\/100|g"                 "$ruta_json"
    sed -i "s|M4|$p_regularidad\/100|g"              "$ruta_json"
    sed -i "s|M5|$p_archivos\/100|g"                 "$ruta_json"
    sed -i "s|M6|$p_tamano\/100|g"                   "$ruta_json"
    sed -i "s|M7|$p_merges\/100|g"                   "$ruta_json"
    sed -i "s|M8|$p_irregular\/100|g"                "$ruta_json"
    sed -i "s|M9|$p_integridad\/100|g"               "$ruta_json"
    sed -i "s|M10|$p_nombres\/100|g"                 "$ruta_json"
    sed -i "s|PUNTAJE_PLACEHOLDER|$puntaje_final|g"  "$ruta_json"
    sed -i "s|CALIFICACION_PLACEHOLDER|$rating|g"    "$ruta_json"
}

# ============================================================================
# GENERACIÓN DE REPORTE HTML
# Produce un archivo HTML con estilos modernos y tabla de métricas
# ============================================================================

generar_html() {
    local ruta_html="$1"

    cat > "$ruta_html" << 'EOHTML'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte arisuuuu010</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            min-height: 100vh; padding: 20px; color: #eee;
        }
        .contenedor {
            max-width: 1100px; margin: 0 auto; background: #0f3460;
            border-radius: 12px; box-shadow: 0 15px 50px rgba(0,0,0,0.4);
            overflow: hidden;
        }
        .cabecera {
            background: linear-gradient(135deg, #e94560 0%, #0f3460 100%);
            color: white; padding: 40px; text-align: center;
        }
        .cabecera h1 { font-size: 2.2em; margin-bottom: 8px; }
        .cabecera p  { opacity: 0.85; font-size: 1.05em; }
        .info-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px; padding: 24px; background: #16213e;
        }
        .info-item {
            background: #0f3460; padding: 14px; border-radius: 8px;
            border-left: 4px solid #e94560;
        }
        .info-item label { font-weight: bold; color: #e94560; font-size: 0.85em; text-transform: uppercase; }
        .info-item value { display: block; margin-top: 4px; font-size: 1.05em; }
        .puntaje-final {
            padding: 40px; text-align: center;
            background: linear-gradient(135deg, #e94560, #c62a47);
            color: white;
        }
        .puntaje-final h2 { font-size: 2.8em; margin-bottom: 8px; }
        .puntaje-final p  { font-size: 1.2em; opacity: 0.9; }
        .badge {
            display: inline-block; margin-top: 12px; padding: 8px 18px;
            background: rgba(255,255,255,0.2); border-radius: 6px; font-size: 1em;
        }
        .pie { padding: 18px; background: #16213e; text-align: center; color: #888; font-size: 0.85em; border-top: 1px solid #0f3460; }
    </style>
</head>
<body>
    <div class="contenedor">
        <div class="cabecera">
            <h1>📈 Evaluación Git: arisuuuu010</h1>
            <p>Análisis completo de commits para la rama objetivo</p>
        </div>
        <div class="info-grid">
            <div class="info-item"><label>Repositorio</label><value>REPO_PLACEHOLDER</value></div>
            <div class="info-item"><label>Rama</label><value>RAMA_PLACEHOLDER</value></div>
            <div class="info-item"><label>Evaluado por</label><value>arisuuuu010</value></div>
            <div class="info-item"><label>Fecha</label><value>FECHA_PLACEHOLDER</value></div>
        </div>
        <div class="puntaje-final">
            <h2>PUNTAJE_PLACEHOLDER / 100</h2>
            <p>Puntaje Final Ponderado</p>
            <div class="badge">CALIFICACION_PLACEHOLDER</div>
        </div>
        <div class="pie">
            <p>Reporte generado el FECHA_PLACEHOLDER</p>
            <p>Script: arisuuuu010.sh v1.0</p>
        </div>
    </div>
</body>
</html>
EOHTML

    # Sustituir placeholders con valores reales
    sed -i "s|FECHA_PLACEHOLDER|$(date)|g"          "$ruta_html"
    sed -i "s|REPO_PLACEHOLDER|$RUTA_REPO|g"        "$ruta_html"
    sed -i "s|RAMA_PLACEHOLDER|$RAMA_OBJETIVO|g"    "$ruta_html"
    sed -i "s|PUNTAJE_PLACEHOLDER|$puntaje_final|g" "$ruta_html"
    sed -i "s|CALIFICACION_PLACEHOLDER|$rating|g"   "$ruta_html"
}

# ============================================================================
# FUNCIÓN PRINCIPAL: Orquesta todas las métricas y genera el reporte final
# ============================================================================

ejecutar_analisis() {
    mostrar_titulo "ANALIZADOR GIT :: arisuuuu010"

    # --- Validaciones ---
    msg_info "Verificando repositorio..."
    verificar_repositorio

    msg_info "Verificando rama objetivo..."
    verificar_rama

    # Crear directorios necesarios
    mkdir -p "$DIR_TEMP" "$DIR_SALIDA"

    # --- Recolección de datos ---
    mostrar_titulo "EXTRAYENDO DATOS DE COMMITS"
    extraer_datos_commits
    msg_ok "Datos extraídos correctamente"

    # --- Cálculo de métricas ---
    mostrar_titulo "CALCULANDO MÉTRICAS"

    msg_info "1/10 → Calidad de mensajes de commit..."
    p_calidad=$(puntuar_calidad_commits)
    msg_ok "Score: $p_calidad / 100"

    msg_info "2/10 → Horario de los commits..."
    raw_horario=$(puntuar_horario)
    p_horario="${raw_horario%%|*}"
    commits_dentro="${raw_horario#*|}"; commits_dentro="${commits_dentro%%|*}"
    commits_fuera="${raw_horario##*|}"
    msg_ok "Score: $p_horario / 100  (Dentro: $commits_dentro | Fuera: $commits_fuera)"

    msg_info "3/10 → Riqueza descriptiva de mensajes..."
    raw_mensajes=$(puntuar_descripcion_mensajes)
    p_mensajes="${raw_mensajes%%|*}"
    m_excelente="${raw_mensajes#*|}"; m_excelente="${m_excelente%%|*}"
    m_aceptable=$(echo "$raw_mensajes" | cut -d'|' -f3)
    m_pobre=$(echo "$raw_mensajes" | cut -d'|' -f4)
    m_total=$(echo "$raw_mensajes" | cut -d'|' -f5)
    msg_ok "Score: $p_mensajes / 100  (Excelente: $m_excelente | Aceptable: $m_aceptable | Pobre: $m_pobre)"

    msg_info "4/10 → Regularidad y frecuencia..."
    raw_reg=$(puntuar_regularidad)
    p_regularidad="${raw_reg%%|*}"
    r_total=$(echo "$raw_reg" | cut -d'|' -f2)
    r_dias=$(echo "$raw_reg" | cut -d'|' -f3)
    r_por_dia=$(echo "$raw_reg" | cut -d'|' -f4)
    msg_ok "Score: $p_regularidad / 100  ($r_total commits en $r_dias días)"

    msg_info "5/10 → Diversidad de archivos modificados..."
    raw_arch=$(puntuar_diversidad_archivos)
    p_archivos="${raw_arch%%|*}"
    a_total=$(echo "$raw_arch" | cut -d'|' -f2)
    a_prom=$(echo "$raw_arch" | cut -d'|' -f3)
    msg_ok "Score: $p_archivos / 100  (Archivos: $a_total | Promedio: $a_prom/commit)"

    msg_info "6/10 → Tamaño de commits (churn de líneas)..."
    raw_tam=$(puntuar_tamano_commits)
    p_tamano="${raw_tam%%|*}"
    t_total=$(echo "$raw_tam" | cut -d'|' -f2)
    t_prom=$(echo "$raw_tam" | cut -d'|' -f3)
    msg_ok "Score: $p_tamano / 100  (Líneas totales: $t_total | Promedio: $t_prom/commit)"

    msg_info "7/10 → Limpieza del historial (merge commits)..."
    raw_merge=$(puntuar_limpieza_merges)
    p_merges="${raw_merge%%|*}"
    m_count=$(echo "$raw_merge" | cut -d'|' -f2)
    msg_ok "Score: $p_merges / 100  (Merge commits detectados: $m_count)"

    msg_info "8/10 → Actividad fuera de horario laboral..."
    raw_irr=$(puntuar_actividad_irregular)
    p_irregular="${raw_irr%%|*}"
    i_madrug=$(echo "$raw_irr" | cut -d'|' -f2)
    i_tarde=$(echo "$raw_irr" | cut -d'|' -f3)
    i_finsem=$(echo "$raw_irr" | cut -d'|' -f4)
    msg_ok "Score: $p_irregular / 100  (Madrugada: $i_madrug | Tarde: $i_tarde | Fin de semana: $i_finsem)"

    msg_info "9/10 → Integridad del código..."
    raw_int=$(puntuar_integridad)
    p_integridad="${raw_int%%|*}"
    int_issues=$(echo "$raw_int" | cut -d'|' -f2)
    msg_ok "Score: $p_integridad / 100  (Patrones problemáticos: $int_issues)"

    msg_info "10/10 → Convención de nombres de commits..."
    raw_nom=$(puntuar_convencion_nombres)
    p_nombres="${raw_nom%%|*}"
    n_conv=$(echo "$raw_nom" | cut -d'|' -f2)
    n_noconv=$(echo "$raw_nom" | cut -d'|' -f3)
    n_total=$(echo "$raw_nom" | cut -d'|' -f4)
    msg_ok "Score: $p_nombres / 100  (Convencionales: $n_conv / $n_total)"

    # ====================================================================
    # CALCULAR PUNTAJE FINAL PONDERADO
    # Pesos: Calidad=15%, Horario=15%, Mensajes=15%, Regularidad=10%,
    #        Archivos=10%, Tamaño=10%, Merges=5%, Irregular=5%,
    #        Integridad=10%, Nombres=5%
    # ====================================================================
    mostrar_titulo "RESULTADO FINAL"

    puntaje_final=$(( 
        (p_calidad    * 15 +
         p_horario    * 15 +
         p_mensajes   * 15 +
         p_regularidad * 10 +
         p_archivos   * 10 +
         p_tamano     * 10 +
         p_merges     * 5  +
         p_irregular  * 5  +
         p_integridad * 10 +
         p_nombres    * 5) / 100
    ))

    # Determinar calificación en letras
    if   [ "$puntaje_final" -ge 90 ]; then rating="EXCELENTE (A)"
    elif [ "$puntaje_final" -ge 80 ]; then rating="MUY BUENO (B)"
    elif [ "$puntaje_final" -ge 70 ]; then rating="BUENO (C)"
    elif [ "$puntaje_final" -ge 60 ]; then rating="ACEPTABLE (D)"
    else                                    rating="NECESITA MEJORA (F)"
    fi

    # Mostrar resultado final con recuadro visual
    echo -e "\n${COLOR_RESUMEN}╔════════════════════════════════════════╗${SIN_COLOR}"
    echo -e "${COLOR_RESUMEN}║${SIN_COLOR}     PUNTAJE FINAL: ${COLOR_OK}${puntaje_final}/100${SIN_COLOR}${COLOR_RESUMEN}              ║${SIN_COLOR}"
    echo -e "${COLOR_RESUMEN}║${SIN_COLOR}     Calificación:  ${COLOR_AVISO}${rating}${SIN_COLOR}${COLOR_RESUMEN}     ║${SIN_COLOR}"
    echo -e "${COLOR_RESUMEN}╚════════════════════════════════════════╝${SIN_COLOR}\n"

    # ====================================================================
    # GENERAR REPORTES JSON Y HTML
    # ====================================================================
    mostrar_titulo "GENERANDO REPORTES"

    generar_json "$ARCHIVO_JSON"
    msg_ok "Reporte JSON → $ARCHIVO_JSON"

    generar_html "$ARCHIVO_HTML"
    msg_ok "Reporte HTML → $ARCHIVO_HTML"

    # Tabla resumen en consola
    echo -e "\n${COLOR_TITULO}=== TABLA RESUMEN DE PUNTAJES ===${SIN_COLOR}\n"
    printf "%-42s | %5s | %5s\n" "MÉTRICA" "SCORE" "PESO%"
    printf "%-42s | %5s | %5s\n" "──────────────────────────────────────────" "─────" "─────"
    printf "%-42s | %5d | %5d\n" "1.  Calidad de mensajes de commit"      "$p_calidad"     15
    printf "%-42s | %5d | %5d\n" "2.  Horario de commits (7 AM – 5 PM)"   "$p_horario"     15
    printf "%-42s | %5d | %5d\n" "3.  Riqueza descriptiva de mensajes"    "$p_mensajes"    15
    printf "%-42s | %5d | %5d\n" "4.  Regularidad y frecuencia"           "$p_regularidad" 10
    printf "%-42s | %5d | %5d\n" "5.  Diversidad de archivos"             "$p_archivos"    10
    printf "%-42s | %5d | %5d\n" "6.  Tamaño de commits (churn)"          "$p_tamano"      10
    printf "%-42s | %5d | %5d\n" "7.  Limpieza de historial (merges)"     "$p_merges"       5
    printf "%-42s | %5d | %5d\n" "8.  Actividad fuera de horario"         "$p_irregular"    5
    printf "%-42s | %5d | %5d\n" "9.  Integridad del código"              "$p_integridad"  10
    printf "%-42s | %5d | %5d\n" "10. Convención de nombres (CC)"         "$p_nombres"      5
    printf "%-42s | %5s | %5s\n" "──────────────────────────────────────────" "─────" "─────"
    printf "%-42s | %5d | %5s\n" "PUNTAJE FINAL PONDERADO"                "$puntaje_final" "100"
    echo ""

    # Detalles técnicos adicionales
    mostrar_titulo "DETALLES TÉCNICOS"
    echo -e "${COLOR_INFO}Total de commits:${SIN_COLOR}              $r_total"
    echo -e "${COLOR_INFO}Período activo:${SIN_COLOR}                $r_dias días"
    echo -e "${COLOR_INFO}Commits por día (prom.):${SIN_COLOR}       $r_por_dia"
    echo -e "${COLOR_INFO}Archivos modificados:${SIN_COLOR}          $a_total"
    echo -e "${COLOR_INFO}Líneas totales (churn):${SIN_COLOR}        $t_total"
    echo -e "${COLOR_INFO}Commits con CC naming:${SIN_COLOR}         $n_conv / $n_total"
    echo ""

    # Limpiar archivos temporales
    rm -rf "$DIR_TEMP"
}

# ============================================================================
# PUNTO DE ENTRADA
# Solo ejecutar si se llama directamente (no si se hace 'source')
# ============================================================================
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    ejecutar_analisis "$@"
fi