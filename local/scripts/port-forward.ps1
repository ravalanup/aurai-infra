#Requires -Version 5.1
<#
.SYNOPSIS
  Forwards the platform services to localhost until you press Ctrl+C.
  Keycloak 8080, Qdrant 6333, Postgres 5432, Redis 6379, OTLP 4317/4318.
#>
[CmdletBinding()]
param([string]$Namespace = "aurai-system")

$ErrorActionPreference = "Stop"

$forwards = @(
    @{ Service = "keycloak";       Ports = @("8080:8080") },
    @{ Service = "qdrant";         Ports = @("6333:6333", "6334:6334") },
    @{ Service = "postgres";       Ports = @("5432:5432") },
    @{ Service = "redis";          Ports = @("6379:6379") },
    @{ Service = "otel-collector"; Ports = @("4317:4317", "4318:4318") }
)

$procs = @()
foreach ($f in $forwards) {
    $kubectlArgs = @("port-forward", "--namespace", $Namespace, "svc/$($f.Service)") + $f.Ports
    $procs += Start-Process -FilePath "kubectl" -ArgumentList $kubectlArgs -PassThru -WindowStyle Hidden
}

Write-Host "Port-forwarding started. Press Ctrl+C to stop."
Write-Host "  Keycloak   http://localhost:8080"
Write-Host "  Qdrant     http://localhost:6333/dashboard"
Write-Host "  Postgres   localhost:5432"
Write-Host "  Redis      localhost:6379"
Write-Host "  OTLP       localhost:4317 (gRPC), localhost:4318 (HTTP)"

try {
    Wait-Process -Id ($procs | ForEach-Object { $_.Id })
} finally {
    $procs | Stop-Process -Force -ErrorAction SilentlyContinue
}
