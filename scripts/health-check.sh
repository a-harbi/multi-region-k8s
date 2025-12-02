#!/bin/bash

echo "=========================================="
echo " System Health Check"
echo "=========================================="
echo ""

ALL_HEALTHY=true

# 1. Check Minikube Clusters
echo "  Kubernetes Clusters:"
if minikube status --profile sa-riyadh-1 | grep -q "Running"; then
  echo "    sa-riyadh-1: Running"
else
  echo "    sa-riyadh-1: Stopped"
  ALL_HEALTHY=false
fi

if minikube status --profile sa-jeddah-1 | grep -q "Running"; then
  echo "    sa-jeddah-1: Running"
else
  echo "    sa-jeddah-1: Stopped"
  ALL_HEALTHY=false
fi

# 2. Check Applications
echo ""
echo "  Applications:"
if curl -s --max-time 2 http://localhost:8080/health | grep -q "healthy"; then
  echo "    Riyadh App (8080)"
else
  echo "    Riyadh App (8080)"
  ALL_HEALTHY=false
fi

if curl -s --max-time 2 http://localhost:8081/health | grep -q "healthy"; then
  echo "    Jeddah App (8081)"
else
  echo "    Jeddah App (8081)"
  ALL_HEALTHY=false
fi

if curl -s --max-time 2 http://localhost:8888/health | grep -q "healthy"; then
  echo "    HAProxy Load Balancer (8888)"
else
  echo "    HAProxy Load Balancer (8888)"
  ALL_HEALTHY=false
fi

# 3. Check GitOps
echo ""
echo "  GitOps (ArgoCD):"
if curl -sk --max-time 2 https://localhost:9090 > /dev/null 2>&1; then
  echo "    Riyadh ArgoCD (9090)"
else
  echo "    Riyadh ArgoCD (9090)"
  ALL_HEALTHY=false
fi

if curl -sk --max-time 2 https://localhost:9091 > /dev/null 2>&1; then
  echo "    Jeddah ArgoCD (9091)"
else
  echo "    Jeddah ArgoCD (9091)"
  ALL_HEALTHY=false
fi

# 4. Check Monitoring
echo ""
echo "  Monitoring:"
if curl -s --max-time 2 http://localhost:9190/-/healthy 2>&1 | grep -q "Prometheus"; then
  echo "    Riyadh Prometheus (9190)"
else
  echo "    Riyadh Prometheus (9190)"
fi

if curl -s --max-time 2 http://localhost:9191/-/healthy 2>&1 | grep -q "Prometheus"; then
  echo "    Jeddah Prometheus (9191)"
else
  echo "    Jeddah Prometheus (9191)"
fi

if curl -s --max-time 2 http://localhost:3000/api/health | grep -q "ok"; then
  echo "    Riyadh Grafana (3000)"
else
  echo "    Riyadh Grafana (3000)"
fi

if curl -s --max-time 2 http://localhost:3001/api/health | grep -q "ok"; then
  echo "    Jeddah Grafana (3001)"
else
  echo "    Jeddah Grafana (3001)"
fi

# 5. Check Load Balancing
echo ""
echo "  Load Balancing:"
LB_TEST=$(for i in {1..6}; do curl -s http://localhost:8888/api 2>/dev/null | grep -o '"cluster":"[^"]*"'; done | sort -u | wc -l)
if [ "$LB_TEST" -eq 2 ]; then
  echo "    Traffic distributed to both clusters"
else
  echo "     Traffic only to one cluster"
fi

# 6. Check Pod Counts
echo ""
echo "  Pod Status:"
kubectl config use-context sa-riyadh-1 &>/dev/null
RIYADH_PODS=$(kubectl get pods -l app=demo-app --no-headers 2>/dev/null | grep Running | wc -l)
echo "   Riyadh: $RIYADH_PODS/3 pods running"

kubectl config use-context sa-jeddah-1 &>/dev/null
JEDDAH_PODS=$(kubectl get pods -l app=demo-app --no-headers 2>/dev/null | grep Running | wc -l)
echo "   Jeddah: $JEDDAH_PODS/3 pods running"

# Summary
echo ""
echo "=========================================="
if [ "$ALL_HEALTHY" = true ] && [ $RIYADH_PODS -eq 3 ] && [ $JEDDAH_PODS -eq 3 ]; then
  echo " ALL SYSTEMS HEALTHY"
  echo " Platform is ready for demo!"
else
  echo "  Some components need attention"
  echo " Run: ./start-everything.sh"
fi
echo "=========================================="
