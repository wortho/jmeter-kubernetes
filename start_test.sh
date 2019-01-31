#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir="`pwd`"

#Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

jmx="$1"
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

props="$2"
[ -n "$props" ] || read -p 'Enter path to the jmx file ' props

if [ ! -f "$props" ];
then
    echo "Properties file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"
props_name="$(basename "$props")" 

echo "Running $test_name with properties $props_name"

#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl exec -ti -n $tenant $master_pod -- cp -r load_test jmeter/load_test
kubectl exec -ti -n $tenant $master_pod -- chmod 755 jmeter/load_test

kubectl cp "$jmx" -n $tenant "$master_pod:/$test_name"
kubectl cp "$props" -n $tenant "$master_pod:/$props_name"

## Echo Starting Jmeter load test

kubectl exec -ti -n $tenant $master_pod -- bin/bash load_test "$test_name" "$props_name"
