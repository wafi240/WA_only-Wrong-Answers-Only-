#!/bin/bash
PASS=0
FAIL=0
for i in 1 2 3 4 5 6 7 8 9 10; do
    PID="P10$(printf '%02d' $i)"
    SOL="assets/solutions/sol$i.cpp"
    BIN="/tmp/verify_$PID"
    
    if [ ! -f "$SOL" ]; then
        echo "MISSING: $SOL"
        FAIL=$((FAIL+1))
        continue
    fi
    
    g++ -O2 -std=c++17 -o $BIN $SOL 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "CE: $SOL"
        FAIL=$((FAIL+1))
        continue
    fi
    
    all_pass=1
    for t in 1 2 3 4 5; do
        IN="assets/testcases/$PID/$t.in"
        OUT="assets/testcases/$PID/$t.out"
        if [ ! -f "$IN" ]; then break; fi
        
        got=$($BIN < $IN 2>/dev/null)
        expected=$(cat $OUT)
        if [ "$got" = "$expected" ]; then
            echo "  $PID test$t: AC"
        else
            echo "  $PID test$t: WA"
            echo "    Expected: $(echo $expected | head -c 50)"
            echo "    Got:      $(echo $got | head -c 50)"
            all_pass=0
        fi
    done
    
    if [ $all_pass -eq 1 ]; then
        echo "OK: $PID"
        PASS=$((PASS+1))
    else
        echo "FAIL: $PID"
        FAIL=$((FAIL+1))
    fi
done
echo ""
echo "Results: $PASS OK, $FAIL FAILED"
