#!/bin/bash

go install github.com/tsenart/vegeta@latest

GOPATH=$(go env GOPATH)

$GOPATH/bin/vegeta attack \
    -targets=vegeta_targets.txt \
    -duration 60s \
    -rate 1000/s \
    -timeout 1s \
    -workers 50 \
    -max-workers 50 \
    -header 'Accept: application/json' \
    -header 'Content-Type: application/json' \
    > /tmp/vegeta_results.bin

cat /tmp/vegeta_results.bin \
    | $GOPATH/bin/vegeta report \
    | tee vegeta_report.txt
cat /tmp/vegeta_results.bin \
    | $GOPATH/bin/vegeta report \
    -buckets "[0,500us,1ms,1.5ms,2ms,3ms,4ms,8ms,16ms,32ms,64ms,82ms,100ms,122ms,149ms,182ms,223ms,272ms,332ms,406ms,496ms,512ms,1s]" \
    -type hist[buckets] \
    | tee vegeta_histogram.txt
cat /tmp/vegeta_results.bin | $GOPATH/bin/vegeta plot > vegeta_plot.html