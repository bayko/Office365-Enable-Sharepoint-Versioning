Write-Host 'Connecting to all Office 365 services' -foregroundcolor Green
$Username = $args[0]
$Password = $args[1]
$SecureStringPwd = $Password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureStringPwd
Connect-MsolService -Credential $Creds
$Clientdomains = get-msoldomain | Select-Object Name
$Msdomain = $Clientdomains.name | Select-String -Pattern 'onmicrosoft.com' | Select-String -Pattern 'mail' -NotMatch
$Msdomain = $Msdomain -replace ".onmicrosoft.com",""
$AdminSite = "https://" + $Msdomain + "-admin.sharepoint.com"
Connect-SPOService -Url $AdminSite -Credential $Creds
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