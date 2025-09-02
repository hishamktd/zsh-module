#!/usr/bin/env zsh
# Network Module - Network utilities and tools

# Clear any existing aliases to avoid conflicts
unalias p dl serve ping download httpserver nslookup whois 2>/dev/null || true

# Enhanced ping with better output
ping() {
    local host="$1"
    local count="${2:-4}"
    
    if [[ -z "$host" ]]; then
        echo "❌ Host required"
        echo "Usage: ping host [count]"
        return 1
    fi
    
    echo "🏓 Pinging $host..."
    command ping -c "$count" "$host"
}

# HTTP status checker
httpstatus() {
    local url="$1"
    if [[ -z "$url" ]]; then
        echo "❌ URL required"
        echo "Usage: httpstatus https://example.com"
        return 1
    fi
    
    # Add https:// if no protocol specified
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="https://$url"
    fi
    
    echo "🌐 Checking HTTP status for $url..."
    
    if zmod_has_command curl; then
        local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        local time=$(curl -s -o /dev/null -w "%{time_total}" "$url")
        
        echo "  Status: $status"
        echo "  Response time: ${time}s"
        
        case "$status" in
            200) echo "  ✅ OK" ;;
            301|302) echo "  🔄 Redirect" ;;
            404) echo "  ❌ Not Found" ;;
            500) echo "  💥 Server Error" ;;
            *) echo "  ❓ Unknown status" ;;
        esac
    else
        echo "❌ curl not available"
        return 1
    fi
}

# Download with progress
download() {
    local url="$1"
    local output="$2"
    
    if [[ -z "$url" ]]; then
        echo "❌ URL required"
        echo "Usage: download URL [output_file]"
        return 1
    fi
    
    if zmod_has_command curl; then
        if [[ -n "$output" ]]; then
            curl -L --progress-bar -o "$output" "$url"
        else
            curl -L --progress-bar -O "$url"
        fi
    elif zmod_has_command wget; then
        if [[ -n "$output" ]]; then
            wget --progress=bar -O "$output" "$url"
        else
            wget --progress=bar "$url"
        fi
    else
        echo "❌ No download tool available (curl/wget)"
        return 1
    fi
}

# Speed test
speedtest() {
    echo "🚀 Testing internet speed..."
    
    if zmod_has_command speedtest-cli; then
        speedtest-cli
    elif zmod_has_command curl; then
        echo "  Download test (10MB file):"
        local start_time=$EPOCHREALTIME
        curl -s -o /dev/null http://speedtest.tele2.net/10MB.zip
        local end_time=$EPOCHREALTIME
        local duration=$(( end_time - start_time ))
        local speed=$(( 80 / duration )) # 10MB = 80Mbits
        echo "  Speed: ${speed}Mbps (approx)"
    else
        echo "❌ No speed test tool available"
        echo "Install speedtest-cli: pip install speedtest-cli"
        return 1
    fi
}

# Network interface information
netinfo() {
    echo "🌐 Network Interface Information:"
    
    if zmod_has_command ip; then
        ip addr show | grep -E "^[0-9]+:|inet " | while read line; do
            if [[ "$line" =~ ^[0-9]+: ]]; then
                echo "  $(echo "$line" | cut -d: -f2 | cut -d@ -f1)"
            elif [[ "$line" =~ inet ]]; then
                local addr=$(echo "$line" | awk '{print $2}')
                echo "    IP: $addr"
            fi
        done
    else
        ifconfig | grep -E "^[a-zA-Z]|inet " | while read line; do
            if [[ ! "$line" =~ ^[[:space:]] ]]; then
                echo "  $(echo "$line" | cut -d: -f1)"
            elif [[ "$line" =~ inet ]]; then
                local addr=$(echo "$line" | awk '{print $2}')
                echo "    IP: $addr"
            fi
        done
    fi
}

# DNS lookup
nslookup() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        echo "❌ Domain required"
        echo "Usage: nslookup domain.com"
        return 1
    fi
    
    echo "🔍 DNS Lookup for $domain:"
    
    if zmod_has_command dig; then
        echo "  A Records:"
        dig +short A "$domain"
        echo "  MX Records:"
        dig +short MX "$domain"
        echo "  NS Records:"
        dig +short NS "$domain"
    elif zmod_has_command host; then
        host "$domain"
    else
        echo "❌ No DNS lookup tool available (dig/host)"
        return 1
    fi
}

# SSL certificate check
sslcheck() {
    local domain="$1"
    local port="${2:-443}"
    
    if [[ -z "$domain" ]]; then
        echo "❌ Domain required"
        echo "Usage: sslcheck domain.com [port]"
        return 1
    fi
    
    echo "🔐 SSL Certificate check for $domain:$port"
    
    if zmod_has_command openssl; then
        echo | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | openssl x509 -noout -dates -subject -issuer
    else
        echo "❌ OpenSSL not available"
        return 1
    fi
}

# Simple HTTP server
httpserver() {
    local port="${1:-8000}"
    local dir="${2:-.}"
    
    echo "🌐 Starting HTTP server on port $port in directory $dir"
    echo "  URL: http://localhost:$port"
    
    if zmod_has_command python3; then
        cd "$dir" && python3 -m http.server "$port"
    elif zmod_has_command python; then
        cd "$dir" && python -m SimpleHTTPServer "$port"
    elif zmod_has_command ruby; then
        cd "$dir" && ruby -run -e httpd . -p "$port"
    else
        echo "❌ No HTTP server available (python/ruby)"
        return 1
    fi
}

# Network connectivity test
nettest() {
    local hosts=("8.8.8.8" "1.1.1.1" "google.com" "github.com")
    
    echo "🔌 Network Connectivity Test:"
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
            echo "  ✅ $host"
        else
            echo "  ❌ $host"
        fi
    done
}

# Trace route
trace() {
    local host="$1"
    if [[ -z "$host" ]]; then
        echo "❌ Host required"
        echo "Usage: trace host"
        return 1
    fi
    
    echo "🛤️  Tracing route to $host:"
    
    if zmod_has_command traceroute; then
        traceroute "$host"
    elif zmod_has_command tracert; then
        tracert "$host"
    else
        echo "❌ No traceroute tool available"
        return 1
    fi
}

# Whois lookup
whois() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        echo "❌ Domain required"
        echo "Usage: whois domain.com"
        return 1
    fi
    
    if zmod_has_command whois; then
        command whois "$domain"
    elif zmod_has_command curl; then
        curl -s "http://whois.jsonwhois.io/whois?domain=$domain" | grep -E "(registrar|creation|expir)"
    else
        echo "❌ No whois tool available"
        return 1
    fi
}

# Local network scanner
lanscan() {
    local network="${1:-$(ip route | grep -E '192\.168\.|10\.|172\.' | head -1 | cut -d' ' -f1)}"
    
    if [[ -z "$network" ]]; then
        echo "❌ Could not determine network range"
        echo "Usage: lanscan 192.168.1.0/24"
        return 1
    fi
    
    echo "🔍 Scanning network: $network"
    
    if zmod_has_command nmap; then
        nmap -sn "$network" | grep -E "Nmap scan report|MAC Address"
    else
        echo "❌ nmap not available"
        echo "Install nmap for network scanning"
        return 1
    fi
}

# Internet connection quality test
netquality() {
    echo "📊 Internet Connection Quality Test:"
    
    # Packet loss test
    echo "  Testing packet loss..."
    local loss=$(ping -c 10 8.8.8.8 | grep "packet loss" | cut -d',' -f3 | cut -d'%' -f1 | xargs)
    echo "  Packet loss: $loss%"
    
    # Latency test
    echo "  Testing latency..."
    local latency=$(ping -c 5 8.8.8.8 | tail -1 | cut -d'/' -f5)
    echo "  Average latency: ${latency}ms"
    
    # DNS resolution test
    echo "  Testing DNS resolution..."
    local dns_start=$EPOCHREALTIME
    nslookup google.com >/dev/null
    local dns_end=$EPOCHREALTIME
    local dns_time=$(( (dns_end - dns_start) * 1000 ))
    echo "  DNS resolution: ${dns_time}ms"
}

# Network aliases
alias p='ping'
alias dl='download'
alias serve='httpserver'