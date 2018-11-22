k8s-mgr.sh


# Lists nodes with disk pressure.
fn::list_nodes_with_disk_pressure()
{
  kubectl get no -ojson | jq -r '.items[] | select(.status.conditions[] | select(.status == "True") | select(.type == "DiskPressure")) | .metadata.name'
}