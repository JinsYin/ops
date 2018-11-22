#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

# kcadm policy add-scc-to-user privileged system:serviceaccount:default:router
# kcadm policy add-cluster-role-to-user cluster-reader system:serviceaccount:default.router
fn::policy()
{

}

# kcadm router ose-router --replicas=1 --service-account=router --selector='infra=yes'
fn::router()
{

}

main()
{

}

main $@
