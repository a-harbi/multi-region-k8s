#!/bin/bash

clear
echo "=========================================="
echo "       Saudi Arabia HA Platform "
echo "      Zero-Downtime Demonstration"
echo "=========================================="
echo ""
echo "Presenter: Abdulrahman Alharbi"
echo "Project: High Availability Kubernetes Platform"
echo "Duration: ~10 minutes"
echo ""
read -p "Press Enter to begin presentation..."

# ============================================
# SECTION 1: ARCHITECTURE
# ============================================
clear
echo "=========================================="
echo "   ARCHITECTURE OVERVIEW"
echo "=========================================="
echo ""
echo "            User Browser"
echo "              │"
echo "              ▼"
echo "     ┌─────────────────┐"
echo "     │  HAProxy:8888   │ ← Load Balancer"
echo "     │  Health Checks  │    (50/50 split)"
echo "     └────────┬────────┘"
echo "              │"
echo "       ┏──────┴──────┓"
echo "       ▼             ▼"
echo "   Port 8080     Port 8081"
echo "       │             │"
echo "       ▼             ▼"
echo "  ┌──────────┐   ┌──────────┐"
echo "  │ Riyadh   │   │ Jeddah   │"
echo "  │ Cluster  │   │ Cluster  │"
echo "  ├──────────┤   ├──────────┤"
echo "  │ 3x Pods  │   │ 3x Pods  │"
echo "  │ ArgoCD   │   │ ArgoCD   │"
echo "  │Prometheus│   │Prometheus│"
echo "  │ Grafana  │   │ Grafana  │"
echo "  └──────────┘   └──────────┘"
echo ""
echo "Key Features:"
echo "  ✓ High Availability (2 clusters)"
echo "  ✓ Load Balancing (HAProxy)"
echo "  ✓ GitOps Automation (ArgoCD)"
echo "  ✓ Real-time Monitoring (Prometheus + Grafana)"
echo "  ✓ Zero-Downtime Failover"
echo ""
read -p "Press Enter to view live application..."

# ============================================
# SECTION 2: LIVE APPLICATION
# ============================================
clear
echo "=========================================="
echo "    LIVE APPLICATION"
echo "=========================================="
echo ""
echo "   Main Application URL:"
echo "   http://localhost:8888"
echo ""
echo "   Instructions for Presenter:"
echo "   1. Open above URL in browser"
echo "   2. Show beautiful Saudi-themed UI"
echo "   3. Refresh page 5-6 times"
echo "   4. Point out:"
echo "      • Cluster name changes (Riyadh ↔ Jeddah)"
echo "      • Pod hostname changes"
echo "      • Version shows v3.0"
echo "      • Load balancer status"
echo ""
echo "This proves load balancing is working!"
echo ""
read -p "Press Enter after demonstrating application..."

# ============================================
# SECTION 3: LOAD BALANCING
# ============================================
clear
echo "=========================================="
echo "   LOAD BALANCING VERIFICATION"
echo "=========================================="
echo ""
echo "Sending 10 requests to demonstrate distribution..."
echo ""

for i in {1..10}; do
  RESPONSE=$(curl -s http://localhost:8888/api 2>/dev/null)
  CLUSTER=$(echo "$RESPONSE" | grep -o '"cluster":"[^"]*"' | cut -d'"' -f4)
  POD=$(echo "$RESPONSE" | grep -o '"hostname":"[^"]*"' | cut -d'"' -f4)
  echo "Request $i: Cluster=$CLUSTER | Pod=$POD"
  sleep 0.3
done

echo ""
echo "Distribution Summary:"
for i in {1..10}; do
  curl -s http://localhost:8888/api | grep -o '"cluster":"[^"]*"'
done | sort | uniq -c

echo ""
echo "  Traffic is split ~50/50 between clusters"
echo ""
read -p "Press Enter to view monitoring dashboards..."

# ============================================
# SECTION 4: MONITORING
# ============================================
clear
echo "=========================================="
echo "   MONITORING & OBSERVABILITY"
echo "=========================================="
echo ""
echo "   Grafana Dashboards:"
echo "   Riyadh:  http://localhost:3000"
echo "   Jeddah:  http://localhost:3001"
echo "   Login:   admin / admin123"
echo ""
echo "   Instructions for Presenter:"
echo "   1. Open Grafana (Riyadh or Jeddah)"
echo "   2. Show imported dashboard (ID: 315)"
echo "   3. Point out key metrics:"
echo "      • Pod count (should be 3)"
echo "      • CPU usage (low, ~10-20%)"
echo "      • Memory usage (stable)"
echo "      • Network traffic"
echo ""
echo "   HAProxy Statistics:"
echo "   URL:     http://localhost:8404"
echo "   Login:   admin / admin123"
echo ""
echo "  Instructions:"
echo "   1. Open HAProxy stats"
echo "   2. Show backend servers (Riyadh & Jeddah)"
echo "   3. Point out:"
echo "      • Both servers are UP (green)"
echo "      • Request counts"
echo "      • Health check status"
echo ""
read -p "Press Enter after showing dashboards..."

# ============================================
# SECTION 5: GITOPS
# ============================================
clear
echo "=========================================="
echo "   GITOPS AUTOMATION (ArgoCD)"
echo "=========================================="
echo ""
echo "    ArgoCD Dashboards:"
echo "   Riyadh:  https://localhost:9090"
echo "   Jeddah:  https://localhost:9091"
echo "   Login:   admin / password"
echo ""
echo "   Instructions for Presenter:"
echo "   1. Open ArgoCD UI"
echo "   2. Show 'demo-app-riyadh' or 'demo-app-jeddah'"
echo "   3. Point out:"
echo "      • Status: Healthy & Synced"
echo "      • Auto-sync enabled"
echo "      • Git repository connected"
echo "      • Application topology view"
echo ""
echo "   How GitOps Works:"
echo "   Git Commit → ArgoCD Detects → Auto-Deploy → Both Clusters"
echo ""
echo "This is Infrastructure as Code in action!"
echo ""
read -p "Press Enter to demonstrate zero-downtime failover..."

# ============================================
# SECTION 6: ZERO-DOWNTIME FAILOVER TEST
# ============================================
clear
echo "=========================================="
echo "   ZERO-DOWNTIME FAILOVER TEST"
echo "=========================================="
echo ""
echo "   What we'll demonstrate:"
echo "   1. Application running on BOTH clusters"
echo "   2. We'll DELETE all pods in Riyadh cluster"
echo "   3. Watch traffic automatically route to Jeddah"
echo "   4. Measure downtime (should be 0-6 seconds)"
echo "   5. Watch Kubernetes recreate pods (self-healing)"
echo ""
echo "This proves TRUE high availability!"
echo ""
read -p "Press Enter to start failover test..."

echo ""
./test-zero-downtime.sh

read -p "Press Enter to view system status..."

# ============================================
# SECTION 7: SYSTEM STATUS
# ============================================
clear
echo "=========================================="
echo "   FINAL SYSTEM STATUS"
echo "=========================================="
echo ""

./health-check.sh

echo ""
read -p "Press Enter for summary..."

# ============================================
# SECTION 8: SUMMARY
# ============================================
clear
echo "=========================================="
echo "   DEMONSTRATION COMPLETE!"
echo "=========================================="
echo ""
echo "   What We Demonstrated:"
echo ""
echo "     High Availability"
echo "     → 2 independent Kubernetes clusters"
echo "     → Automatic failover in <6 seconds"
echo ""
echo "     Load Balancing"
echo "     → HAProxy distributing traffic 50/50"
echo "     → Health checks every 2 seconds"
echo ""
echo "     GitOps Automation"
echo "     → ArgoCD auto-deploying from Git"
echo "     → Self-healing enabled"
echo ""
echo "     Complete Observability"
echo "     → Prometheus metrics collection"
echo "     → Grafana real-time dashboards"
echo "     → HAProxy statistics"
echo ""
echo "     Zero-Downtime Failover"
echo "     → Tested live during presentation"
echo "     → 95%+ success rate achieved"
echo ""
echo "     Professional Implementation"
echo "     → Saudi-themed deployment 🇸🇦"
echo "     → Production-ready architecture"
echo "     → Comprehensive monitoring"
echo ""
echo "=========================================="
echo ""
echo " All Access URLs:"
echo "   App:         http://localhost:8888"
echo "   Grafana:     http://localhost:3000 & 3001"
echo "   ArgoCD:      https://localhost:9090 & 9091"
echo "   HAProxy:     http://localhost:8404"
echo ""
echo " Documentation:"
echo "   Test Results:    /tmp/*-test-*.txt"
echo "   Dashboards:      monitoring/"
echo "   Architecture:    docs/"
echo ""
echo "=========================================="
echo "        Thank you for watching! "
echo "            SDAIA  Bootcamp"
echo "=========================================="
echo ""
