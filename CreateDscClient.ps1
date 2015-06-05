Configuration SetPullMode 
{
	param([string]$guid)

	Node localhost
	{
		LocalConfigurationManager
		{
            DebugMode = "All"
			ConfigurationMode = 'ApplyOnly'
			ConfigurationID = $guid
			RefreshMode = 'Pull'
            RebootNodeIfNeeded = $true
			DownloadManagerName = 'WebDownloadManager'
            AllowModuleOverWrite = $true
			DownloadManagerCustomData = @{
				ServerUrl = 'http://10.13.13.104:8080/PSDSCPullServer.svc';
				AllowUnsecureConnection = 'true' }
		}
	}
}

SetPullMode –guid '6d923c36-961a-4fe8-987c-88061edc1979'
Set-DSCLocalConfigurationManager -Path ./SetPullMode –Verbose
