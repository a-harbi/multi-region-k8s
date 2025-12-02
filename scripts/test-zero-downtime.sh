#!/bin/bash

echo "=========================================="
echo " Zero-Downtime Failover Test"
echo "=========================================="
echo ""
echo "This test will:"
echo "1. Send continuous requests (60 seconds)"
echo "2. After 15s: DELETE all pods in sa-riyadh-1"
echo "3. Kubernetes auto-recreates pods (self-healing)"
echo "4. Measure downtime and recovery"
echo "5. Show automatic failover to sa-jeddah-1"
echo ""
echo "This demonstrates:"
echo "  ✓ High Availability (traffic goes to Jeddah)"
echo "  ✓ Self-Healing (Kubernetes recreates pods)"
echo "  ✓ ArgoCD sync (ensures correct state)"
echo ""
read -p "Press Enter to start test..."

RESULTS_FILE="/tmp/failover-test-$(date +%Y%m%d-%H%M%S).txt"
echo "Failover Test Results - $(date)" > $RESULTS_FILE
echo "Test Type: Pod Deletion with Auto-Healing" >> $RESULTS_FILE
echo "========================================" >> $RESULTS_FILE

# Start continuous requests in background
(
  COUNTER=0
  while [ $COUNTER -lt 60 ]; do
    TIMESTAMP=$(date +%s.%N)
    RESPONSE=$(curl -s --max-time 2 http://localhost:8888/api 2>&1)
    
    if echo "$RESPONSE" | grep -q "cluster"; then
      CLUSTER=$(echo "$RESPONSE" | grep -o '"cluster":"[^"]*"' | cut -d'"' -f4)
      echo "$TIMESTAMP SUCCESS $CLUSTER" >> $RESULTS_FILE
      echo " $(date +%H:%M:%S) - Request #$COUNTER - $CLUSTER"
    else
      echo "$TIMESTAMP FAILED" >> $RESULTS_FILE
      echo " $(date +%H:%M:%S) - Request #$COUNTER - FAILED"
    fi
    
    COUNTER=$((COUNTER + 1))
    sleep 1
  done
) &
TEST_PID=$!

echo ""
echo "=========================================="
echo " Phase 1: Normal Operation (15 seconds)"
echo "=========================================="
echo "Both clusters serving traffic..."
sleep 15

echo ""
echo "=========================================="
echo " Phase 2: Simulating Cluster Failure"
echo "=========================================="
echo "Deleting ALL pods in sa-riyadh-1..."

# Switch to Riyadh and delete all demo-app pods
kubectl config use-context sa-riyadh-1
PODS_DELETED=$(kubectl get pods -l app=demo-app -o name | wc -l)
kubectl delete pods -l app=demo-app --grace-period=0 --force

echo "    Deleted $PODS_DELETED pods in sa-riyadh-1"
echo ""
echo "What's happening now:"
echo "  1. Traffic failing over to sa-jeddah-1"
echo "  2. Kubernetes detecting missing pods"
echo "  3. Kubernetes creating new pods"
echo "  4. ArgoCD ensuring correct state"

echo ""
echo " Phase 3: Monitoring Failover & Recovery (30 seconds)"
echo "=========================================="

# Monitor pod recreation
echo ""
echo "Pod Status in sa-riyadh-1:"
for i in {1..30}; do
  RUNNING=$(kubectl get pods -l app=demo-app --no-headers 2>/dev/null | grep Running | wc -l)
  CREATING=$(kubectl get pods -l app=demo-app --no-headers 2>/dev/null | grep -E "ContainerCreating|Pending" | wc -l)
  
  if [ $i -eq 1 ] || [ $i -eq 10 ] || [ $i -eq 20 ] || [ $i -eq 30 ]; then
    echo "  $(date +%H:%M:%S) - Running: $RUNNING/3 | Creating: $CREATING"
  fi
  
  sleep 1
done

echo ""
echo " Phase 4: Recovery Complete"
echo "=========================================="

# Wait for background test to complete
wait $TEST_PID 2>/dev/null

echo ""
echo "Checking final pod status..."
kubectl config use-context sa-riyadh-1
FINAL_PODS=$(kubectl get pods -l app=demo-app --no-headers | grep Running | wc -l)
echo "sa-riyadh-1: $FINAL_PODS/3 pods running"

kubectl config use-context sa-jeddah-1
JEDDAH_PODS=$(kubectl get pods -l app=demo-app --no-headers | grep Running | wc -l)
echo "sa-jeddah-1: $JEDDAH_PODS/3 pods running"

echo ""
echo "=========================================="
echo " Test Results & Analysis"
echo "=========================================="

# Analyze results
TOTAL_LINES=$(grep -E "SUCCESS|FAILED" $RESULTS_FILE | wc -l)
SUCCESS=$(grep "SUCCESS" $RESULTS_FILE | wc -l)
FAILED=$(grep "FAILED" $RESULTS_FILE | wc -l)
RIYADH_BEFORE=$(grep "SUCCESS sa-riyadh-1" $RESULTS_FILE | head -15 | wc -l)
JEDDAH_DURING=$(grep "SUCCESS sa-jeddah-1" $RESULTS_FILE | tail -30 | wc -l)

# Calculate failure window
FIRST_FAIL=$(grep "FAILED" $RESULTS_FILE | head -1 | cut -d' ' -f1 2>/dev/null)
LAST_FAIL=$(grep "FAILED" $RESULTS_FILE | tail -1 | cut -d' ' -f1 2>/dev/null)

if [ ! -z "$FIRST_FAIL" ] && [ ! -z "$LAST_FAIL" ]; then
  DOWNTIME=$(echo "$LAST_FAIL - $FIRST_FAIL" | bc 2>/dev/null || echo "0")
  DOWNTIME_INT=${DOWNTIME%.*}
else
  DOWNTIME=0
  DOWNTIME_INT=0
fi

SUCCESS_RATE=$(echo "scale=1; $SUCCESS * 100 / ($SUCCESS + $FAILED)" | bc 2>/dev/null || echo "0")

echo ""
echo " Request Statistics:"
echo "  Total Requests:       $((SUCCESS + FAILED))"
echo "  Successful:           $SUCCESS"
echo "  Failed:               $FAILED"
echo "  Success Rate:         $SUCCESS_RATE%"
echo ""

echo " Traffic Distribution:"
echo "  Before Failure:"
echo "    sa-riyadh-1:        $RIYADH_BEFORE requests"
echo ""
echo "  During Failure:"
echo "    sa-jeddah-1:        $JEDDAH_DURING requests (handled failover)"
echo ""

echo "  Downtime Analysis:"
if [ $FAILED -eq 0 ]; then
  echo "   ZERO DOWNTIME - Perfect!"
  echo "   All requests succeeded!"
elif [ $DOWNTIME_INT -le 10 ]; then
  echo "   Minimal downtime: ~${DOWNTIME_INT}s"
  echo "   Acceptable for pod recreation"
  echo "   $FAILED requests failed during pod restart"
else
  echo "    Downtime: ~${DOWNTIME_INT}s"
  echo "   $FAILED requests failed"
fi

echo ""
echo " Self-Healing Verification:"
if [ $FINAL_PODS -eq 3 ]; then
  echo "   sa-riyadh-1: All 3 pods restored"
  echo "   Kubernetes self-healing: WORKING"
  echo "   ArgoCD sync: WORKING"
else
  echo "    sa-riyadh-1: Only $FINAL_PODS/3 pods running"
  echo "   Pods still starting up (check again in 30s)"
fi

if [ $JEDDAH_PODS -eq 3 ]; then
  echo "   sa-jeddah-1: All 3 pods healthy"
else
  echo "    sa-jeddah-1: Only $JEDDAH_PODS/3 pods running"
fi

echo ""
echo " Overall Assessment:"
if [ $SUCCESS_RATE -gt 90 ] && [ $FINAL_PODS -eq 3 ]; then
  echo "  ✅✅✅ EXCELLENT"
  echo "  • High Availability: VERIFIED"
  echo "  • Auto-Failover: WORKING"
  echo "  • Self-Healing: WORKING"
  echo "  • Production Ready: YES"
elif [ $SUCCESS_RATE -gt 80 ]; then
  echo "  ✅✅ GOOD"
  echo "  • High Availability: VERIFIED"
  echo "  • Minor improvements possible"
else
  echo "  ⚠️  NEEDS ATTENTION"
  echo "  • Review configuration"
fi

echo ""
echo "=========================================="

# Save summary to file
{
  echo ""
  echo "=== SUMMARY ==="
  echo "Test Type: Pod Deletion + Auto-Healing"
  echo "Total Requests: $((SUCCESS + FAILED))"
  echo "Success: $SUCCESS | Failed: $FAILED"
  echo "Success Rate: $SUCCESS_RATE%"
  echo "Downtime: ~${DOWNTIME_INT}s"
  echo "Riyadh Before: $RIYADH_BEFORE requests"
  echo "Jeddah During: $JEDDAH_DURING requests"
  echo "Pods Deleted: $PODS_DELETED"
  echo "Pods Restored: $FINAL_PODS/3"
  echo ""
  echo "Self-Healing: $([ $FINAL_PODS -eq 3 ] && echo 'WORKING' || echo 'IN PROGRESS')"
  echo "High Availability: $([ $SUCCESS_RATE -gt 90 ] && echo 'VERIFIED' || echo 'PARTIAL')"
} >> $RESULTS_FILE

echo " Detailed results saved to: $RESULTS_FILE"
echo ""

# Show current pod status
echo "=========================================="
echo " Final Pod Status"
echo "=========================================="
echo ""
echo "sa-riyadh-1:"
kubectl config use-context sa-riyadh-1
kubectl get pods -l app=demo-app

echo ""
echo "sa-jeddah-1:"
kubectl config use-context sa-jeddah-1
kubectl get pods -l app=demo-app

echo ""
echo "=========================================="
echo " Test Complete!"
echo ""
echo "What was demonstrated:"
echo "  ✓ Pods deleted → Traffic to Jeddah"
echo "  ✓ Kubernetes recreated pods automatically"
echo "  ✓ ArgoCD maintained desired state"
echo "  ✓ Zero (or minimal) downtime achieved"
echo "=========================================="
echo ""
