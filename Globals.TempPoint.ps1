#Import-Module VMware.PowerCLI

#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

function export-DGV2CSV ([Windows.Forms.DataGridView]$grid, [String]$File)
<#
  .SYNOPSIS
  Export basic datagrid to CSV file
  .PARAMETER grid
  Datagrid object
  .PARAMETER file
  Path to CSV file
#>
{
	if ($grid.RowCount -eq 0) { return } # nothing to do
	
	$row = New-Object Windows.Forms.DataGridViewRow
	$sw = new-object System.IO.StreamWriter($File)
	
	#Write header line
	$sw.WriteLine(($grid.Columns | % { $_.HeaderText }) -join ',')
	
	#Export contents
	$grid.Rows | % {
		$sw.WriteLine(
			($_.Cells | % { $_.Value }) -join ','
		)
	}
	$sw.Close()
}
function Scramble-String([string]$inputString)
{
	$characterArray = $inputString.ToCharArray()
	$scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length
	$outputString = -join $scrambledStringArray
	return $outputString
}

function Get-RandomCharacters($length, $characters)
{
	
	$random = 1 .. $length | ForEach-Object { Get-Random -Maximum $characters.length }
	$private:ofs = ""
	return [String]$characters[$random]
}

function change-password($vmhost, $action, $inputPass)
{
	$Esxiuser = "root"
	$serverName = $vmhost
	$date = Get-Date
	$succesNote = $date.ToString() + " : Password Changed Successfully"
	$failedNote = $date.ToString() + " : Changing Password failed"
	if ($action -eq 1)
	{
		$password = Scramble-String $password
	}
	elseif ($action -eq 0)
	{
		$password = $inputPass
		
	}
	try
	{
		$esxcli = get-esxcli -vmhost $vmhost -v2
		$esxcli.system.account.set.Invoke(@{ id = $Esxiuser; password = $password; passwordconfirmation = $password })
		$chpassresult = $true
		$chPassRes = New-Object PSObject -Property @{
			ResultNote = $succesNote
			Password   = $password
			Status	   = $true
		}
	}
	catch
	{
		
		$chPassRes = New-Object PSObject -Property @{
			ResultNote = $succesNote
			Password   = $password
			Status	   = $false
		}
	}
	
	return $chPassRes
	
}


function ConvertTo-DataTable
{
    <#
    .Synopsis
        Creates a DataTable from an object
    .Description
        Creates a DataTable from an object, containing all properties (except built-in properties from a database)
    .Example
        Get-ChildItem| Select Name, LastWriteTime | ConvertTo-DataTable
    .Link
        Select-DataTable
    .Link
        Import-DataTable
    .Link
        Export-Datatable
    #>	
	[OutputType([Data.DataTable])]
	param (
		# The input objects
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
		[PSObject[]]$InputObject
	)
	
	begin
	{
		
		$outputDataTable = new-object Data.datatable
		
		$knownColumns = @{ }
		
		
	}
	
	process
	{
		
		foreach ($In in $InputObject)
		{
			$DataRow = $outputDataTable.NewRow()
			$isDataRow = $in.psobject.TypeNames -like "*.DataRow*" -as [bool]
			
			$simpleTypes = ('System.Boolean', 'System.Byte[]', 'System.Byte', 'System.Char', 'System.Datetime', 'System.Decimal', 'System.Double', 'System.Guid', 'System.Int16', 'System.Int32', 'System.Int64', 'System.Single', 'System.UInt16', 'System.UInt32', 'System.UInt64')
			
			$SimpletypeLookup = @{ }
			foreach ($s in $simpleTypes)
			{
				$SimpletypeLookup[$s] = $s
			}
			
			
			foreach ($property in $In.PsObject.properties)
			{
				if ($isDataRow -and
					'RowError', 'RowState', 'Table', 'ItemArray', 'HasErrors' -contains $property.Name)
				{
					continue
				}
				$propName = $property.Name
				$propValue = $property.Value
				$IsSimpleType = $SimpletypeLookup.ContainsKey($property.TypeNameOfValue)
				
				if (-not $outputDataTable.Columns.Contains($propName))
				{
					$outputDataTable.Columns.Add((
							New-Object Data.DataColumn -Property @{
								ColumnName = $propName
								DataType   = if ($issimpleType)
								{
									$property.TypeNameOfValue
								} else {
									'System.Object'
								}
							}
						))
				}
				
				$DataRow.Item($propName) = if ($isSimpleType -and $propValue)
				{
					$propValue
				}
				elseif ($propValue)
				{
					[PSObject]$propValue
				}
				else
				{
					[DBNull]::Value
					
				}
				
			}
			$outputDataTable.Rows.Add($DataRow)
		}
		
	}
	
	end
	{
		 ,$outputDataTable
		
	}
	
}

function Update-DataGridView
{
	<#
	.SYNOPSIS
		This functions helps you load items into a DataGridView.

	.DESCRIPTION
		Use this function to dynamically load items into the DataGridView control.

	.PARAMETER  DataGridView
		The DataGridView control you want to add items to.

	.PARAMETER  Item
		The object or objects you wish to load into the DataGridView's items collection.
	
	.PARAMETER  DataMember
		Sets the name of the list or table in the data source for which the DataGridView is displaying data.

	.PARAMETER AutoSizeColumns
	    Resizes DataGridView control's columns after loading the items.
	#>
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		$Item,
		[Parameter(Mandatory = $false)]
		[string]$DataMember,
		[System.Windows.Forms.DataGridViewAutoSizeColumnsMode]$AutoSizeColumns = 'None'
	)
	$DataGridView.SuspendLayout()
	$DataGridView.DataMember = $DataMember
	
	if ($null -eq $Item)
	{
		$DataGridView.DataSource = $null
	}
	elseif ($Item -is [System.Data.DataSet] -and $Item.Tables.Count -gt 0)
	{
		$DataGridView.DataSource = $Item.Tables[0]
	}
	elseif ($Item -is [System.ComponentModel.IListSource]`
		-or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView])
	{
		$DataGridView.DataSource = $Item
	}
	else
	{
		$array = New-Object System.Collections.ArrayList
		
		if ($Item -is [System.Collections.IList])
		{
			$array.AddRange($Item)
		}
		else
		{
			$array.Add($Item)
		}
		$DataGridView.DataSource = $array
	}
	
	if ($AutoSizeColumns -ne 'None')
	{
		$DataGridView.AutoResizeColumns($AutoSizeColumns)
	}
	
	$DataGridView.ResumeLayout()
}

function UpdateNavButtons
{
	$buttonNext.Enabled = $tabcontrol1.SelectedIndex -lt $tabcontrol1.TabCount - 1
	$buttonPrev.Enabled = $tabcontrol1.SelectedIndex -gt 0
}

function getAllSSHservice()
{
	$sshStatus = Get-VMHost | Where-Object {$_.ConnectionState -ne "NotResponding"} | Get-VMHostService | Where-Object {$_.key -eq "TSM-SSH"} | select vmhost, policy, running, OperationResult
		
	return $sshStatus
}

function getHostsSSHservice($vmhost)
{
	$sshStatus = Get-VMHostService -VMHost $vmhost | Where-Object { $_.key -eq "TSM-SSH" } | select vmhost, policy, running, OperationResult
	
	return $sshStatus
}
function sshServiceActions($vmhostName, $actionType)
{
	# if action type is eaual to 0 start ssh service on hosts
	if ($actionType -eq 0)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.Key -eq "TSM-SSH" } | Start-VMHostService -Confirm:$false
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "SSH Service Successfully started"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "SSh Service start Failed"
		}
				
		return $result
	}
	# if action type is equal to 1 stop ssh service on hosts
	elseif ($actionType -eq 1)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.Key -eq "TSM-SSH" } | Stop-VMHostService -Confirm:$false
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "SSH Service Successfully Stopped"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "SSh Service stop Failed"
		}
		
		return $result
		
	}
	# if action type is equal 2 restart ssh Service on hosts
	elseif ($actionType -eq 2)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.Key -eq "TSM-SSH" } | Restart-VMHostService -Confirm:$false
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "SSH Service Successfully Restarted"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "SSh Service Restart Failed"
		}
		
		return $result
	}
	# if action type is equal to 3 set service policy Off / Stop and start manually
	elseif ($actionType -eq 3)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.Key -eq "TSM-SSH" } | Set-VMHostService -Policy Off
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "Policy Set, Stop and start manually"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "setting policy failed"
		}
		
		return $result
	}
	# if action type is equal to 3 set service policy On / Stop and start with host
	elseif ($actionType -eq 4)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.Key -eq "TSM-SSH" } | Set-VMHostService -Policy on
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "Policy Set, Stop and start with host"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "setting policy failed"
		}
		
		return $result
	}
	
}

function getAllNTP()
{
	$ntpStatus = Get-VMHost | Where-Object { $_.ConnectionState -ne "NotResponding" } | Sort Name |
	
	Select Name, @{ N = "NTPServers"; E = { $_ | Get-VMHostNtpServer | Out-String } },
		   @{ N = "Policy"; E = { (Get-VmHostService -VMHost $_ | Where-Object { $_.key -eq "ntpd" } | Select -ExpandProperty Policy) } },
		   
		   @{ N = "running"; E = { (Get-VmHostService -VMHost $_ | Where-Object { $_.key -eq "ntpd" } | Select -ExpandProperty Running )} },
		   @{ N = "Operation Result"; E = {$null} }
	
	
	return $ntpStatus
}




function getHostNTP($vmhost)
{
	$ntpStatus = Get-VMHost -Name $vmhost |
	
	Select Name, @{ N = "NTPServers"; E = { $_ | Get-VMHostNtpServer } },
		   @{ N = "Policy"; E = { (Get-VmHostService -VMHost $_ | Where-Object { $_.key -eq "ntpd" } | Select -ExpandProperty Policy) } },
		   
	   	   @{ N = "running"; E = { (Get-VmHostService -VMHost $_ | Where-Object { $_.key -eq "ntpd" } | Select -ExpandProperty Running) } }
		
		return $ntpStatus
}



function NTPActions($vmhostname, $actiontype)
{	# if actiontype = 0, Start NTP client service
	if ($actiontype -eq 0)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.key -eq "ntpd" } | Start-VMHostService -Confirm:$false
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Client Service Successfully started"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Client Service start Failed"
		}
		
		return $result
	}
	# if actiontype = 1, Stop NTP client service
	elseif ($actiontype -eq 1)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.key -eq "ntpd" } | Stop-VMHostService -Confirm:$false
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Client Service Successfully stopped"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Client Service stop Failed"
		}
		
		return $result
	}
	# if actiontype = 2, restart NTP Client Service
	elseif ($actiontype -eq 2)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.key -eq "ntpd" } | Restart-VMHostService -Confirm:$false
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Client Service Successfully Restarted"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Client Service restart Failed"
		}
		
		return $result
	}
	# if actiontype = 3, set NTP policy to Off (start manually)
	elseif ($actiontype -eq 3)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.key -eq "ntpd" } | Set-VMHostService -policy Off
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Policy set, Start and Stop Manually"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Policy Set Failed"
		}
		
		return $result
	}
	# if actiontype = 4, set NTP policy to on (Start and stop with host)
	elseif ($actiontype -eq 4)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		try
		{
			Get-VMHostService -VMHost $vmhostName | Where-Object { $_.key -eq "ntpd" } | Set-VMHostService -policy on
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Policy set, Start and Stop with host"
		}
		catch
		{
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value "NTP Policy Set Failed"
		}
		
		return $result
	}
	
}


function setNTPServer ($vmhostname, $ntpservers, $actionType)
{
	if ($actionType -eq 0)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
		$currentntpServers = Get-VMHost -Name $vmhostName | Get-VMHostNtpServer
		Get-VMHost -Name $vmhostname | Remove-VMHostNtpServer -NtpServer $currentntpServers -Confirm:$false
		try
		{
			Get-VMHost -Name $vmhostname | Add-VMHostNtpServer -NtpServer $ntpservers
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value $ntpservers, "NTP replaced successfully"
		}
		catch
		{
			Get-VMHost -Name $vmhostname | Add-VMHostNtpServer -NtpServer $currentntpServers
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value $currentntpServers, "Replacing NTP Failed, Roll Back to old NTP servers"
		}
	}
	elseif ($actionType -eq 1)
	{
		$result = New-Object -TypeName PSObject
		$result | Add-Member -Type NoteProperty -Name Name -Value $vmhostName
	
		try
		{
			Get-VMHost -Name $vmhostname | Add-VMHostNtpServer -NtpServer $ntpservers
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value $ntpservers, "NTP added successfully"
		}
		catch
		{
			Get-VMHost -Name $vmhostname | Add-VMHostNtpServer -NtpServer $currentntpServers
			$result | Add-Member -Type NoteProperty -Name OperationResult -Value $currentntpServers, "Adding NTP Failed"
		}
	}
	
	return $result
}

#Sample function that provides the location of the script
###################### My Functions #####################



############## My Variables ####################
$global:connectedvCenter = ''
#$connectionStat = 0
$global:connectionStat = 0
$global:hosts
$password = Get-RandomCharacters -length 4 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 3 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 3 -characters '1234567890'
$password += Get-RandomCharacters -length 2 -characters '!"$%&/()?}{@#*'
$global:sshDT
$global:ntpDT