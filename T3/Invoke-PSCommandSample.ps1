<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
<#
.SYNOPSIS 
    This runbook calls a command inside of an Azure VM

.DESCRIPTION
    This runbook connects into an Azure virtual machine and runs the PowerShell command passed in.
    It has a dependency on the Connect-AzureVM runbook to set up the connection to the virtual machine
    before the command can be run.

.PARAMETER AzureSubscriptionName
    Name of the Azure subscription to connect to
    
.PARAMETER AzureOrgIdCredential
    A credential containing an Org Id username / password with access to this Azure subscription.

	If invoking this runbook inline from within another runbook, pass a PSCredential for this parameter.

	If starting this runbook using Start-AzureAutomationRunbook, or via the Azure portal UI, pass as a string the
	name of an Azure Automation PSCredential asset instead. Azure Automation will automatically grab the asset with
	that name and pass it into the runbook.
    
.PARAMETER ServiceName
    Name of the cloud service where the VM is located.

.PARAMETER VMName    
    Name of the virtual machine that you want to connect to  

.PARAMETER VMCredentialName
    Name of a PowerShell credential asset that is stored in the Automation service.
    This credential should have access to the virtual machine.
 
.PARAMETER PSCommand
    PowerShell command that you want to run inside the Azure virtual machine.

.EXAMPLE
    Invoke-PSCommandSample -AzureSubscriptionName "Visual Studio Ultimate with MSDN" -ServiceName "Finance" -VMName "WebServer01" -VMCredentialName "FinanceCredentials" -PSCommand "ipconfig /all" -AzureOrgIdCredential $cred

.NOTES
    AUTHOR: System Center Automation Team
    LASTEDIT: Aug 14, 2014 
#>
workflow Invoke-PSCommandSample {
	
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
		Workflow Invoke-PSCommandSample
		
        		$AzureSubscriptionName = Get-AutomationVariable -Name 'AzureSubscriptionName',
        		$AzureOrgIdCredential = Get-AutomationPSCredential -Name 'AzureOrgIdCredential',
        		$ResourceGroupName = Get-AutomationVariable -Name 'Resourcegroupname',
        		$VMName = Get-AutomationVariable -Name 'VMName',  
        		$VMCredentialName = Get-AutomationPSCredential -Name 'vmcredentialname',
        		$PSCommand = whoami
       		
    		# Get credentials to Azure VM
    		Switch-AzureMode AzureResourceManager
    		$Credential = Get-AutomationPSCredential -Name $VMCredentialName    
			if ($Credential -eq $null)
    		{
        		throw "Could not retrieve '$VMCredentialName' credential asset. Check that you created this asset in the Automation service."
    		}     
    		
			# Set up Azure connection by calling the Connect-Azure runbook. You should call this runbook after
			# every CheckPoint-WorkFlow to ensure that the management certificate is available if this runbook
			# gets interrupted and starts from the last checkpoint
    		$Uri = Connect-AzureVM -AzureSubscriptionName $AzureSubscriptionName -AzureOrgIdCredential $AzureOrgIdCredential -ResourceGroupName $ResourceGroupName -VMName $VMName 
    		
			# Run a command on the Azure VM
    		$PSCommandResult = InlineScript {        
        		Invoke-command -ConnectionUri $Using:Uri -credential $Using:Credential -ScriptBlock {
            		Invoke-Expression $Args[0]
        		} -Args $Using:PSCommand
		
    		}
			
			$PSCommandResult
		}
	}
}