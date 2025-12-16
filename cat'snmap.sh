#!/usr/bin/env bash
# ==============================================================================
#  Cat's NMAP 1.0A 🐾
#  Author : ChatGPT + Catsan
#  License: GNU Lesser General Public License v3.0 or later (LGPL-3.0+)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------------------
#  PURPOSE
# ------------------------------------------------------------------------------
#  A friendly, readable, modular Nmap automation wrapper for:
#   • learning
#   • labs
#   • defensive recon
#   • home / test networks
#
#  REQUIREMENTS:
#   - bash 4+
#   - nmap
#
#  USAGE:
#   chmod +x cats_nmap_1.0A.sh
#   ./cats_nmap_1.0A.sh <target> [profile]
#
#  PROFILES:
#   quick     → Fast scan, common ports
#   full      → Full TCP scan + version detection
#   stealth   → SYN scan, slow timing
#   vuln      → Vulnerability NSE scripts
#   udp       → UDP scan (slow)
#   all       → TCP + UDP + NSE (very slow)
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------------------------
OUTPUT_DIR="./nmap_results"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
NMAP_BIN="$(command -v nmap)"

# ------------------------------------------------------------------------------
# SANITY CHECKS
# ------------------------------------------------------------------------------
if [[ -z "${NMAP_BIN}" ]]; then
    echo "[!] nmap not found. Please install nmap."
    exit 1
fi

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <target> [profile]"
    exit 1
fi

TARGET="$1"
PROFILE="${2:-quick}"
OUTFILE="${OUTPUT_DIR}/${TARGET//[^a-zA-Z0-9._-]/_}_${PROFILE}_${TIMESTAMP}"

mkdir -p "${OUTPUT_DIR}"

# ------------------------------------------------------------------------------
# BANNER
# ------------------------------------------------------------------------------
cat <<'EOF'
╔══════════════════════════════════════╗
║        🐱 Cat's NMAP 1.0A            ║
║   ChatGPT + Catsan — LGPL v3+        ║
╚══════════════════════════════════════╝
EOF

echo "[*] Target : ${TARGET}"
echo "[*] Profile: ${PROFILE}"
echo "[*] Output : ${OUTFILE}"
echo

# ------------------------------------------------------------------------------
# SCAN PROFILES
# ------------------------------------------------------------------------------
case "${PROFILE}" in
    quick)
        nmap -T4 -F "${TARGET}" -oA "${OUTFILE}"
        ;;
    full)
        nmap -T4 -p- -sV -sC "${TARGET}" -oA "${OUTFILE}"
        ;;
    stealth)
        sudo nmap -sS -T2 -p- "${TARGET}" -oA "${OUTFILE}"
        ;;
    vuln)
        nmap -sV --script vuln "${TARGET}" -oA "${OUTFILE}"
        ;;
    udp)
        sudo nmap -sU --top-ports 200 "${TARGET}" -oA "${OUTFILE}"
        ;;
    all)
        sudo nmap -sS -sU -p- -sV -sC --script vuln "${TARGET}" -oA "${OUTFILE}"
        ;;
    *)
        echo "[!] Unknown profile: ${PROFILE}"
        echo "    Valid: quick | full | stealth | vuln | udp | all"
        exit 1
        ;;
esac

# ------------------------------------------------------------------------------
# DONE
# ------------------------------------------------------------------------------
echo
echo "[✓] Scan complete."
echo "[✓] Results saved as:"
echo "    ${OUTFILE}.nmap"
echo "    ${OUTFILE}.xml"
echo "    ${OUTFILE}.gnmap"
