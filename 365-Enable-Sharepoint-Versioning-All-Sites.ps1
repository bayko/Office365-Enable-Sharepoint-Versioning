if (Get-Module -ListAvailable -Name MSOnline) {
} else {
    Write-Host "Microsoft Online Powershell Module is Missing, Please install before re-running script"
    Exit
}
if (Get-Module -ListAvailable -Name Microsoft.Online.Sharepoint.Powershell) {
} else {
    Write-Host "Sharepoint Online Powershell Module is Missing, please install before re-running script"
    Exit
}

Write-Host 'Connecting to all Office 365 - MSOL/SPO' -foregroundcolor Green
$Username = $args[0]
$Password = $args[1]
if ((!$Username) -or (!$Password)){
    Write-Host 'You must supply global admin credentials as parameters when executing this script ( ie: C:\> .\STS-Office365-Provisioning.ps1 office365admin@company.com Password99 )' -foregroundcolor Red
    Exit
}
$SecureStringPwd = $Password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureStringPwd
Connect-MsolService -Credential $Creds
$Clientdomains = get-msoldomain | Select-Object Name
$Msdomain = $Clientdomains.name | Select-String -Pattern 'onmicrosoft.com' | Select-String -Pattern 'mail' -NotMatch
$Msdomain = $Msdomain -replace ".onmicrosoft.com",""
$AdminSite = "https://" + $Msdomain + "-admin.sharepoint.com"
Connect-SPOService -Url $AdminSite -Credential $Creds

# Path to Sharepoint SDK files, modify if you do not have a default install location
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

Write-Host 'Enabling Versioning on Sharepoint Libraries' -foregroundcolor Green
$Sites = Get-SPOSite | Select-Object Url
foreach ($Site in $Sites) {
    try{
        Write-Host "Sharepoint Site:" $Site.Url
        $Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site.Url)
        $Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$SecureStringPwd)
        $Context.Credentials = $Creds
        $Web = $Context.Web
        $Context.Load($Web)
        $Context.load($Web.lists)
        $Context.executeQuery()
        foreach($List in $Web.lists) {
            if (($List.hidden -eq $false) -and ($List.Title -notmatch "Style Library")) {
                $List.EnableVersioning = $true
                $LiST.MajorVersionLimit = 50
                $List.Update()
                $Context.ExecuteQuery() 
                Write-host "Versioning has been turned ON for :" $List.title -foregroundcolor Green
            }
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -foregroundcolor Red
    }
}
