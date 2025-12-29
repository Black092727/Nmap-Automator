#!/bin/bash

echo -e "${RED}"
echo "███╗   ██╗███╗   ███╗ █████╗ ██████╗ "
echo "████╗  ██║████╗ ████║██╔══██╗██╔══██╗"
echo "██╔██╗ ██║██╔████╔██║███████║██████╔╝"
echo "██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝ "
echo "██║ ╚████║██║ ╚═╝ ██║██║  ██║██║     "
echo "╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     "
echo -e "${YELLOW}        Made by Light Bringer${NC}"
echo
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

TARGET="$1"
TYPE="$2"
OUTPUT="nmap-$TARGET"

usage() {
    echo -e ""
    echo -e "${RED}Usage: $0 <TARGET-IP> <TYPE>${NC}"
    echo -e "${YELLOW}"
    echo -e "Scan Types:"
    echo -e "\tQuick   : Fast TCP scan"
    echo -e "\tBasic   : Quick + version & script scan"
    echo -e "\tUDP     : UDP scan"
    echo -e "\tFull    : Full port scan"
    echo -e "\tVulns   : Vulnerability scan"
    echo -e "\tAll     : Run all scans"
    echo -e "${NC}"
    exit 1
}

check_args() {
    if [[ -z "$TARGET" || -z "$TYPE" ]]; then
        usage
    fi
}

quick_scan() {
    echo -e "${GREEN}[+] Running Quick scan${NC}"
    nmap -T5 -F "$TARGET" -oN "$OUTPUT-quick.txt"
}

basic_scan() {
    echo -e "${GREEN}[+] Running Basic Scan${NC}"
    nmap -T4 -F "$TARGET" -oG "$OUTPUT-ports.gnmap"

    PORTS=$(grep "/open/" "$OUTPUT-ports.gnmap" | cut -d "/" -f1 | tr '\n' ',' | sed 's/,$//')

    if [[ -n "$PORTS" ]]; then
        nmap -sC -sV -p "$PORTS" "$TARGET" -oN "$OUTPUT-basic.txt"
    fi
}

udp_scan() {
    echo -e "${GREEN}[+] Running UDP Scan${NC}"
    nmap -sU --top-ports 100 "$TARGET" -oN "$OUTPUT-udp.txt"
}

full_scan() {
    echo -e "${GREEN}[+] Running Full Port Scan${NC}"
    nmap -p- -T4 "$TARGET" -oG "$OUTPUT-full.gnmap"

    PORTS=$(grep "/open/" "$OUTPUT-full.gnmap" | cut -d "/" -f1 | tr '\n' ',' | sed 's/,$//')

    if [[ -n "$PORTS" ]]; then
        nmap -sC -sV -p "$PORTS" "$TARGET" -oN "$OUTPUT-full-detail.txt"
    fi
}

vuln_scan() {
    echo -e "${GREEN}[+] Running Vulnerability Scan${NC}"
    nmap --script vuln "$TARGET" -oN "$OUTPUT-vulns.txt"
}

all_scans() {
    quick_scan
    basic_scan
    udp_scan
    full_scan
    vuln_scan
}

check_args

case "$TYPE" in
    Quick|quick)
        quick_scan
        ;;
    Basic|basic)
        basic_scan
        ;;
    UDP|udp)
        udp_scan
        ;;
    Full|full)
        full_scan
        ;;
    Vulns|vulns)
        vuln_scan
        ;;
    All|all)
        all_scans
        ;;
    *)
        usage
        ;;
esac
