# ============================================================================
#  Dockerfile — "receta" para construir la imagen del curso
# ============================================================================
#  Un Dockerfile es un archivo de texto con instrucciones paso a paso que
#  Docker (o Codespaces) lee de arriba hacia abajo para fabricar una
#  "imagen". Una imagen es como un molde congelado de un sistema Linux
#  listo para usar; cada vez que abres el Codespace, se crea un
#  "contenedor" a partir de ese molde.
#
#  Analogía: la imagen es el PLANO, el contenedor es la CASA construida
#  con ese plano. Puedes construir muchas casas iguales a partir de un
#  solo plano, y si destruyes una casa el plano sigue intacto.
#
#  Cada instrucción (FROM, ENV, RUN...) crea una "capa". Docker guarda
#  esas capas en caché: si no cambias las primeras líneas, no las
#  reconstruye y el siguiente build es casi instantáneo.
# ============================================================================


# ============================================================================
# Block a: Base Image Definition
# ============================================================================
# The FROM instruction specifies the foundation layer of our environment.
# We utilize kalilinux/kali-rolling:latest as it provides a continuously updated 
# platform packed with pre-installed cybersecurity tools and networking analysis suites, 
# preventing us from setting up these binary utilities from scratch (BHB Ch. 3).
FROM kalilinux/kali-rolling:latest

# ============================================================================
# Block b: Instruction Order & Docker Layer Cache
# ============================================================================
# Docker builds its images incrementally using a read-only architecture where each instruction 
# creates a new "layer" (BHB Ch. 3). If any instruction changes, Docker invalidates the cache 
# from that point downward. Static configurations like image selection and core variables, help us to i 
# improve the way to optimized future run times and avoid redundant execution steps..


# ============================================================================
# Block c: System Environment Variables (ENV)
# ============================================================================
# Environment variables act as systemic key-value properties parsed globally by active shells (BHB Ch. 1).
# - DEBIAN_FRONTEND=noninteractive: Suppresses graphical prompt windows from apt-get, ensuring an 
#   automated headless compilation without unexpected execution freezes.
# - LANG & LC_ALL: Standardizes standard language configurations to support Spanish UTF-8 text rendering.
# - TERM=xterm-256color: Instructs CLI tools like vim or htop to utilize full 256-bit palette color structures.
# Note: The backslash '\' represents line continuation, grouping items cleanly for better shell formatting (BHB Ch. 1).
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=es_ES.UTF-8 \
    LC_ALL=es_ES.UTF-8 \
    TERM=xterm-256color


# ============================================================================
# Block d: Automated Package Selection Pre-answering
# ============================================================================
# The 'debconf-set-selections' command passes system configurations directly into the software database.
# By feeding standard input via a pipe sequence '|' (BHB Ch. 1), we preemptively answer Wireshark's 
# non-root access queries as 'false', it helps to have more  fluency.
RUN echo "wireshark-common wireshark-common/install-setuid boolean false" \
    | debconf-set-selections



# ============================================================================
# Block e: Package Synchronization and Binary Execution
# ============================================================================
# This big RUN command updates and installs all the software we need for the course.
# - 'apt-get update' updates the list of available packages.
# - 'apt-get install' downloads and installs the tools.
# - The '-y' flag says 'yes' automatically to all questions.
# - '--no-install-recommends' does not install extra packages, so the image stays small.
# - We connect all commands with '&&' (BHB Ch. 1). This means the next command runs 
#   only if the previous command is successful.
# - We use ONE single RUN command to have fewer layers. This makes the final image 
#   much smaller and faster to download (BHB Ch. 3).
# Important tools in this block:
#   * grep, sed, gawk: Text processing tools to filter and change text (BHB Ch. 2).
#   * shellcheck: A tool to find errors and bad practices in my Bash scripts (BHB Ch. 1).
#   * nmap, tcpdump, tshark: Tools for network scanning and capturing packets (BHB Ch. 3).
#   * tor, proxychains4: Privacy tools to hide my identity and traffic on the network.
#   * jq: A tool to read and filter JSON data from the command line.
#   * man-db: Installs the Linux manual pages so I can use the 'man' command for help.

# ----------------------------------------------------------------------------
# RUN: ejecutar comandos durante la construcción de la imagen
# ----------------------------------------------------------------------------
# Aquí instalamos TODO el software del curso en un solo RUN.
#
#   apt-get update          -> actualiza la lista de paquetes disponibles
#   apt-get install         -> descarga e instala los paquetes listados
#     -y                    -> responde "sí" automáticamente
#     --no-install-recommends -> instala SOLO lo esencial (no los extras
#                                sugeridos). Ahorra cientos de MB.
#
# ¿Por qué un solo RUN gigante y no 10 RUN pequeños?
# Porque CADA RUN crea una capa nueva en la imagen. Menos capas = imagen
# más pequeña, más rápida de construir y de descargar.
#
# El "&&" encadena comandos: ejecuta el siguiente SOLO SI el anterior
# terminó bien. Si algo falla, el build se detiene con error (que es lo
# que queremos: mejor un error claro que una imagen rota).
RUN apt-get update && apt-get install -y --no-install-recommends \
    \
    # === Editores de texto y shells (intérpretes de comandos) ===
    neovim \
    vim \
    zsh \
    bash-completion \
    \
    # === Herramientas de 4ta generación ===
    # Estas son las protagonistas de las Unidades 2, 3 y 4:
    perl \
    make \
    gawk \
    sed \
    grep \
    \
    # === Utilidades básicas de UNIX ===
    # coreutils trae cat, ls, head, tail, sort, cut, tr, etc.
    # findutils trae find y xargs.
    # procps trae ps, top, kill (gestión de procesos).
    # less = paginador para leer archivos largos.
    # tree = muestra directorios como árbol.
    # jq = procesa JSON desde la línea de comandos.
    coreutils \
    findutils \
    procps \
    less \
    tree \
    jq \
    \
    # === Páginas de manual (comando `man`) ===
    # La imagen base de Kali viene sin documentación para
    # ahorrar espacio. La reinstalamos porque en el curso "man bash" o
    # "man grep" es material de consulta obligada.
    man-db \
    manpages \
    manpages-posix \
    \
    # === Red básica y utilidades de descarga ===
    curl \
    wget \
    git \
    git-lfs \
    ca-certificates \
    locales \
    \
    # === Linter (revisor automático de errores) para scripts Bash ===
    shellcheck \
    \
    # === Reconocimiento y escaneo de red ===
    # nmap = el escáner de puertos más famoso.
    # masscan = escaneo masivo de rangos grandes de IPs.
    nmap \
    masscan \
    \
    # === Captura y análisis de paquetes de red ===
    # tcpdump = capturador clásico por terminal.
    # tshark = versión de terminal de Wireshark.
    tcpdump \
    tshark \
    \
    # === Utilidades de red variadas ===
    netcat-traditional \
    socat \
    dnsutils \
    whois \
    traceroute \
    mtr-tiny \
    iproute2 \
    net-tools \
    iputils-ping \
    \
    # === Anonimato: Tor y similares ===
    # tor = cliente de la red Tor.
    # torsocks = "envoltorio" que hace pasar cualquier comando por Tor.
    # proxychains4 = encadena múltiples proxies.
    # obfs4proxy = ofusca el tráfico de Tor para evadir bloqueos.
    tor \
    torsocks \
    proxychains4 \
    obfs4proxy \
    \
    # === Cliente HTTP más legible que curl para aprender ===
    httpie \
    \
 # ============================================================================
# Block f: In-Place Text Processing & Locale Compilation
# ============================================================================
# The 'sed -i' flag initiates an interactive, in-place substitution operation directly across text streams (BHB Ch. 2).
# It uncomments the Spanish locale marker inside '/etc/locale.gen', allowing 'locale-gen' to run 
# localized translation sets across the system layout.
 && sed -i 's/# es_ES.UTF-8/es_ES.UTF-8/' /etc/locale.gen \
 && locale-gen \
 \
# ============================================================================
# Block g: Cache Maintenance and Container Optimization
# ============================================================================
# Executing 'apt-get clean' along with 'rm -rf' flushes out transient installation tracking metadata. 
# Purging these assets inside the exact same RUN directive ensures that heavy install (BHB Ch. 3).
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# ============================================================================
# Block h: Active Processing Shell Override
# ============================================================================
# Modifies Docker's background command shell mechanism for any subsequent RUN tasks.
# We can use /bin/bash when we need more tools to execute into the container(BHB Ch. 1).
SHELL ["/bin/bash", "-c"]


# ============================================================================
# Block i: Workspace Mount Directives (WORKDIR)
# ============================================================================
# Sets the structural absolute root index '/workspaces' as the primary execution directory. 
# Any subsequent runtime sessions or editor interactions default directly to this directory path.
WORKDIR /workspaces

# ============================================================================
# Block j: Git LFS Parameter Initialization
# ============================================================================
# Uses system flags to lock general tracking variables for all repository work paths.
# It updates default tracking branches to 'main', prevents divergence warnings


RUN git config --system --add safe.directory '*' \
 && git config --system init.defaultBranch main \
 && git config --system pull.rebase false \
 && git lfs install --system

# ============================================================================
# Block k: User Privilege Shell Switch
# ============================================================================
# The 'chsh' utility manipulates execution profiles. Here, it targets the elevated 'root' 
# profile, converting its default shell configuration over to Zsh instead of traditional Bash.
RUN chsh -s /usr/bin/zsh root

RUN cat>> /root/.zshrc <<'EOF'

PROMPT='%F{cyan}[Ariel_Yumbillo]%f %F{yellow}%1~%f %(?.%F{green}ok%f.%F{red}notok %?%f) %# '
EOF

CMD ["/usr/bin/zsh"]



