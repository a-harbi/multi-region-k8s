#!/bin/bash

echo "=========================================="
echo " Starting Complete HA Platform + Monitoring"
echo "=========================================="

# Kill existing port-forwards
echo "Cleaning up old port-forwards..."
pkill -f "kubectl port-forward" 2>/dev/null
sleep 2

echo ""
echo "Starting services..."
echo ""

# ========== SA-RIYADH-1 ==========
echo " sa-riyadh-1 Services:"

# 1. Riyadh App (8080)
kubectl config use-context sa-riyadh-1
nohup kubectl port-forward --address 0.0.0.0 service/demo-app-service 8080:80 > /tmp/riyadh-app-pf.log 2>&1 &
echo "  ✓ App on localhost:8080"
sleep 1

# 2. Riyadh ArgoCD (9090)
nohup kubectl port-forward --address 0.0.0.0 -n argocd service/argocd-server 9090:443 > /tmp/riyadh-argocd-pf.log 2>&1 &
echo "  ✓ ArgoCD on localhost:9090"
sleep 1

# 3. Riyadh Prometheus (9190)
nohup kubectl port-forward --address 0.0.0.0 -n monitoring service/prometheus-server 9190:80 > /tmp/riyadh-prometheus-pf.log 2>&1 &
echo "  ✓ Prometheus on localhost:9190"
sleep 1

# 4. Riyadh Grafana (3000)
nohup kubectl port-forward --address 0.0.0.0 -n monitoring service/grafana 3000:80 > /tmp/riyadh-grafana-pf.log 2>&1 &
echo "  ✓ Grafana on localhost:3000"
sleep 1

echo ""

# ========== SA-JEDDAH-1 ==========
echo " sa-jeddah-1 Services:"

# 5. Jeddah App (8081)
kubectl config use-context sa-jeddah-1
nohup kubectl port-forward --address 0.0.0.0 service/demo-app-service 8081:80 > /tmp/jeddah-app-pf.log 2>&1 &
echo "  ✓ App on localhost:8081"
sleep 1

# 6. Jeddah ArgoCD (9091)
nohup kubectl port-forward --address 0.0.0.0 -n argocd service/argocd-server 9091:443 > /tmp/jeddah-argocd-pf.log 2>&1 &
echo "  ✓ ArgoCD on localhost:9091"
sleep 1

# 7. Jeddah Prometheus (9191)
nohup kubectl port-forward --address 0.0.0.0 -n monitoring service/prometheus-server 9191:80 > /tmp/jeddah-prometheus-pf.log 2>&1 &
echo "  ✓ Prometheus on localhost:9191"
sleep 1

# 8. Jeddah Grafana (3001)
nohup kubectl port-forward --address 0.0.0.0 -n monitoring service/grafana 3001:80 > /tmp/jeddah-grafana-pf.log 2>&1 &
echo "  ✓ Grafana on localhost:3001"
sleep 1

echo ""

# ========== HAPROXY ==========
echo " Load Balancer:"
sudo systemctl restart haproxy
echo "  ✓ HAProxy on localhost:8888"
sleep 2

echo ""
echo "=========================================="
echo " All Services Started!"
echo ""
echo " ACCESS URLS:"
echo ""
echo " Applications:"
echo "   Load Balanced:  http://localhost:8888"
echo "   Riyadh Direct:  http://localhost:8080"
echo "   Jeddah Direct:  http://localhost:8081"
echo ""
echo "  GitOps (ArgoCD):"
echo "   Riyadh ArgoCD:  https://localhost:9090"
echo "   Jeddah ArgoCD:  https://localhost:9091"
echo "   Username: admin"
echo ""
echo " Monitoring (Grafana):"
echo "   Riyadh Grafana: http://localhost:3000"
echo "   Jeddah Grafana: http://localhost:3001"
echo "   Username: admin | Password: admin123"
echo ""
echo " Metrics (Prometheus):"
echo "   Riyadh Prom:    http://localhost:9190"
echo "   Jeddah Prom:    http://localhost:9191"
echo ""
echo " HAProxy Stats:  http://localhost:8404"
echo "   Username: admin | Password: admin123"
echo ""
echo "=========================================="
echo ""
echo " Logs available at: /tmp/*-pf.log"
echo " To stop: pkill -f 'kubectl port-forward'"
echo ""
