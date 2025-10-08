#!/bin/bash

target="$1"
output_base="nmap-initiate"
current_path=$(pwd)

echo $current_path

echo "==== TCP Port Scan (Full) ===="
/usr/bin/nmap -sS -p- -T4 -Pn "$target" -oA "${current_path}/${output_base}_tcp_init" -v

echo "==== UDP Port Scan (Top 100) ===="
/usr/bin/nmap -sU --top-ports 100 -T4 -Pn "$target" -oA "${current_path}/${output_base}_udp_init" -v

echo "==== Filter Ports ===="
# Filter TCP ports
port_range_tcp=$(grep "Ports:" "${current_path}/${output_base}_tcp_init.gnmap" | grep "open" | \
  sed -n 's/.*Ports: \(.*\)/\1/p' | tr ',' '\n' | grep '/open/tcp' | \
  cut -d '/' -f1 | sed 's/^ *//' | sort -n | uniq | paste -sd,)

# Filter UDP ports
port_range_udp=$(grep "Ports:" "${current_path}/${output_base}_udp_init.gnmap" | grep "open" | \
  sed -n 's/.*Ports: \(.*\)/\1/p' | tr ',' '\n' | grep '/open/udp' | \
  cut -d '/' -f1 | sed 's/^ *//' | sort -n | uniq | paste -sd,)

echo "TCP Ports: $port_range_tcp"
echo "UDP Ports: $port_range_udp"

echo "==== Scan Port Detail ===="

# TCP Detail Scan
if [[ -n "$port_range_tcp" ]]; then
  echo "→ TCP detail scan"
  /usr/bin/nmap -A -sS -T4 -Pn "$target" -oN "${current_path}/${output_base}_tcp.txt" --stats-every=1m -p "$port_range_tcp"
fi

# UDP Detail Scan
if [[ -n "$port_range_udp" ]]; then
  echo "→ UDP detail scan"
  /usr/bin/nmap -A -sU -T4 -Pn "$target" -oN "${current_path}/${output_base}_udp.txt" --stats-every=1m -p "$port_range_udp"
fi

rm -f "${current_path}/${output_base}_udp_init".*
rm -f "${current_path}/${output_base}_tcp_init".*

echo "==== Done ===="
