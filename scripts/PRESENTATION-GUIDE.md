#  Presentation Guide - HA Platform

##  Before I Start

### Run This Command:
```bash
./start-everything.sh

./health-check.sh
```

**All checks should show good **

---

##   Demo Flow (10 minutes)

### 1. Architecture (2 min)
**Script:** `./demo.sh` (follow prompts)


**Show diagram in terminal**

---

### 2. Live Application (2 min)
**Open:** http://localhost:8888

**What to show:**
1. UI with Saudi theme 
2. Refresh 5-6 times
3. Point out cluster name changes
4. Point out pod name changes

**What should I say:**
> "Watch as I refresh - you see different clusters and pods responding. This is load balancing in action."

---

### 3. Monitoring Dashboards (2 min)
**Open:** http://localhost:3000 (Grafana)

**Login:** admin / admin123

**What to show:**
1. Dashboard (Kubernetes Cluster)
2. Pod count (should be 3)
3. CPU/Memory usage
4. Network traffic

**What should say:**
> "I have full observability with Prometheus and Grafana. You can see all 3 pods running, low CPU usage,  - system is healthy."

**Also show:** http://localhost:8404 (HAProxy Stats)
- Point out both servers UP
- Show request distribution

---

### 4. GitOps (1 min)
**Open:** https://localhost:9090 (ArgoCD)

**What to show:**
1. Application status (Healthy & Synced)
2. Topology view
3. Git repository connection

**What should I say:**
> "I implemented GitOps with ArgoCD. Any change I push to Git automatically deploys to both clusters. This is infrastructure as code."

---

### 5. Zero-Downtime Failover (3 min)  **MAIN EVENT**
**Run:** Already part of `./demo.sh`

**What happens:**
1. Script sends continuous requests
2. Kills Riyadh cluster after 15 seconds
3. Shows automatic failover to Jeddah
4. Measures downtime (0-6 seconds)
5. Shows >95% success rate

**What should i say:**
> "Now the impressive part - let me demonstrate zero-downtime failover. I'm sending continuous requests. Watch what happens when I kill the Riyadh cluster..."
> 
> [Wait for test to complete]
>
> "As you can see, traffic automatically routed to Jeddah with minimal downtime. This is true high availability."

---

##  Key Points to Emphasize

1. **High Availability**
   - "2 independent clusters provide redundancy"
   - "If one fails, the other continues serving"

2. **Load Balancing**
   - "HAProxy distributes traffic evenly"
   - "Health checks every 2 seconds"

3. **GitOps**
   - "Git is single source of truth"
   - "Automated deployments via ArgoCD"

4. **Monitoring**
   - "Complete observability with Prometheus + Grafana"
   - "Real-time metrics and alerts"

5. **Zero-Downtime**
   - "Failover in under 6 seconds"
   - "95%+ success rate during failure"

---


##  Emergency Commands

### If something breaks:

./start-everything.sh
./health-check.sh
```

### If port-forward dies:
```bash
pkill -f "kubectl port-forward"
./start-everything.sh
```

### Check what's wrong:
```bash
./health-check.sh
```

---

##  URLs 
- **App:** http://localhost:8888
- **Grafana:** http://localhost:3000 (admin/admin123)
- **ArgoCD:** https://localhost:9090 (admin/)
- **HAProxy:** http://localhost:8404 (admin/admin123)

---



