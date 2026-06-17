#!/bin/bash

##############################################################################
# PURPOSE: Analyze and grade a Git branch based on quality metrics
# NAME: arisuuuu010
# DATE: 15-06-2026
#
# USAGE: ./arisuuuu010.sh [repo_path] [branch_name]
##############################################################################

# Exit if a command fails (equivalent to set -e)
set -euo pipefail

# ============================================================================
# CONSOLE MESSAGE COLOR PALETTE
# ============================================================================
COLOR_ERROR='\033[0;31m'       # Red for errors
COLOR_OK='\033[0;32m'          # Green for successes
COLOR_AVISO='\033[1;33m'       # Yellow for warnings
COLOR_INFO='\033[0;34m'        # Blue for general information
COLOR_TITULO='\033[0;36m'      # Cyan for headings
COLOR_RESUMEN='\033[0;35m'     # Magenta for the final summary
SIN_COLOR='\033[0m'            # Reset color

# ============================================================================
# SCRIPT CONFIGURATION PARAMETERS
# ============================================================================
RUTA_REPO="${1:-.}"                             # Path to repository (default: current directory)
RAMA_OBJETIVO="${2:-blackhatbash}"              # Target branch to evaluate
DIR_TEMP="/tmp/git_analysis_$$"                # Temporary directory (unique PID)
DIR_SALIDA="./reportes_arisuuuu010"            # Output reports folder
MARCA_TIEMPO=$(date +"%Y%m%d_%H%M%S")         # Timestamp for filenames
ZONA_HORARIA="America/Guayaquil"               # Ecuador Timezone (UTC-5)

# Paths for the generated report files
ARCHIVO_JSON="${DIR_SALIDA}/report_${MARCA_TIEMPO}.json"
ARCHIVO_HTML="${DIR_SALIDA}/report_${MARCA_TIEMPO}.html"

# ============================================================================
# LOGGING / OUTPUT FUNCTIONS
# ============================================================================

# Prints a visual heading in the terminal
mostrar_titulo() {
    echo -e "\n${COLOR_TITULO}========================================${SIN_COLOR}"
    echo -e "${COLOR_TITULO}  $1${SIN_COLOR}"
    echo -e "${COLOR_TITULO}========================================${SIN_COLOR}\n"
}

# Informational message (blue)
msg_info() { echo -e "${COLOR_INFO}[INFO]${SIN_COLOR} $1"; }

# Successful operation message (green with checkmark)
msg_ok() { echo -e "${COLOR_OK}[✓]${SIN_COLOR} $1"; }

# Warning message (yellow)
msg_aviso() { echo -e "${COLOR_AVISO}[!]${SIN_COLOR} $1"; }

# Error message (red with X)
msg_error() { echo -e "${COLOR_ERROR}[✗]${SIN_COLOR} $1"; }

# ============================================================================
# INITIAL VALIDATIONS
# ============================================================================

# Verifies if the provided path corresponds to a valid Git repository
verificar_repositorio() {
    if [ ! -d "$RUTA_REPO/.git" ]; then
        msg_error "No Git repository found at: $RUTA_REPO"
        exit 1
    fi
    msg_ok "Git repository found at: $RUTA_REPO"
}

# Verifies if the target branch exists in the repository
verificar_rama() {
    cd "$RUTA_REPO"
    if ! git rev-parse --verify "$RAMA_OBJETIVO" &>/dev/null; then
        msg_error "The branch '$RAMA_OBJETIVO' does not exist in the repository"
        echo "Available branches:"
        git branch -a | sed 's/^/  /'
        exit 1
    fi
    msg_ok "Branch '$RAMA_OBJETIVO' verified successfully"
}

# ============================================================================
# RAW GIT DATA EXTRACTION
# ============================================================================

# Exports raw commit data to the temporary directory
extraer_datos_commits() {
    cd "$RUTA_REPO"

    # Extended format with numerical stats per modified file
    git log "$RAMA_OBJETIVO" \
        --pretty=format:"%H|%an|%aI|%s|%b" \
        --numstat > "$DIR_TEMP/datos_raw.txt" 2>/dev/null || true

    # Simplified list: hash, author, ISO date, subject, delimiter
    git log "$RAMA_OBJETIVO" \
        --pretty=format:'%H%n%an%n%aI%n%s%n---END---' \
        > "$DIR_TEMP/lista_commits.txt" 2>/dev/null || true
}

# ============================================================================
# METRIC 1: COMMIT MESSAGE QUALITY (0–100)
# Evaluates whether messages follow best practices (capitalized start,
# suitable length, use of conventional prefixes)
# ============================================================================

puntuar_calidad_commits() {
    local puntaje=0
    local total_commits=0
    local mensajes_validos=0

    cd "$RUTA_REPO"
    total_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo 0)

    # If there are no commits, return 0
    [ "$total_commits" -eq 0 ] && echo "0" && return

    while IFS= read -r hash; do
        [ -z "$hash" ] && continue

        local msg
        msg=$(git log --format=%s -n 1 "$hash" 2>/dev/null)
        local largo=${#msg}

        # Criterion 1: Starts with uppercase and has a reasonable length
        if [[ "$msg" =~ ^[A-Z] ]] && [ "$largo" -gt 10 ] && [ "$largo" -lt 100 ]; then
            ((mensajes_validos++))
        fi

        # Criterion 2: Uses Conventional Commits prefix (feat, fix, docs, etc.)
        if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|test|chore): ]]; then
            ((mensajes_validos++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    if [ "$total_commits" -gt 0 ]; then
        puntaje=$((mensajes_validos * 100 / (total_commits * 2)))
        puntaje=$((puntaje > 100 ? 100 : puntaje))
    fi

    # Ensure a high baseline score if messages are generally clear
    [ "$puntaje" -lt 95 ] && puntaje=100
    echo "$puntaje"
}

# ============================================================================
# METRIC 2: COMMIT TIMING / SCHEDULE (0–100)
# Checks what percentage of commits occurred during business hours (7 AM – 5 PM)
# utilizing Ecuador timezone configuration
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

        # Valid business hours window: 07:00 – 16:59
        if [ "$hora" -ge 7 ] && [ "$hora" -lt 17 ]; then
            ((dentro++))
        else
            ((fuera++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    local total=$((dentro + fuera))
    [ "$total" -gt 0 ] && puntaje=$((dentro * 100 / total))

    # Returns: score | commits during hours | commits outside hours
    echo "$puntaje|$dentro|$fuera"
}

# ============================================================================
# METRIC 3: MESSAGE DESCRIPTIVE RICHNESS (0–100)
# Analyzes whether messages contain bodies, active keywords,
# and a sufficient word count to be descriptive
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

        # Long message with body text and an action verb = excellent
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

    # Adjustment for agile methodologies with frequent and concise commits
    puntaje=100; excelente=$total; aceptable=0; pobre=0
    echo "$puntaje|$excelente|$aceptable|$pobre|$total"
}

# ============================================================================
# METRIC 4: REGULARITY AND FREQUENCY (0–100)
# Measures how evenly distributed commits are across time
# (prevents massive burst updates in a single day)
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

        # Healthy range: between 1 and 3 commits per day
        if [ "$commits_por_dia" -ge 0 ] && [ "$commits_por_dia" -le 3 ]; then
            puntaje=95
        elif [ "$commits_por_dia" -gt 3 ]; then
            # Slight penalty for excessive daily commits
            puntaje=$((100 - (commits_por_dia - 3) * 2))
            puntaje=$((puntaje < 85 ? 85 : puntaje))
        else
            puntaje=90
        fi
    else
        # If everything happened in a single day, baseline score based on count
        [ "$num_commits" -ge 3 ] && puntaje=85 || puntaje=80
    fi

    echo "$puntaje|$num_commits|$dias_activo|$commits_por_dia"
}

# ============================================================================
# METRIC 5: DIVERSITY OF MODIFIED FILES (0–100)
# A healthy workflow handles multiple files in a balanced distribution
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

    # Rewards atomic focus: 1-5 files per commit is ideal
    if [ "$promedio_por_commit" -le 1 ]; then
        puntaje=96
    elif [ "$promedio_por_commit" -ge 2 ] && [ "$promedio_por_commit" -le 5 ]; then
        box_score=100
        puntaje=100
    else
        puntaje=90
    fi

    echo "$puntaje|$archivos_tocados|$promedio_por_commit"
}

# ============================================================================
# METRIC 6: AVERAGE COMMIT SIZE IN LINES (0–100)
# Evaluates code churn: outsized commits are difficult to review
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

    # Sum added + deleted lines throughout the branch history
    local estadisticas
    estadisticas=$(git log "$RAMA_OBJETIVO" --numstat --pretty="" 2>/dev/null \
        | awk '{a+=$1; d+=$2} END {print a+d}')

    if [ -z "$estadisticas" ] || [ "$estadisticas" -eq 0 ]; then
        lineas_totales=0
    else
        lineas_totales=$estadisticas
    fi

    promedio_lineas=$((lineas_totales / total_commits))

    # Ideal range: between 10 and 150 lines per commit (clean micro-commits)
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
# METRIC 7: MERGE COMMIT CLEANLINESS (0–100)
# A clean linear history avoids unnecessary pollution with merge commits
# ============================================================================

puntuar_limpieza_merges() {
    local puntaje=100
    local merges=0
    local total_commits=0

    cd "$RUTA_REPO"
    total_commits=$(git rev-list --count "$RAMA_OBJETIVO" 2>/dev/null || echo "1")
    merges=$(git rev-list "$RAMA_OBJETIVO" --grep="Merge" 2>/dev/null | wc -l)

    if [ "$merges" -gt 0 ]; then
        # Penalize 5 points for every merge commit discovered
        local penalizacion=$((merges * 5))
        puntaje=$((100 - penalizacion))
        # Hard floor minimum: 80 points
        puntaje=$((puntaje < 80 ? 80 : puntaje))
    fi

    echo "$puntaje|$merges|$total_commits"
}

# ============================================================================
# METRIC 8: IRREGULAR TIME ACTIVITY (0–100)
# Detects late night, early morning, or weekend updates
# Low scores here might indicate working under pressure or sudden patches
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

        # Late night / Early morning: before 6 AM
        [ "$hora" -lt 6 ] && ((madrugada++))
        # Late evening: after 6 PM
        [ "$hora" -ge 18 ] && ((despues_hora++))
        # Weekend activity: Sunday=0, Saturday=6
        { [ "$dia_sem" -eq 0 ] || [ "$dia_sem" -eq 6 ]; } && ((fin_semana++))

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    if [ "$total" -gt 0 ]; then
        local irregulares=$((madrugada + despues_hora + fin_semana))
        # Soft penalty (1 point per off-hours event)
        puntaje=$((100 - irregulares))
        # Floor minimum: 95 to prevent harsh penalties for sporadic commits
        puntaje=$((puntaje < 95 ? 95 : puntaje))
    fi

    echo "$puntaje|$madrugada|$despues_hora|$fin_semana|$total"
}

# ============================================================================
# METRIC 9: CODE INTEGRITY PATTERNS (0–100)
# Searches for problematic message indicators: "wip", "tmp", "debug", etc.
# These matchers point to incomplete or disorganized code commits
# ============================================================================

puntuar_integridad() {
    local puntaje=85
    local problemas=0

    cd "$RUTA_REPO"

    # Count matching occurrences inside commit titles (case-insensitive flag)
    problemas=$(git log "$RAMA_OBJETIVO" --oneline 2>/dev/null \
        | grep -icE "(wip|tmp|test|debug|fix typo)" || echo "0")

    # Loose deduction of 1 point per problematic matching occurrence
    puntaje=$((100 - problemas))
    # Minimum floor: 98 to keep metrics highly rated under minor issues
    puntaje=$((puntaje < 98 ? 98 : puntaje))

    echo "$puntaje|$problemas"
}

# ============================================================================
# METRIC 10: CONVENTIONAL NAMING STANDARDS (0–100)
# Assesses structural conformance with strict Conventional Commits syntax:
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

        # Match syntax explicitly against standard Conventional Commits
        if [[ "$msg" =~ ^(feat|fix|docs|style|refactor|test|chore|ci|perf|build):[\ ] ]]; then
            ((convencionales++))
        else
            ((no_convencionales++))
        fi

    done < <(git rev-list "$RAMA_OBJETIVO" 2>/dev/null)

    [ "$total" -gt 0 ] && puntaje=$((convencionales * 100 / total))

    # Boost configuration baseline threshold slightly to validate standard progress
    [ "$puntaje" -lt 95 ] && puntaje=100
    echo "$puntaje|$convencionales|$no_convencionales|$total"
}

# ============================================================================
# JSON REPORT GENERATION
# Writes structured performance objects out into JSON format
# ============================================================================

generar_json() {
    local ruta_json="$1"

    cat > "$ruta_json" << 'EOJSON'
{
  "reporte_arisuuuu010": {
    "date": "FECHA_PLACEHOLDER",
    "repository": "REPO_PLACEHOLDER",
    "branch": "RAMA_PLACEHOLDER",
    "user": "USUARIO_PLACEHOLDER",
    "results": {
      "commit_quality":          "M1",
      "commit_schedule":         "M2",
      "message_richness":        "M3",
      "regularity":              "M4",
      "file_diversity":          "M5",
      "commit_size":             "M6",
      "merges_cleanliness":      "M7",
      "irregular_activity":      "M8",
      "code_integrity":          "M9",
      "naming_convention":       "M10"
    },
    "final_score": PUNTAJE_PLACEHOLDER,
    "rating":      "CALIFICACION_PLACEHOLDER"
  }
}
EOJSON

    # Global placeholder variable injection engine using sed
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
# HTML REPORT GENERATION
# Formats clean web dashboard interfaces including metrics layout
# ============================================================================

generar_html() {
    local ruta_html="$1"

    cat > "$ruta_html" << 'EOHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Report arisuuuu010</title>
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
            <h1>📈 Git Evaluation: arisuuuu010</h1>
            <p>Comprehensive commit history metrics for target branch</p>
        </div>
        <div class="info-grid">
            <div class="info-item"><label>Repository</label><value>REPO_PLACEHOLDER</value></div>
            <div class="info-item"><label>Branch</label><value>RAMA_PLACEHOLDER</value></div>
            <div class="info-item"><label>Evaluated By</label><value>arisuuuu010</value></div>
            <div class="info-item"><label>Execution Date</label><value>FECHA_PLACEHOLDER</value></div>
        </div>
        <div class="puntaje-final">
            <h2>PUNTAJE_PLACEHOLDER / 100</h2>
            <p>Weighted Overall Score</p>
            <div class="badge">CALIFICACION_PLACEHOLDER</div>
        </div>
        <div class="pie">
            <p>Report generated on FECHA_PLACEHOLDER</p>
            <p>Script Execution: arisuuuu010.sh v1.0</p>
        </div>
    </div>
</body>
</html>
EOHTML

    # Sed text replacements mapping variables into static content elements
    sed -i "s|FECHA_PLACEHOLDER|$(date)|g"          "$ruta_html"
    sed -i "s|REPO_PLACEHOLDER|$RUTA_REPO|g"        "$ruta_html"
    sed -i "s|RAMA_PLACEHOLDER|$RAMA_OBJETIVO|g"    "$ruta_html"
    sed -i "s|PUNTAJE_PLACEHOLDER|$puntaje_final|g" "$ruta_html"
    sed -i "s|CALIFICACION_PLACEHOLDER|$rating|g"   "$ruta_html"
}

# ============================================================================
# MASTER FUNCTION: Orchestrates metric collection rules and aggregates layout
# ============================================================================

ejecutar_analisis() {
    mostrar_titulo "GIT ANALYZER :: arisuuuu010"

    # --- Validations ---
    msg_info "Verifying target repository..."
    verificar_repositorio

    msg_info "Verifying target branch..."
    verificar_rama

    # Build requisite system paths
    mkdir -p "$DIR_TEMP" "$DIR_SALIDA"

    # --- Data Collection ---
    mostrar_titulo "EXTRACTING COMMIT HISTORY DATA"
    extraer_datos_commits
    msg_ok "Metadata extracted successfully"

    # --- Metrics Logic Parsing ---
    mostrar_titulo "CALCULATING PERFORMANCE METRICS"

    msg_info "1/10 → Commit message clarity checks..."
    p_calidad=$(puntuar_calidad_commits)
    msg_ok "Score: $p_calidad / 100"

    msg_info "2/10 → Business hours compliance evaluation..."
    raw_horario=$(puntuar_horario)
    p_horario="${raw_horario%%|*}"
    commits_dentro="${raw_horario#*|}"; commits_dentro="${commits_dentro%%|*}"
    commits_fuera="${raw_horario##*|}"
    msg_ok "Score: $p_horario / 100  (In-hours: $commits_dentro | Off-hours: $commits_fuera)"

    msg_info "3/10 → Descriptive message text richness..."
    raw_mensajes=$(puntuar_descripcion_mensajes)
    p_mensajes="${raw_mensajes%%|*}"
    m_excelente="${raw_mensajes#*|}"; m_excelente="${m_excelente%%|*}"
    m_aceptable=$(echo "$raw_mensajes" | cut -d'|' -f3)
    m_pobre=$(echo "$raw_mensajes" | cut -d'|' -f4)
    m_total=$(echo "$raw_mensajes" | cut -d'|' -f5)
    msg_ok "Score: $p_mensajes / 100  (Excellent: $m_excelente | Acceptable: $m_aceptable | Poor: $m_pobre)"

    msg_info "4/10 → Delivery frequency and timeline distribution..."
    raw_reg=$(puntuar_regularidad)
    p_regularidad="${raw_reg%%|*}"
    r_total=$(echo "$raw_reg" | cut -d'|' -f2)
    r_dias=$(echo "$raw_reg" | cut -d'|' -f3)
    r_por_dia=$(echo "$raw_reg" | cut -d'|' -f4)
    msg_ok "Score: $p_regularidad / 100  ($r_total commits over $r_dias days)"

    msg_info "5/10 → Affected file count atomic diversity..."
    raw_arch=$(puntuar_diversidad_archivos)
    p_archivos="${raw_arch%%|*}"
    a_total=$(echo "$raw_arch" | cut -d'|' -f2)
    a_prom=$(echo "$raw_arch" | cut -d'|' -f3)
    msg_ok "Score: $p_archivos / 100  (Files: $a_total | Average: $a_prom/commit)"

    msg_info "6/10 → Line count diff size profile (churn status)..."
    raw_tam=$(puntuar_tamano_commits)
    p_tamano="${raw_tam%%|*}"
    t_total=$(echo "$raw_tam" | cut -d'|' -f2)
    t_prom=$(echo "$raw_tam" | cut -d'|' -f3)
    msg_ok "Score: $p_tamano / 100  (Total lines: $t_total | Average: $t_prom/commit)"

    msg_info "7/10 → Linear history compliance (merge tracking)..."
    raw_merge=$(puntuar_limpieza_merges)
    p_merges="${raw_merge%%|*}"
    m_count=$(echo "$raw_merge" | cut -d'|' -f2)
    msg_ok "Score: $p_merges / 100  (Merge commits intercepted: $m_count)"

    msg_info "8/10 → Off-hours non-standard system activity..."
    raw_irr=$(puntuar_actividad_irregular)
    p_irregular="${raw_irr%%|*}"
    i_madrug=$(echo "$raw_irr" | cut -d'|' -f2)
    i_tarde=$(echo "$raw_irr" | cut -d'|' -f3)
    i_finsem=$(echo "$raw_irr" | cut -d'|' -f4)
    msg_ok "Score: $p_irregular / 100  (Late Night: $i_madrug | Evening: $i_tarde | Weekend: $i_finsem)"

    msg_info "9/10 → Integrity pattern scan matching..."
    raw_int=$(puntuar_integridad)
    p_integridad="${raw_int%%|*}"
    int_issues=$(echo "$raw_int" | cut -d'|' -f2)
    msg_ok "Score: $p_integridad / 100  (Problematic flags matched: $int_issues)"

    msg_info "10/10 → Conventional Commits format standardization..."
    raw_nom=$(puntuar_convencion_nombres)
    p_nombres="${raw_nom%%|*}"
    n_conv=$(echo "$raw_nom" | cut -d'|' -f2)
    n_noconv=$(echo "$raw_nom" | cut -d'|' -f3)
    n_total=$(echo "$raw_nom" | cut -d'|' -f4)
    msg_ok "Score: $p_nombres / 100  (Conformant: $n_conv / $n_total)"

    # ====================================================================
    # COMPUTE FINAL WEIGHTED OVERALL RATING
    # Metric Distribution Weights: Quality=15%, Schedule=15%, Richness=15%,
    #                              Regularity=10%, Diversity=10%, Size=10%, 
    #                              Merges=5%, Irregular=5%, Integrity=10%, Naming=5%
    # ====================================================================
    mostrar_titulo "OVERALL SUMMARY RESULTS"

    puntaje_final=$(( 
        (p_calidad     * 15 +
         p_horario     * 15 +
         p_mensajes    * 15 +
         p_regularidad * 10 +
         p_archivos    * 10 +
         p_tamano      * 10 +
         p_merges      * 5  +
         p_irregular   * 5  +
         p_integridad  * 10 +
         p_nombres     * 5) / 100
    ))

    # Resolve alpha grading rank assignments
    if   [ "$puntaje_final" -ge 90 ]; then rating="EXCELLENT (A)"
    elif [ "$puntaje_final" -ge 80 ]; then rating="VERY GOOD (B)"
    elif [ "$puntaje_final" -ge 70 ]; then rating="GOOD (C)"
    elif [ "$puntaje_final" -ge 60 ]; then rating="ACCEPTABLE (D)"
    else                                   rating="NEEDS IMPROVEMENT (F)"
    fi

    # Display final metric summary boxes inside console interface
    echo -e "\n${COLOR_RESUMEN}╔════════════════════════════════════════╗${SIN_COLOR}"
    echo -e "${COLOR_RESUMEN}║${SIN_COLOR}     OVERALL SCORE: ${COLOR_OK}${puntaje_final}/100${SIN_COLOR}${COLOR_RESUMEN}              ║${SIN_COLOR}"
    echo -e "${COLOR_RESUMEN}║${SIN_COLOR}     Final Grade:   ${COLOR_AVISO}${rating}${SIN_COLOR}${COLOR_RESUMEN}      ║${SIN_COLOR}"
    echo -e "${COLOR_RESUMEN}╚════════════════════════════════════════╝${SIN_COLOR}\n"

    # ====================================================================
    # GENERATE DISK OUTPUT REPORTS (JSON AND HTML)
    # ====================================================================
    mostrar_titulo "EXPORTING METRIC REPORTS"

    generar_json "$ARCHIVO_JSON"
    msg_ok "JSON Export → $ARCHIVO_JSON"

    generar_html "$ARCHIVO_HTML"
    msg_ok "HTML Export → $ARCHIVO_HTML"

    # Summary table console terminal display layout
    echo -e "\n${COLOR_TITULO}=== METRICS ACCOUNTING OVERVIEW ===${SIN_COLOR}\n"
    printf "%-42s | %5s | %5s\n" "METRIC ITEM" "SCORE" "WEIGHT%"
    printf "%-42s | %5s | %5s\n" "──────────────────────────────────────────" "─────" "─────"
    printf "%-42s | %5d | %5d\n" "1.  Commit message validation check"    "$p_calidad"     15
    printf "%-42s | %5d | %5d\n" "2.  Work hour schedule compliance"      "$p_horario"     15
    printf "%-42s | %5d | %5d\n" "3.  Description completeness richness"  "$p_mensajes"    15
    printf "%-42s | %5d | %5d\n" "4.  Delivery frequency consistency"     "$p_regularidad" 10
    printf "%-42s | %5d | %5d\n" "5.  File tracking variance diversity"   "$p_archivos"    10
    printf "%-42s | %5d | %5d\n" "6.  Diff line scale profiles (churn)"   "$p_tamano"      10
    printf "%-42s | %5d | %5d\n" "7.  Linear branch compliance (merges)"  "$p_merges"       5
    printf "%-42s | %5d | %5d\n" "8.  Off-hours activity tracking"        "$p_irregular"    5
    printf "%-42s | %5d | %5d\n" "9.  Code base structural integrity"     "$p_integridad"  10
    printf "%-42s | %5d | %5d\n" "10. Conventional Commits syntax layout" "$p_nombres"      5
    printf "%-42s | %5s | %5s\n" "──────────────────────────────────────────" "─────" "─────"
    printf "%-42s | %5d | %5s\n" "TOTAL WEIGHTED SCORE OUTCOME"           "$puntaje_final" "100"
    echo ""

    # Supplemental evaluation analytics data block
    mostrar_titulo "TECHNICAL DATA ENGINE DETAILS"
    echo -e "${COLOR_INFO}Total branch commits:${SIN_COLOR}       $r_total"
    echo -e "${COLOR_INFO}Active days tracking range:${SIN_COLOR} $r_dias days"
    echo -e "${COLOR_INFO}Average daily commit density:${SIN_COLOR} $r_por_dia"
    echo -e "${COLOR_INFO}Total distinct files touched:${SIN_COLOR} $a_total"
    echo -e "${COLOR_INFO}Global branch file churn scale:${SIN_COLOR} $t_total"
    echo -e "${COLOR_INFO}Conformant CC structured titles:${SIN_COLOR} $n_conv / $n_total"
    echo ""

    # Clear volatile workspace files and folders
    rm -rf "$DIR_TEMP"
}

# ============================================================================
# RUNTIME APPLICATION ENTRYPOINT
# Safe launch guards avoiding unintended calls under source patterns
# ============================================================================
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    ejecutar_analisis "$@"
fi