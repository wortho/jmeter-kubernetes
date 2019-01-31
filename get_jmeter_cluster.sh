working_dir=`pwd`
tenant=`awk '{print $NF}' $working_dir/tenant_export`
echo $tenant
master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
grafana_pod=`kubectl get po -n $tenant | grep jmeter-grafana | awk '{print $1}'`
echo $master_pod
echo $grafana_pod
kubectl get deployments -n $tenant
kubectl get pods -n $tenant

## grafana 
kubectl port-forward -n $tenant $grafana_pod 3001:3000 &

## update config map
kubectl get configmaps -n $tenant
kubectl get configmaps -n $tenant jmeter-load-test -o yaml
kubectl replace -n $tenant -f $working_dir/jmeter_master_configmap.yaml
kubectl delete -n $tenant pod/$master_pod
kubectl rollout status -w -n $tenant deployments/jmeter-master
kubectl get pods -n $tenant

# get new pod
master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
kubectl exec -ti -n $tenant $master_pod -- cat load_test

## view jmeter logs
kubectl exec -ti -n $tenant $master_pod -- cat jmeter.log