# Monitoring Guide - HA Platform

## Access URLs

### Riyadh Cluster
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9190
- Credentials: admin / admin123

### Jeddah Cluster
- Grafana: http://localhost:3001
- Prometheus: http://localhost:9191
- Credentials: admin / admin123

---

## Quick Start

### View Metrics in Grafana
1. Open http://localhost:3000 (Riyadh) or http://localhost:3001 (Jeddah)
2. Login with admin/admin123
3. Go to Dashboards
4. Select "Kubernetes Cluster Monitoring (Custom)"

### Key Metrics to Watch
- Cluster Status:** Should show "UP" (green)
- Cluster Uptime:** Should be close to 100%
- Pod Count: Should always be 3 per cluster
- CPU Usage: Should be low (< 20%)


### Services Not Accessible

Restart all port-forwards:
# Kill existing port-forwards
pkill -f "port-forward"

# Restart services
~/ha-k8s-platform/start-all-services.sh


### Current Dashboard: "Kubernetes Cluster Monitoring (Custom):

1. **Cluster Overview**
   - Cluster status, uptime, node health
   - Total pods, replicas, containers

2. **Resource Usage**
   - Memory, CPU, and filesystem gauges
   - Pod restart counter

3. **Pod Health Status**
   - Running, Pending, Failed, Succeeded counts
   - Pod status distribution pie chart

4. **Network I/O**
   - Real-time network traffic graphs

5. **CPU & Memory by Pod**
   - Time-series graphs per pod
   - Shows individual pod performance

6. **Pod Details Table**
   - Lists all demo-app pods
   - Shows namespace, pod name, phase, restart count

#### OR

## Import Pre-built Dashboards

# Recommended Community Dashboards:

* Dashboard ID: 315 - Kubernetes Cluster Monitoring
- Best for: Overall cluster health
- Shows: Nodes, Pods, Resources

* Dashboard ID: 6417 - Kubernetes Pod Resources
- Best for: Application monitoring
- Shows: CPU, Memory, Network per pod


### How to Import:
1. Click '+' → Import
2. Enter Dashboard ID
3. Select 'Prometheus' data source
4. Click Import

---

## Troubleshooting

### Dashboard shows "No Data"
```bash
# Check if Prometheus is scraping
curl http://localhost:9190/api/v1/targets

# Check if metrics exist
curl "http://localhost:9190/api/v1/query?query=up"
```

### Grafana not connecting to Prometheus
1. Go to Configuration → Data Sources
2. Edit Prometheus
3. URL should be: `http://prometheus-server.monitoring.svc.cluster.local`
4. Click "Save & Test"

### Start monitoring services
```bash
./start-everything.sh
```

---
## NOETS
- Prometheus scrapes metrics every **15 seconds**
- Grafana dashboard refreshes every **10 seconds**
- Historical data retained for the lifetime of the Prometheus pod
- Persistent storage is **disabled** for demo purposes
- Each cluster has **independent monitoring** (no federation due to minikube networking)




## Maintenance Commands

### Restart Monitoring Stack
```bash
# Restart Prometheus
kubectl rollout restart deployment prometheus-server -n monitoring --context sa-riyadh-1

# Restart Grafana
kubectl rollout restart deployment grafana -n monitoring --context sa-riyadh-1
```

### Check Monitoring Health
```bash
# Check all monitoring pods
kubectl get pods -n monitoring --context sa-riyadh-1

# Check Prometheus configuration
kubectl logs -n monitoring deployment/prometheus-server --tail=50 --context sa-riyadh-1

# Check Grafana logs
kubectl logs -n monitoring deployment/grafana --tail=50 --context sa-riyadh-1




##############################################################################################

### Pre-Demo Checklist

1. Reset everything for clean metrics:
# Reset demo app to 0 restarts
- kubectl rollout restart deployment demo-app --context sa-riyadh-1
- kubectl rollout restart deployment demo-app --context sa-jeddah-1
# Verify clean state
- kubectl get pods --context sa-riyadh-1 -o custom-columns=NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount

2. Start all services:
- ~/ha-k8s-platform/start-all-services.sh

### What to Show

**1. Cluster Overview (30 seconds)**
- Point to "Cluster Status: UP"
- Show "Demo App Pods: 3/3"
- Explain: "Both clusters running independently"

**2. Resource Efficiency (30 seconds)**
- Show CPU gauge (~1-5%)
- Show Memory gauge (~28%)
- Explain: "Lightweight, efficient resource usage"

**3. High Availability (1 minute)**
- Open HAProxy stats: http://localhost:8404/stats
- Show both backends GREEN
- Explain: "Load balancer sees both clusters healthy"

**4. Failover Demo (2 minutes)**
```bash
# Stop Riyadh cluster
minikube stop --profile sa-riyadh-1

# Show Grafana for Riyadh goes red
# Show HAProxy stats - Riyadh backend goes DOWN
# Show Jeddah dashboard still green
# Show app still accessible: curl http://localhost:8888


