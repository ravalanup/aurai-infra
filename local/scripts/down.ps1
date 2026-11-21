#Requires -Version 5.1
<#
.SYNOPSIS
  Deletes the local kind cluster (and all data in it).
#>
[CmdletBinding()]
param([string]$ClusterName = "aurai")

$ErrorActionPreference = "Stop"

if (-not (Get-Command kind -ErrorAction SilentlyContinue)) { throw "Missing required tool: kind." }

kind delete cluster --name $ClusterName
