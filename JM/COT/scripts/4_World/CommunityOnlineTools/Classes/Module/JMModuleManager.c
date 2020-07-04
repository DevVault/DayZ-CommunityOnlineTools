modded class JMModuleManager
{
	protected autoptr array< JMRenderableModuleBase > m_COTModules;

	void JMModuleManager()
	{
		m_COTModules = new array< JMRenderableModuleBase >;

		JMScriptInvokers.COT_ON_OPEN.Insert( SetPreventModuleBindings );
	}

	void ~JMModuleManager()
	{
		JMScriptInvokers.COT_ON_OPEN.Remove( SetPreventModuleBindings );
	}
	
	protected override void InitModule( ref JMModuleBase module )
	{
		super.InitModule( module );
		
		if ( module.IsInherited( JMRenderableModuleBase ) )
		{
			m_COTModules.Insert( JMRenderableModuleBase.Cast( module ) );
		}
	}

	array< JMRenderableModuleBase > GetCOTModules()
	{
		return m_COTModules;
	}

	void OnClientPermissionsUpdated()
	{
		for ( int i = 0; i < m_Modules.Count(); i++ )
		{
			m_Modules.GetElement(i).OnClientPermissionsUpdated();
		}
	}
}