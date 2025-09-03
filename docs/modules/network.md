# Network Module

The Network module provides comprehensive network diagnostics, connectivity testing, and network utilities for development and system administration.

## 📋 Overview

The Network module includes:
- HTTP status checking and web diagnostics
- Internet speed testing
- Network interface information
- SSL certificate validation
- Comprehensive connectivity testing
- Network troubleshooting utilities

## 📁 Module Structure

```
modules/network/
└── network.zsh    # Complete network module (all functions in one file)
```

## 🚀 Core Commands

### Web Diagnostics

#### `httpstatus [url]`
HTTP status checker with detailed timing information.

```bash
# Usage
httpstatus https://google.com           # Check single URL
httpstatus google.com                  # Auto-add https://
httpstatus --verbose github.com        # Detailed output
httpstatus --timeout 10 slow-site.com # Custom timeout
```

**Output Example:**
```
🌐 HTTP Status Check: https://google.com
├── Status: ✅ 200 OK
├── Response Time: 142ms
├── Total Time: 284ms
├── Content Type: text/html; charset=ISO-8859-1
├── Content Length: 15,032 bytes
├── Server: gws
└── SSL: ✅ Valid Certificate
```

**Features:**
- HTTP status code validation
- Response time measurement
- SSL certificate verification
- Content-Type detection
- Server information
- Redirect following
- IPv4/IPv6 support

#### `httpheaders [url]`
Display HTTP response headers with formatting.

```bash
# Usage
httpheaders https://api.github.com     # Show all headers
httpheaders --security github.com      # Security-focused headers
httpheaders --cache google.com         # Cache-related headers
```

**Header Categories:**
- **Security**: HSTS, CSP, X-Frame-Options, etc.
- **Caching**: Cache-Control, ETag, Last-Modified
- **CORS**: Access-Control-* headers
- **Performance**: Content-Encoding, Keep-Alive

### Speed Testing

#### `speedtest`
Internet connection speed testing.

```bash
# Usage
speedtest                              # Quick speed test
speedtest --detailed                   # Detailed results
speedtest --server nearest            # Use nearest server
speedtest --json                      # JSON output
```

**Output Example:**
```
🚀 Internet Speed Test
├── Server: Speedtest.net Server (New York, NY)
├── Ping: 12ms
├── Download: ⬇️ 95.4 Mbps
├── Upload: ⬆️ 23.7 Mbps
├── ISP: Comcast Cable
└── External IP: 203.0.113.42
```

**Features:**
- Download/upload speed measurement
- Latency testing
- Server selection (automatic/manual)
- ISP detection
- Multiple output formats
- Historical speed tracking (planned)

### Network Information

#### `netinfo`
Network interface and connectivity information.

```bash
# Usage
netinfo                                # All network interfaces
netinfo --active                       # Active interfaces only
netinfo --external                     # External IP information
netinfo --dns                         # DNS configuration
```

**Output Example:**
```
🔌 Network Information
├── Active Interfaces:
│   ├── en0 (WiFi): 192.168.1.100/24
│   └── lo0 (Loopback): 127.0.0.1/8
├── External IP: 203.0.113.42
├── Location: New York, NY, US
├── ISP: Comcast Cable Communications
├── DNS Servers:
│   ├── 8.8.8.8 (Google)
│   └── 1.1.1.1 (Cloudflare)
└── Gateway: 192.168.1.1
```

**Information Includes:**
- Network interfaces and IP addresses
- Subnet masks and network ranges
- External IP and geolocation
- ISP information
- DNS server configuration
- Default gateway
- MAC addresses
- Network statistics

### SSL Certificate Validation

#### `sslcheck [domain] [port]`
SSL certificate validation and information.

```bash
# Usage
sslcheck google.com                    # Check SSL certificate
sslcheck github.com 443               # Specify port
sslcheck --expiry-days 30 mysite.com  # Check expiry within 30 days
sslcheck --chain google.com           # Show certificate chain
```

**Output Example:**
```
🔒 SSL Certificate Check: google.com:443
├── Status: ✅ Valid
├── Issuer: Google Trust Services LLC
├── Subject: *.google.com
├── Valid From: 2023-08-14
├── Valid Until: 2023-11-06 (72 days remaining)
├── Serial: 7c:b4:66:47:3a:16:8f:2e:10:00:00:00:4a:b2:5c:d9
├── Signature: SHA256-RSA
├── Key Size: 256-bit ECC
├── SAN: google.com, *.google.com, *.appengine.google.com
└── OCSP: ✅ Good
```

**Features:**
- Certificate validity verification
- Expiration date checking
- Certificate chain analysis
- Subject Alternative Names (SAN)
- OCSP stapling verification
- Key strength analysis
- Issuer information

### Connectivity Testing

#### `nettest [options]`
Comprehensive network connectivity testing.

```bash
# Usage
nettest                                # Full connectivity test
nettest --quick                        # Quick basic tests
nettest --dns                         # DNS resolution tests
nettest --port 80,443,22              # Specific port tests
```

**Test Categories:**
1. **Basic Connectivity**
   - Internet connectivity (ping)
   - DNS resolution
   - Gateway accessibility

2. **Service Tests**
   - HTTP/HTTPS connectivity
   - SSH accessibility
   - Common service ports

3. **Performance Tests**
   - Latency measurements
   - Packet loss detection
   - Bandwidth estimation

**Output Example:**
```
🔍 Network Connectivity Test
├── Internet: ✅ Connected (ping: 12ms)
├── DNS: ✅ Resolving (google.com → 142.250.191.14)
├── Gateway: ✅ Accessible (192.168.1.1)
├── HTTP: ✅ Port 80 open
├── HTTPS: ✅ Port 443 open
├── SSH: ❌ Port 22 filtered
└── Overall: ⚠️ Mostly functional (1 issue)
```

### Network Troubleshooting

#### `netdebug [target]`
Network debugging and troubleshooting utilities.

```bash
# Usage
netdebug google.com                    # Debug connectivity to host
netdebug --route 8.8.8.8              # Show route to destination
netdebug --scan 192.168.1.0/24        # Network scan
netdebug --listen                      # Show listening ports
```

**Debug Features:**
- Route tracing (traceroute)
- Port scanning
- Network interface analysis
- Routing table inspection
- ARP table display
- Active connections listing

#### `portcheck [host] [port]`
Check if specific ports are open.

```bash
# Usage
portcheck google.com 80               # Check single port
portcheck localhost 3000,8080         # Multiple ports
portcheck --range github.com 80-90    # Port range
portcheck --udp dns.google 53         # UDP port check
```

**Features:**
- TCP and UDP port checking
- Port range scanning
- Service identification
- Response time measurement
- Batch port checking

## 🎯 Advanced Features

### Network Monitoring

#### `netmon`
Real-time network monitoring.

```bash
# Usage
netmon                                 # Monitor all interfaces
netmon --interface en0                # Monitor specific interface
netmon --connections                   # Monitor active connections
netmon --bandwidth                     # Bandwidth monitoring
```

**Monitoring Features:**
- Real-time bandwidth usage
- Connection tracking
- Interface statistics
- Protocol analysis
- Historical data (short-term)

### DNS Tools

#### `dnsinfo [domain]`
DNS record information and analysis.

```bash
# Usage
dnsinfo google.com                     # All DNS records
dnsinfo --mx github.com               # Mail exchange records
dnsinfo --txt cloudflare.com         # TXT records
dnsinfo --trace recursive.ly          # DNS trace
```

**DNS Record Types:**
- A (IPv4 addresses)
- AAAA (IPv6 addresses)
- MX (Mail exchange)
- TXT (Text records)
- CNAME (Canonical name)
- NS (Name servers)
- SOA (Start of authority)

### Security Testing

#### `netsec [target]`
Network security testing and analysis.

```bash
# Usage
netsec mywebsite.com                   # Security scan
netsec --ssl-grade github.com         # SSL security rating
netsec --headers secure-site.com      # Security headers check
netsec --ports 192.168.1.100          # Port security scan
```

**Security Tests:**
- SSL/TLS configuration analysis
- Security header verification
- Open port identification
- Service fingerprinting
- Vulnerability detection (basic)

## 🛠️ Configuration

### Environment Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `ZSH_MODULE_NET_TIMEOUT` | Default network timeout | `10` | Seconds (1-60) |
| `ZSH_MODULE_NET_IPV6` | Enable IPv6 testing | `true` | `true`, `false` |
| `ZSH_MODULE_NET_VERBOSE` | Verbose output | `false` | `true`, `false` |
| `ZSH_MODULE_SPEEDTEST_SERVER` | Preferred speedtest server | `auto` | Server ID or `auto` |

### Custom Configuration
```bash
# Network module configuration
export ZSH_MODULE_NET_TIMEOUT=15
export ZSH_MODULE_NET_IPV6=true
export ZSH_MODULE_NET_VERBOSE=true

# Custom DNS servers for testing
export ZSH_MODULE_DNS_SERVERS="8.8.8.8,1.1.1.1,208.67.222.222"
```

## 🎨 Customization Examples

### Custom Network Checks
```bash
# Check multiple services
function check-services() {
    local services=("google.com:80" "github.com:443" "dns.google:53")
    
    echo $(zmod_color blue "🔍 Service Connectivity Check")
    for service in "${services[@]}"; do
        local host=$(echo $service | cut -d: -f1)
        local port=$(echo $service | cut -d: -f2)
        
        if portcheck $host $port >/dev/null 2>&1; then
            echo "  ✅ $service"
        else
            echo "  ❌ $service"
        fi
    done
}
```

### Network Health Monitoring
```bash
# Continuous network health check
function net-health() {
    while true; do
        clear
        echo $(zmod_color green "🌐 Network Health Monitor")
        echo "$(date)"
        echo
        
        nettest --quick
        echo
        
        speedtest --quick 2>/dev/null | grep -E "(Download|Upload|Ping)"
        
        sleep 30
    done
}
```

### Development Server Testing
```bash
# Test local development servers
function dev-server-check() {
    local ports=(3000 4000 5000 8000 8080 9000)
    
    echo $(zmod_color blue "🔧 Development Server Check")
    for port in "${ports[@]}"; do
        if portcheck localhost $port >/dev/null 2>&1; then
            echo "  ✅ Port $port: Active"
            httpstatus "localhost:$port" 2>/dev/null | grep -E "(Status|Response Time)"
        else
            echo "  ❌ Port $port: Inactive"
        fi
    done
}
```

## 🚨 Error Handling

### Network Connectivity Issues
```bash
# Graceful handling of network failures
function safe-nettest() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo $(zmod_color red "❌ No internet connectivity")
        echo "Troubleshooting steps:"
        echo "  1. Check network cable/WiFi connection"
        echo "  2. Verify network settings"
        echo "  3. Restart network interface"
        return 1
    fi
    
    nettest "$@"
}
```

### SSL Certificate Warnings
```bash
# Handle SSL certificate issues
function safe-sslcheck() {
    local domain="$1"
    
    if sslcheck "$domain" 2>&1 | grep -q "expires in"; then
        local days=$(sslcheck "$domain" | grep "expires in" | sed 's/.*(\([0-9]*\) days.*/\1/')
        
        if [[ $days -lt 30 ]]; then
            echo $(zmod_color yellow "⚠️ Certificate expires soon: $days days")
        fi
    fi
}
```

## 📊 Performance Features

### Caching
- DNS resolution results cached temporarily
- SSL certificate information cached
- Network interface data cached

### Parallel Testing
- Multiple connectivity tests run in parallel
- Batch port checking optimized
- Concurrent SSL checks

### Resource Management
- Automatic timeout handling
- Memory-efficient operations
- Clean process termination

## 🔍 Troubleshooting

### Common Issues

#### No Network Tools Available
```bash
# Install required tools
# Ubuntu/Debian
sudo apt install curl wget netcat-openbsd dnsutils

# macOS
brew install curl wget netcat

# Check tool availability
zmod_has_command curl && echo "curl available"
zmod_has_command nc && echo "netcat available"
```

#### Firewall Blocking Tests
```bash
# Some tests may be blocked by firewalls
# Run with appropriate permissions
sudo nettest --scan 192.168.1.0/24

# Or configure firewall exceptions
```

#### DNS Resolution Issues
```bash
# Test DNS resolution directly
nslookup google.com
dig google.com

# Use alternative DNS servers
export ZSH_MODULE_DNS_SERVERS="1.1.1.1,8.8.8.8"
```

### Debug Mode
```bash
# Enable verbose network debugging
export ZSH_MODULE_NET_VERBOSE=true
export ZSH_MODULE_DEBUG=true

nettest --debug
```

## 📚 Dependencies

### Required
- `zsh` 5.0+
- `curl` or `wget` - HTTP operations
- `ping` - Connectivity testing
- Basic networking utilities (`netstat`, `ss`)

### Recommended
- `netcat` (`nc`) - Port testing
- `nmap` - Advanced port scanning
- `dig` or `nslookup` - DNS queries
- `traceroute` - Route tracing
- `iftop` - Network monitoring

### Optional
- `speedtest-cli` - Internet speed testing
- `openssl` - SSL certificate analysis
- `whois` - Domain information
- `tcpdump` - Network packet analysis

## 🔮 Future Enhancements

### Planned Features
- **Network Topology Mapping** - Discover network devices
- **Bandwidth Monitoring** - Historical usage tracking
- **VPN Integration** - VPN status and management
- **Cloud Network Testing** - AWS, Azure, GCP connectivity
- **Network Security Scanning** - Vulnerability assessment
- **Performance Benchmarking** - Network performance baselines

### Advanced Network Tools
```bash
# Planned commands
net-topology                           # Network topology discovery
net-history --bandwidth               # Bandwidth usage history
vpn-status                            # VPN connection status
cloud-connectivity aws                # Cloud service connectivity
net-security-scan 192.168.1.0/24     # Security vulnerability scan
net-benchmark --latency              # Network performance benchmark
```

## 📚 Related Documentation

- [System Module](system.md) - System utilities and monitoring
- [Development Module](dev.md) - Development server integration
- [Core Utilities](../core/utils.md) - Framework helper functions
- [Installation](../scripts/install.md) - Setup and configuration