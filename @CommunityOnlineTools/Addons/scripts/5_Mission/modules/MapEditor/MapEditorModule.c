class MapEditorModule: Module
{
    protected bool m_InEditor;

    void MapEditorModule()
    {
        GetRPCManager().AddRPC( "COT_MapEditor", "EnterEditor", this, SingeplayerExecutionType.Server );
        GetRPCManager().AddRPC( "COT_MapEditor", "LeaveEditor", this, SingeplayerExecutionType.Server );

        GetPermissionsManager().RegisterPermission( "MapEditor.EnterEditor" );
        GetPermissionsManager().RegisterPermission( "MapEditor.LeaveEditor" );
    }
    
    void EnterEditor( CallType type, ref ParamsReadContext ctx, ref PlayerIdentity sender, ref Object target )
    {
        if ( !GetPermissionsManager().HasPermission( "CameraTools.EnterCamera", sender ) )
            return;
            
        if ( !GetPermissionsManager().HasPermission( "MapEditor.EnterEditor", sender ) )
            return;

        bool cont = false;

        if( type == CallType.Server )
        {
            if ( GetGame().IsMultiplayer() )
            {
                GetGame().SelectSpectator( sender, "StaticCamera", target.GetPosition() + Vector( 0, 1.8, 0 ) );

                GetGame().SelectPlayer( sender, NULL );

                GetRPCManager().SendRPC( "COT_MapEditor", "EnterEditor", new Param, true, sender, NULL );
            } else 
            {
                cont = true;
            }

            GetRPCManager().SendRPC( "COT_Camera", "EnterCamera", new Param, true, sender, target );
        }

        if( type == CallType.Client || cont )
        {
            m_InEditor = true;

            COTForceHud( true );
        }
    }
    
    void LeaveEditor( CallType type, ref ParamsReadContext ctx, ref PlayerIdentity sender, ref Object target )
    {
        if ( !GetPermissionsManager().HasPermission( "CameraTools.LeaveCamera", sender ) )
            return;
            
        if ( !GetPermissionsManager().HasPermission( "MapEditor.LeaveEditor", sender ) )
            return;

        bool cont = false;

        if( type == CallType.Server )
        {
            Param1< vector > data;
            if ( !ctx.Read( data ) ) return;

            if ( GetGame().IsMultiplayer() )
            {
                GetGame().SelectPlayer( sender, target );

                if ( target ) 
                {
                    target.SetPosition( data.param1 );
                }

                GetRPCManager().SendRPC( "COT_MapEditor", "LeaveEditor", new Param, true, sender, NULL );
            } else 
            {
                cont = true;
            }

            GetRPCManager().SendRPC( "COT_Camera", "LeaveCamera", new Param1<vector>(data.param1), true, sender );
        }

        if( type == CallType.Client || cont )
        {
            m_InEditor = false;

            COTForceHud( false );
        }
    }

    override void RegisterKeyMouseBindings() 
	{
		KeyMouseBinding teleport = new KeyMouseBinding( GetModuleType() , "ToggleEditor", "[U]"    , "Teleport to cursor position." );

		teleport.AddKeyBind( KeyCode.KC_U, KeyMouseBinding.KB_EVENT_PRESS );
		
		RegisterKeyMouseBinding( teleport );
	}

    void ToggleEditor()
    {
        if ( COTCamera )
        {
            GetRPCManager().SendRPC( "COT_MapEditor", "LeaveEditor", new Param1<vector>(GetPlayer().GetPosition()), true, NULL, GetPlayer() );
        } else 
        {
            GetRPCManager().SendRPC( "COT_MapEditor", "EnterEditor", new Param, true, NULL, GetPlayer() );
        }

    }

}