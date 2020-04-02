class JMMapForm extends JMFormBase 
{
	private MapWidget map_widget;
	private Widget basewindow_background;
	
	void JMMapForm()
	{
	}

	void ~JMMapForm()
	{
	}
	
	override void OnInit()
	{
		map_widget = MapWidget.Cast( layoutRoot.FindAnyWidget( "map_widget" ) );
		basewindow_background = window.GetLayoutRoot().FindAnyWidget( "background" );
		basewindow_background.Show( false );
	}
	
	override void OnShow()
	{
		GetGame().GetCallQueue( CALL_CATEGORY_GAMEPLAY ).CallLater( UpdatePlayers, 1000, true );
	}

	override void OnHide() 
	{
		GetGame().GetCallQueue( CALL_CATEGORY_GAMEPLAY ).Remove( UpdatePlayers );
	}

	void UpdatePlayers() 
	{
		map_widget.ClearUserMarks();

		if ( !GetPermissionsManager().HasPermission( "Map.Players", NULL ) )
			return;

		foreach( JMPlayerInstance player : GetPermissionsManager().GetPlayers() ) 
		{
			map_widget.AddUserMark( player.Data.VPosition, player.Data.SName, ARGB( 255, 230, 20, 20 ), "\\JM\\COT\\GUI\\textures\\dot.paa" );
		}

		GetCommunityOnlineTools().RefreshClients();
	}

	override bool OnDoubleClick( Widget w, int x, int y, int button )
	{
		if ( w == NULL )
		{
			return false;
		}

		if ( w == map_widget )
		{
			JMTeleportModule mod;
			if ( Class.CastTo( mod, GetModuleManager().GetModule( JMTeleportModule ) ) )
			{
				mod.Position( SnapToGround( map_widget.ScreenToMap( Vector( x, y, 0 ) ) ) );
			}
			
			return true;
		}

		return false;
	}
}