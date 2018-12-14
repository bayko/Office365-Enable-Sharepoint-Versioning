# Office365-Enable-Sharepoint-Versioning
You must install the Sharepoint Online Client SDK as a pre-requisite:
https://www.microsoft.com/en-ca/download/details.aspx?id=42038

Script will recursively go through every Sharepoint site collection inside the 365 tenant, and enable Versioning for every library.

`````````````````````````````````````
Simply Provide your Global Admin credentials as a parameter when executing:

C:\Users\User> .\Office365-Enable-Sharepoint-Versioning-All-Sites.ps1 admin@contoso.com Password123
