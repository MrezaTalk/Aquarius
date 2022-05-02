[VMware.VimAutomation.Sdk.Interop.V1.CoreServiceFactory]::CoreService.OnImportModule(
    "VMware.VimAutomation.ViCore.Cmdlets",
    (Split-Path $script:MyInvocation.MyCommand.Path));

function global:New-DatastoreDrive([string] $Name, $Datastore){
<#
.SYNOPSIS
This function creates a new datastore drive.
.DESCRIPTION
This function creates a new drive that is mapped to a location in a datastore.
.PARAMETER Name
Specifies a name for the new drive.
.PARAMETER Datastore
Specifies the datastore for which you want to create a new drive.
#>
	begin {
		if ($Datastore) {
			Write-Output $Datastore | New-DatastoreDrive -Name $Name
		}
	}
	process {
		if ($_) {
			$ds = $_
			New-PSDrive -Name $Name -Root \ -PSProvider VimDatastore -Datastore $ds -Scope global
		}
	}
	end {
	}
}

function global:New-VIInventoryDrive([string] $Name, $Location){
<#
.SYNOPSIS
This function creates a new drive for an inventory item.
.DESCRIPTION
This function creates a new inventory drive that is mapped to a location in a datastore.
.PARAMETER Name
Specifies the name of the new inventory drive.
.PARAMETER Location
Specifies the vSphere container objects (such as folders, data centers, and clusters) for which you want to create the drive.
#>
	begin {
		if ($Location) {
			Write-Output $Location | New-VIInventoryDrive -Name $Name
		}
	}
	process {
		if ($_) {
			$location = $_
			New-PSDrive -Name $name -Root \ -PSProvider VimInventory -Location $location -Scope global
		}
	}
	end {
	}
}

function global:Get-VICommand([string] $Name = "*") {
<#
.SYNOPSIS
This function retrieves all commands of the VMware modules.
.DESCRIPTION
This function retrieves all commands of the imported VMware modules, including cmdlets, aliases, and functions.
.PARAMETER Name
Specifies the name of the command you want to retrieve.
#>
  Get-Command -Module VMware.* -Name $Name
}


function HookGetViewAutoCompleter() {	
	if ( -not (Test-Path Function:\TabExpansionDefault) ) {
		
		# This is the new definition of the TabExpansion2 function
		$tabExpansionProxyFunction = 
		'
			[CmdletBinding(DefaultParameterSetName = ''ScriptInputSet'')]
			Param(
				[Parameter(ParameterSetName = ''ScriptInputSet'', Mandatory = $true, Position = 0)]
				[string] $inputScript,

				[Parameter(ParameterSetName = ''ScriptInputSet'', Mandatory = $true, Position = 1)]
				[int] $cursorColumn,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 0)]
				[System.Management.Automation.Language.Ast] $ast,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 1)]
				[System.Management.Automation.Language.Token[]] $tokens,

				[Parameter(ParameterSetName = ''AstInputSet'', Mandatory = $true, Position = 2)]
				[System.Management.Automation.Language.IScriptPosition] $positionOfCursor,

				[Parameter(ParameterSetName = ''ScriptInputSet'', Position = 2)]
				[Parameter(ParameterSetName = ''AstInputSet'', Position = 3)]
				[Hashtable] $options = $null
			)

			End
			{
				if ($psCmdlet.ParameterSetName -eq ''ScriptInputSet'') {
					$shouldProcessInput = [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::ShouldProcess(
						<#inputScript#>  $inputScript,
						<#cursorColumn#> $cursorColumn,
						<#options#>        $options)
					
					if ($shouldProcessInput) {
						return [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::CompleteInput(
							<#inputScript#>  $inputScript,
							<#cursorColumn#> $cursorColumn,
							<#options#>        $options)
					} else {
						return global:TabExpansionDefault $inputScript $cursorColumn $options
					}
				} else {
					$shouldProcessInput = [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::ShouldProcess(
						<#ast#>              $ast,
						<#tokens#>           $tokens,
						<#positionOfCursor#> $positionOfCursor,
						<#options#>          $options)
					
					if ($shouldProcessInput) {
						return [VMware.VimAutomation.ViCore.Cmdlets.Commands.DotNetInterop.GetViewAutoCompleter]::CompleteInput(
							<#ast#>              $ast,
							<#tokens#>           $tokens,
							<#positionOfCursor#> $positionOfCursor,
							<#options#>          $options)
					} else {
						return global:TabExpansionDefault $ast $tokens $positionOfCursor $options
					}
				}
			}
		'
	
		# Declare a new function that will hold the current tab expansion implementation
		Copy-Item Function:\TabExpansion2 Function:\global:TabExpansionDefault
		
		# Override the current tab expansion implementation to hook our proxy
		Set-Item -Path Function:\TabExpansion2 -Value $tabExpansionProxyFunction
	}
}


# Aliases
set-alias Get-VIServer Connect-VIServer -Scope Global
set-alias Get-VC Connect-VIServer -Scope Global
set-alias Get-ESX Connect-VIServer -Scope Global
set-alias Answer-VMQuestion Set-VMQuestion -Scope Global
set-alias Get-PowerCLIDocumentation Get-PowerCLIHelp -Scope Global
set-alias Get-VIToolkitVersion Get-PowerCLIVersion -Scope Global
set-alias Get-VIToolkitConfiguration Get-PowerCLIConfiguration -Scope Global
set-alias Set-VIToolkitConfiguration Set-PowerCLIConfiguration -Scope Global
set-alias Export-VM Export-VApp -Scope Global
set-alias Apply-VMHostProfile Invoke-VMHostProfile -Scope Global
set-alias Apply-DrsRecommendation Invoke-DrsRecommendation -Scope Global
set-alias Shutdown-VMGuest Stop-VMGuest -Scope Global

# Uid utilities
$global:UidUtil = [VMware.VimAutomation.ViCore.Cmdlets.Utilities.UidUtil]::Create()
add-member -inputobject $global:UidUtil -membertype scriptmethod -name GetHelp -Value { Get-Help about_uid }

HookGetViewAutoCompleter

# SIG # Begin signature block
# MIIexgYJKoZIhvcNAQcCoIIetzCCHrMCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBvIPgAyfK0gNGS
# o13JSibFq6wu7p8piZ9fn/fdI1s47qCCDdowggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggciMIIFCqADAgECAhAOxvKydqFGoH0ObZNXteEIMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjEwODEwMDAwMDAwWhcNMjMwODEw
# MjM1OTU5WjCBhzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExEjAQ
# BgNVBAcTCVBhbG8gQWx0bzEVMBMGA1UEChMMVk13YXJlLCBJbmMuMRUwEwYDVQQD
# EwxWTXdhcmUsIEluYy4xITAfBgkqhkiG9w0BCQEWEm5vcmVwbHlAdm13YXJlLmNv
# bTCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAMD6lJG8OWkM12huIQpO
# /q9JnhhhW5UyW9if3/UnoFY3oqmp0JYX/ZrXogUHYXmbt2gk01zz2P5Z89mM4gqR
# bGYC2tx+Lez4GxVkyslVPI3PXYcYSaRp39JsF3yYifnp9R+ON8O3Gf5/4EaFmbeT
# ElDCFBfExPMqtSvPZDqekodzX+4SK1PIZxCyR3gml8R3/wzhb6Li0mG7l0evQUD0
# FQAbKJMlBk863apeX4ALFZtrnCpnMlOjRb85LsjV5Ku4OhxQi1jlf8wR+za9C3DU
# ki60/yiWPu+XXwEUqGInIihECBbp7hfFWrnCCaOgahsVpgz8kKg/XN4OFq7rbh4q
# 5IkTauqFhHaE7HKM5bbIBkZ+YJs2SYvu7aHjw4Z8aRjaIbXhI1G+NtaNY7kSRrE4
# fAyC2X2zV5i4a0AuAMM40C1Wm3gTaNtRTHnka/pbynUlFjP+KqAZhOniJg4AUfjX
# sG+PG1LH2+w/sfDl1A8liXSZU1qJtUs3wBQFoSGEaGBeDQIDAQABo4ICJTCCAiEw
# HwYDVR0jBBgwFoAUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHQYDVR0OBBYEFIhC+HL9
# QlvsWsztP/I5wYwdfCFNMB0GA1UdEQQWMBSBEm5vcmVwbHlAdm13YXJlLmNvbTAO
# BgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwgbUGA1UdHwSBrTCB
# qjBToFGgT4ZNaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3Rl
# ZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcmwwU6BRoE+GTWh0
# dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWdu
# aW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMD4GA1UdIAQ3MDUwMwYGZ4EMAQQB
# MCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYI
# KwYBBQUHAQEEgYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0
# LmNvbTBcBggrBgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5j
# cnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEACQAYaQI6Nt2KgxdN
# 6qqfcHB33EZRSXkvs8O9iPZkdDjEx+2fgbBPLUvk9A7T8mRw7brbcJv4PLTYJDFo
# c5mlcmG7/5zwTOuIs2nBGXc/uxCnyW8p7kD4Y0JxPKEVQoIQ8lJS9Uy/hBjyakeV
# ef982JyzvDbOlLBy6AS3ZpXVkRY5y3Va+3v0R/0xJ+JRxUicQhiZRidq2TCiWEas
# d+tLL6jrKaBO+rmP52IM4eS9d4Yids7ogKEBAlJi0NbvuKO0CkgOlFjp1tOvD4sQ
# taHIMmqi40p4Tjyf/sY6yGjROXbMeeF1vlwbBAASPWpQuEIxrNHoVN30YfJyuOWj
# zdiJUTpeLn9XdjM3UlhfaHP+oIAKcmkd33c40SFRlQG9+P9Wlm7TcPxGU4wzXI8n
# Cw/h235jFlAAiWq9L2r7Un7YduqsheJVpGoXmRXJH0T2G2eNFS5/+2sLn98kN2Cn
# J7j6C242onjkZuGL2/+gqx8m5Jbpu9P4IAeTC1He/mX9j6XpIu+7uBoRVwuWD1i0
# N5SiUz7Lfnbr6Q1tHMXKDLFdwVKZos2AKEZhv4SU0WvenMJKDgkkhVeHPHbTahQf
# P1MetR8tdRs7uyTWAjPK5xf5DLEkXbMrUkpJ089fPvAGVHBcHRMqFA5egexOb6sj
# tKncUjJ1xAAtAExGdCh6VD2U5iYxghBCMIIQPgIBATB9MGkxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1
# c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTECEA7G
# 8rJ2oUagfQ5tk1e14QgwDQYJYIZIAWUDBAIBBQCggZYwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwKgYKKwYB
# BAGCNwIBDDEcMBqhGIAWaHR0cDovL3d3dy52bXdhcmUuY29tLzAvBgkqhkiG9w0B
# CQQxIgQg1Ui8YC+CnvZMKWNmoDfza7rY5Egqv+22oyEVBA7GCXUwDQYJKoZIhvcN
# AQEBBQAEggGALxK8m1HqlG7yvhMphAP+IRBFo9CLNgWXqPIYdhCEezYWwVqfds2r
# JB37/QKeoUwu1Pi1TH3PIaRMu46Qi7TdFRSybKTu1ayYMk2KYrmgTilDRs2EBmcY
# dbTl1YW/tkKckg9Y/j6khtllaEknZWuU9CggBfwotkODGauwFrpuIlUl4UxnzmWp
# AVKBr5VH2k++zaBUySa6CdfiRYRUZUrt9kj94RDEljPkqkBBTW6w+0a1rPl4oErC
# P+7hlNnj8xonlvdEN9KVH1lJ27gYUiifWS7hS/tHphT0G38K/mge71mbj/Qwj1+E
# S1R2FTXlksUq/D/Futhu3svun7nKkWmVkzWjZ1VbldlPzBGpCfpr+GW6bAc0BeUZ
# CTogpX7pFLF6FvrnMS+ovWjnyO5c5nD6l8kAAsyZCQXTNLInz8KnQbaUkrMOMv/R
# DqTaZq7gnjdA8CjT+hjawbmWxwmCiVnw2XFA28xQxQgxX/vMQNaUwHAdyGEGvTzK
# UAVBIBzAiLuLoYINfTCCDXkGCisGAQQBgjcDAwExgg1pMIINZQYJKoZIhvcNAQcC
# oIINVjCCDVICAQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0BCRABBKBoBGYw
# ZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIIT5XSBSS27cs93PcH2w
# wX6FXAEhfMkBUC8NxueGvStsAhBw7A13rCSLQMWYrw0xlTCjGA8yMDIxMTIyMDEz
# MjgwN1qgggo3MIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG
# 9w0BAQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkw
# FwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEy
# IEFzc3VyZWQgSUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMx
# MDEwNjAwMDAwMFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2U
# tAxQtSYQ/h3Ib5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4C
# GPN4bbx9+cdtCT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xO
# bTOKfF1FLUuxUOZBOjdWhtyTI433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wOD
# MSlKXAwxikqMiMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwf
# oYervnpbCiAvSwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgw
# ggG0MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoG
# CCsGAQUFBwMIMEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEW
# G2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4p
# rtLkYaWyoiWyyBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYD
# VR0fBGowaDAyoDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNz
# dXJlZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEy
# LWFzc3VyZWQtdHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGlu
# Z0NBLmNydDANBgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0
# CiNHo6uS0iXEcFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1
# UUp4eTZ6J7fz51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2Q
# zI2hF3MN9PNlOXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnY
# Ipp1FUL1LTI4gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oN
# cX6Xt/Q/hOvB46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBTEw
# ggQZoAMCAQICEAqhJdbWMht+QeQF2jaXwhUwDQYJKoZIhvcNAQELBQAwZTELMAkG
# A1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRp
# Z2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENB
# MB4XDTE2MDEwNzEyMDAwMFoXDTMxMDEwNzEyMDAwMFowcjELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGlu
# ZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL3QMu5LzY9/3am6
# gpnFOVQoV7YjSsQOB0UzURB90Pl9TWh+57ag9I2ziOSXv2MhkJi/E7xX08PhfgjW
# ahQAOPcuHjvuzKb2Mln+X2U/4Jvr40ZHBhpVfgsnfsCi9aDg3iI/Dv9+lfvzo7oi
# PhisEeTwmQNtO4V8CdPuXciaC1TjqAlxa+DPIhAPdc9xck4Krd9AOly3UeGheRTG
# TSQjMF287DxgaqwvB8z98OpH2YhQXv1mblZhJymJhFHmgudGUP2UKiyn5HU+upgP
# hH+fMRTWrdXyZMt7HgXQhBlyF/EXBu89zdZN7wZC/aJTKk+FHcQdPK/P2qwQ9d2s
# rOlW/5MCAwEAAaOCAc4wggHKMB0GA1UdDgQWBBT0tuEgHf4prtLkYaWyoiWyyBc1
# bjAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzASBgNVHRMBAf8ECDAG
# AQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB5Bggr
# BgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDov
# L2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6
# oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNybDBQBgNVHSAESTBHMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcC
# ARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sBwEwDQYJ
# KoZIhvcNAQELBQADggEBAHGVEulRh1Zpze/d2nyqY3qzeM8GN0CE70uEv8rPAwL9
# xafDDiBCLK938ysfDCFaKrcFNB1qrpn4J6JmvwmqYN92pDqTD/iy0dh8GWLoXoIl
# HsS6HHssIeLWWywUNUMEaLLbdQLgcseY1jxk5R9IEBhfiThhTWJGJIdjjJFSLK8p
# ieV4H9YLFKWA1xJHcLN11ZOFk362kmf7U2GJqPVrlsD0WGkNfMgBsbkodbeZY4Ui
# jGHKeZR+WfyMD+NvtQEmtmyl7odRIeRYYJu6DC0rbaLEfrvEJStHAgh8Sa4TtuF8
# QkIoxhhWz0E0tmZdtnR79VYzIi8iNrJLokqV2PWmjlIxggKGMIICggIBATCBhjBy
# MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
# d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQg
# SUQgVGltZXN0YW1waW5nIENBAhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQC
# AQUAoIHRMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUx
# DxcNMjExMjIwMTMyODA3WjArBgsqhkiG9w0BCRACDDEcMBowGDAWBBTh14Ko4ZG+
# 72vKFpG1qrSUpiSb8zAvBgkqhkiG9w0BCQQxIgQg/lO/gFlN3tJ8QWt4ck/kATxu
# UdoeuJJpSipf1Lt6d40wNwYLKoZIhvcNAQkQAi8xKDAmMCQwIgQgsxCQBrwK2YMH
# kVcp4EQDQVyD4ykrYU8mlkyNNXHs9akwDQYJKoZIhvcNAQEBBQAEggEATCtxSbTw
# Ju62J0SdbE6EWGA9aYJTcd7FGP91XyNA2J/pfiA2ioWGKg5rwdrIXCwMZvkENMsx
# TsAXg/49uXeWwJzWgViZiJQO9AUsIVZd9OfBG79g8EbVHCQXdtkom+qEg1uE4Ukp
# nnOg+HoFnGmmyTfBB5c45aCO5IBk5/rNvdcdqoUakyuiagu0XKp2gUTEggSwokgO
# ynDfI9iy22g+0mi6BBTb2+QnX0wXw/8PvCiMkc4OBGExrY87d2RCADB0zY5Jz6km
# dlM+0JJdx1yNfnqInkXPGPTeDTl3N04wDiGiOamRgdCsl7j+p1mmjNH0kaM7fPef
# CHmms2ZF+wvNCg==
# SIG # End signature block
