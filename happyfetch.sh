#!/usr/bin/env bash

. /etc/os-release 2>/dev/null

kernel="$(cat /proc/sys/kernel/osrelease 2>/dev/null)"
cpu="$(grep -m1 '^model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ *//')"
mem="$(awk '/MemTotal:/ {printf "%.1f GB", $2/1024/1024}' /proc/meminfo)"

de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
wm="${WINDOWMANAGER:-unknown}"

gpu_list=()

if command -v lspci >/dev/null 2>&1; then
    while IFS= read -r line; do
        gpu_list+=("$line")
    done < <(lspci | grep -Ei "vga|3d|display" | sed -E '
        s/.*: //;
        s/Advanced Micro Devices, Inc\./AMD/;
        s/Intel Corporation/Intel/;
        s/NVIDIA Corporation/NVIDIA/;
        s/\(.*\)//g;
        s/  +/ /g;
    ')
fi

if [ ${#gpu_list[@]} -eq 0 ]; then
    gpu_list=("Unknown GPU")
fi

tux=(
"   .--."
"  |o_o |"
"  |:_/ |"
" //   \\ \\"
"(|     | )"
"/'\\_   _/\\"
"\\___)=(___/"
)

info=(
"OS: ${PRETTY_NAME:-Linux}"
"Kernel: $kernel"
"CPU: $cpu"
"Memory: $mem"
"DE/WM: ${de:-unknown}/${wm:-unknown}"
)

max=${#tux[0]}

for l in "${tux[@]}"; do
    (( ${#l} > max )) && max=${#l}
done

max_lines=$(( ${#tux[@]} > ${#info[@]} ? ${#tux[@]} : ${#info[@]} ))

gpu_i=1

for ((i=0; i<max_lines; i++)); do
    left="${tux[$i]}"

    if [ $i -lt ${#info[@]} ]; then
        right="${info[$i]}"
    else
        if [ $gpu_i -le ${#gpu_list[@]} ]; then
            right="GPU($gpu_i): ${gpu_list[$((gpu_i-1))]}"
            ((gpu_i++))
        else
            right=""
        fi
    fi

    printf "%-*s  %s\n" "$max" "$left" "$right"
done
