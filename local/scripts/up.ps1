#Requires -Version 5.1
<#
.SYNOPSIS
  Creates the local kind cluster and installs the aurai-platform chart.
.EXAMPLE
  .\local\scripts\up.ps1
#>
[CmdletBinding()]
param(
    [string]$ClusterName = "aurai",
    [string]$Namespace = "aurai-system"
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

foreach ($tool in "docker", "kind", "kubectl", "helm") {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        throw "Missing required tool: $tool. See docs/local-development.md."
    }
}

docker info *> $null
if ($LASTEXITCODE -ne 0) { throw "Docker is not running. Start Docker Desktop and retry." }

$existing = @(kind get clusters 2>$null)
if ($existing -notcontains $ClusterName) {
    Write-Host "Creating kind cluster '$ClusterName'..."
    kind create cluster --name $ClusterName --config (Join-Path $root "local\kind-config.yaml")
    if ($LASTEXITCODE -ne 0) { throw "kind create cluster failed." }
} else {
    Write-Host "kind cluster '$ClusterName' already exists."
}

kubectl config use-context "kind-$ClusterName" | Out-Null

# Create the platform namespace with Pod Security labels before installing the chart.
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace $Namespace pod-security.kubernetes.io/enforce=baseline --overwrite | Out-Null

Write-Host "Installing aurai-platform..."
helm upgrade --install aurai-platform (Join-Path $root "charts\aurai-platform") `
    --namespace $Namespace `
    --values (Join-Path $root "charts\aurai-platform\values-local.yaml") `
    --wait --timeout 10m
if ($LASTEXITCODE -ne 0) { throw "helm install failed." }

Write-Host ""
Write-Host "Done. Next: .\local\scripts\port-forward.ps1  (Keycloak http://localhost:8080)"
