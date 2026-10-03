#!/usr/bin/env bash
# ============================================================
#  EX-YU Calendar - instalacija za Linux i macOS
#  Koristenje:
#    curl -fsSL https://raw.githubusercontent.com/vanjamihalicc-spec/ex-yu-calendar/main/install.sh | bash
# ============================================================
set -uo pipefail

REPO="vanjamihalicc-spec/ex-yu-calendar"
BRANCH="main"   # promijeni u "master" ako koristi tu granu
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"

CAL_DIR="$HOME/.calendar"
CAL_FILE="$CAL_DIR/calendar"
BIN_DIR="$HOME/.local/bin"
WRAPPER="$BIN_DIR/exyu-calendar"

say()  { printf '\033[1;32m[+]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m[-]\033[0m %s\n' "$1" >&2; exit 1; }

# ---------- 1) Provjere i detekcija OS-a ----------
OS="$(uname -s)"
case "$OS" in
  Linux*)  PLATFORM="linux" ;;
  Darwin*) PLATFORM="macos" ;;
  *)       die "Nepodrzani operativni sustav: $OS" ;;
esac
say "Detektiran sustav: $PLATFORM"

command -v python3 >/dev/null || die "Treba ti python3 (Linux: sudo apt install python3 / macOS: xcode-select --install)"

# macOS dolazi s vlastitim BSD calendar-om koji vec zna cita ~/.calendar,
# pa curl nije obavezan ako postoji wget.
DL=""
if command -v curl >/dev/null; then DL="curl -fsSL -o"
elif command -v wget >/dev/null; then DL="wget -qO"
else die "Treba ti curl ili wget"; fi

# ---------- 2) Preuzmi calendar.nob ----------
TMP_NOB=$(mktemp) || die "mktemp nije uspio"
trap 'rm -f "$TMP_NOB"' EXIT
say "Preuzimam calendar.nob..."
$DL "$TMP_NOB" "$BASE/calendar.nob" || die "Ne mogu preuzeti calendar.nub iz repo-a."

# ---------- 3) Konvertuj datume u ISO YYYY-MM-DD ----------
say "Konvertiram datume..."
TMP_OUT=$(mktemp) || die "mktemp nije uspio"
python3 - "$TMP_NOB" > "$TMP_OUT" << 'PYEOF' || { rm -f "$TMP_OUT"; die "Konverzija nije uspjela"; }
import sys, re, datetime
M = {'sij':'01','vel':'02','ozu':'03','tra':'04','svi':'05','lip':'06',
     'srp':'07','kol':'08','ruj':'09','lis':'10','stu':'11','pro':'12'}
def norm(s):
    return (s.lower().replace('č','c').replace('ć','c').replace('š','s')
             .replace('đ','d').replace('ž','z'))
year = datetime.date.today().year
for line in open(sys.argv[1], encoding='utf-8'):
    raw = line.rstrip('\n')
    if not raw.strip():
        continue
    m = re.match(r'^\s*(\w+)\s+(\d{1,2})\s+(.*)$', raw)
    if m and norm(m.group(1)) in M:
        print(f"{year}-{M[norm(m.group(1))]}-{int(m.group(2)):02d}\t{m.group(3)}")
    elif re.match(r'^\s*\d{4}-\d{2}-\d{2}', raw):
        print(raw)
PYEOF

mkdir -p "$CAL_DIR"
mv "$TMP_OUT" "$CAL_FILE"
say "Datoteke spremljene u $CAL_FILE"

# ---------- 4) Wrapper koji javi kad nema dogadjaja ----------
mkdir -p "$BIN_DIR"
cat > "$WRAPPER" << 'WRAP'
#!/usr/bin/env bash
out=$(LC_ALL=C calendar -f "$HOME/.calendar/calendar" 2>/dev/null)
if [ -z "$out" ]; then echo "Nema događaja danas."; else echo "$out"; fi
WRAP
chmod +x "$WRAPPER"

# ---------- 5) Alias (bez dupliranja) ----------
LINE='alias calendar="$HOME/.local/bin/exyu-calendar"'
RC="$HOME/.bashrc"
[ "$PLATFORM" = "macos" ] && RC="$HOME/.zshrc"   # macOS default shell je zsh
touch "$RC"
if grep -qxF "$LINE" "$RC"; then
  warn "Alias vec postoji u $(basename "$RC") preskacem."
else
  { echo ''; echo '# ex-yu-calendar'; echo "$LINE"; } >> "$RC"
  say "Alias dodan u $(basename "$RC")"
fi

# macOS: osiguraj da ~/.local/bin bude u PATH-u
if [ "$PLATFORM" = "macos" ] && ! grep -q '.local/bin' "$RC"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
  say "Dodan ~/.local/bin u PATH"
fi

# ---------- 6) Kraj ----------
echo ""
say "Gotovo!"
echo "Za trenutni terminal:   source ~/${RC##*/}"
echo "Za provjeru:            calendar"
