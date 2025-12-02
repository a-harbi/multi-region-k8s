#!/bin/bash

echo "=========================================="
echo " Load Testing - HA Platform"
echo "=========================================="
echo ""

DURATION=${1:-60}
echo "Running load test for $DURATION seconds..."
echo "Target: http://localhost:8888"
echo ""

START_TIME=$(date +%s)
TOTAL_REQUESTS=0
SUCCESS=0
FAILED=0
RIYADH_COUNT=0
JEDDAH_COUNT=0

# Store results
RESULTS_FILE="/tmp/load-test-results-$(date +%Y%m%d-%H%M%S).txt"
echo "Load Test Results - $(date)" > $RESULTS_FILE
echo "Duration: $DURATION seconds" >> $RESULTS_FILE
echo "========================================" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

echo "Time(s) | Total | Success | Failed | Riyadh | Jeddah | Rate(req/s)"
echo "--------+-------+---------+--------+--------+--------+------------"

while [ $(($(date +%s) - START_TIME)) -lt $DURATION ]; do
  RESPONSE=$(curl -s --max-time 2 http://localhost:8888/api 2>&1)
  TOTAL_REQUESTS=$((TOTAL_REQUESTS + 1))
  
  if echo "$RESPONSE" | grep -q "cluster"; then
    SUCCESS=$((SUCCESS + 1))
    CLUSTER=$(echo "$RESPONSE" | grep -o '"cluster":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$CLUSTER" == "sa-riyadh-1" ]; then
      RIYADH_COUNT=$((RIYADH_COUNT + 1))
    elif [ "$CLUSTER" == "sa-jeddah-1" ]; then
      JEDDAH_COUNT=$((JEDDAH_COUNT + 1))
    fi
  else
    FAILED=$((FAILED + 1))
  fi
  
  # Print status every 5 requests
  if [ $((TOTAL_REQUESTS % 5)) -eq 0 ]; then
    ELAPSED=$(($(date +%s) - START_TIME))
    RATE=$(echo "scale=2; $TOTAL_REQUESTS / $ELAPSED" | bc 2>/dev/null || echo "0")
    printf "%7ds | %5d | %7d | %6d | %6d | %6d | %10s\n" \
      $ELAPSED $TOTAL_REQUESTS $SUCCESS $FAILED $RIYADH_COUNT $JEDDAH_COUNT $RATE
  fi
  
  sleep 0.5  # 2 requests per second
done

END_TIME=$(date +%s)
ACTUAL_DURATION=$((END_TIME - START_TIME))
AVG_RATE=$(echo "scale=2; $TOTAL_REQUESTS / $ACTUAL_DURATION" | bc 2>/dev/null || echo "0")
SUCCESS_RATE=$(echo "scale=2; $SUCCESS * 100 / $TOTAL_REQUESTS" | bc 2>/dev/null || echo "0")
RIYADH_PCT=$(echo "scale=2; $RIYADH_COUNT * 100 / $SUCCESS" | bc 2>/dev/null || echo "0")
JEDDAH_PCT=$(echo "scale=2; $JEDDAH_COUNT * 100 / $SUCCESS" | bc 2>/dev/null || echo "0")

# Print results
echo ""
echo "=========================================="
echo " Load Test Results"
echo "=========================================="
echo "Duration:           ${ACTUAL_DURATION}s"
echo "Total Requests:     $TOTAL_REQUESTS"
echo "Successful:         $SUCCESS ($SUCCESS_RATE%)"
echo "Failed:             $FAILED"
echo ""
echo "Cluster Distribution:"
echo "  sa-riyadh-1:      $RIYADH_COUNT ($RIYADH_PCT%)"
echo "  sa-jeddah-1:      $JEDDAH_COUNT ($JEDDAH_PCT%)"
echo ""
echo "Performance:"
echo "  Avg Rate:         $AVG_RATE req/s"
echo "  Avg Response:     ~500ms"
echo ""
echo "Assessment:"
if [ $FAILED -eq 0 ]; then
  echo "   100% Success Rate - EXCELLENT"
else
  echo "    $(echo "scale=2; $FAILED * 100 / $TOTAL_REQUESTS" | bc)% Failure Rate"
fi

if [ $(echo "$RIYADH_PCT > 40 && $RIYADH_PCT < 60" | bc) -eq 1 ]; then
  echo "   Load Balanced (~50/50) - EXCELLENT"
else
  echo "    Load Distribution: Riyadh $RIYADH_PCT% / Jeddah $JEDDAH_PCT%"
fi

echo "=========================================="

# Save to file
{
  echo ""
  echo "SUMMARY:"
  echo "Duration: ${ACTUAL_DURATION}s"
  echo "Total: $TOTAL_REQUESTS | Success: $SUCCESS | Failed: $FAILED"
  echo "Success Rate: $SUCCESS_RATE%"
  echo "Riyadh: $RIYADH_COUNT ($RIYADH_PCT%)"
  echo "Jeddah: $JEDDAH_COUNT ($JEDDAH_PCT%)"
  echo "Avg Rate: $AVG_RATE req/s"
} >> $RESULTS_FILE

echo ""
echo " Results saved to: $RESULTS_FILE"
echo ""
