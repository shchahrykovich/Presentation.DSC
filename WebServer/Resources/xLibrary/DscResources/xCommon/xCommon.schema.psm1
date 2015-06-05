Configuration xDotmailer_Common
{
    WindowsFeature Install-MSMQ {
	    Ensure = 'Present'
	    Name   = 'MSMQ'
    }

    WindowsFeature Install-MSMQ-Directory
    { 
        Ensure = "Present" 
        Name   = "MSMQ-Directory" 
    }

    WindowsFeature Install-AS-NET-Framework
    {
        Ensure = "Present"
        Name = "AS-NET-Framework"
    }
}