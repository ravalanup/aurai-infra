#Requires -Version 5.1
<#
.SYNOPSIS
  Shows the state of the local platform services.
#>
[CmdletBinding()]
param(
    [string]$ClusterName = "aurai",
    [string]$Namespace = "aurai-system"
)

$ErrorActionPreference = "Stop"

kubectl config use-context "kind-$ClusterName" | Out-Null
kubectl get pods,svc,pvc --namespace $Namespace
Write-Host ""
kubectl get namespaces -l app.kubernetes.io/part-of=aurai
