param($ConfigurationData)

Configuration Config 
{
    Import-DscResource -ModuleName xLibrary, PSDesiredStateConfiguration,xPSDesiredStateConfiguration

    Node $AllNodes.NodeName 
    {

        xDotmailer_Common CommonServer
        {
        }

        if($Node.RegisterServerIp)
        {
	        xHostsFile Add-Server-Ip {
			    Name   = 'pull-server'
                Ip     = '10.13.13.104'
		    }
        }
    }

    Node $AllNodes.Where{$_.Roles -eq "Web"}.NodeName
    {
        WindowsFeature Install-Web-Asp-Net45
        {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
        }
    }

    Node $AllNodes.Where{$_.Roles -eq "Tools"}.NodeName
    {
        xPSEndpoint PS-Dev-Endpoint
        {
            Ensure = "Present"
            Name = "Dev"
        }
    }
}

Config -ConfigurationData $ConfigurationData