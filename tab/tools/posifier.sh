#!/bin/bash


BASE_POWER=$(grep 'Empty Loop' ./posifier_data/benchmark_metrics.csv | cut -f 4 -d,)
ROOF_POWER=$(grep 'FIRESTARTER' ./posifier_data/benchmark_metrics.csv | cut -f 4 -d,)

tail -n +2 ../data/code_metrics.csv > LOCAL_METRICS

cut -f 2,4 -d, LOCAL_METRICS | tr , ' ' | while read T P; do
  ruby ../../plot/tools/pose_calculations.rb --base-power $BASE_POWER --roof-power $ROOF_POWER --code-time $T --code-power $P --delay-exponent 2 --energy-exponent 1 --format=table 
done > ALL_OUT

grep Energy ALL_OUT > ENERGY_OUT
grep Runtime ALL_OUT > RUNTIME_OUT

(
  head -n 1 ALL_OUT | sed 's/Axis/Code/'
  paste LOCAL_METRICS ENERGY_OUT | cut -f 1,5- -d,
) | egrep -v 'Empty Loop|Linpack|FIRESTARTER' > code_pose_energy.csv

(
  head -n 1 ALL_OUT | sed 's/Axis/Code/'
  paste LOCAL_METRICS RUNTIME_OUT | cut -f 1,5- -d,
) | egrep -v 'Empty Loop|Linpack|FIRESTARTER' > code_pose_time.csv

rm ALL_OUT RUNTIME_OUT ENERGY_OUT LOCAL_METRICS

