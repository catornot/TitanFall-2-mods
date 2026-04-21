global function placeRiseObjects

// the projection area -> <8069, -8945, -6844>

struct
{
    bool ash_fight_started = false
    bool mission_started = false
    array<entity> terminals
    int terminals_num = 3
    entity signal_ent
} file

const asset DAMAGE_AREA_MODEL = $"models/fx/xo_shield.mdl"
const asset SLOW_TRAP_MODEL = $"models/weapons/titan_incendiary_trap/w_titan_incendiary_trap.mdl"
const asset SLOW_TRAP_FX_ALL = $"P_meteor_Trap_start"
const float SLOW_TRAP_LIFETIME = 12.0
const float SLOW_TRAP_BUILD_TIME = 1.0
const float SLOW_TRAP_RADIUS = 240
const asset TOXIC_FUMES_FX 	= $"P_meteor_trap_gas"
const asset TOXIC_FUMES_S2S_FX 	= $"P_meteor_trap_gas_s2s"
const asset FIRE_CENTER_FX = $"P_meteor_trap_center"
const asset BARREL_EXP_FX = $"P_meteor_trap_EXP"
const asset FIRE_LINES_FX = $"P_meteor_trap_burn"
const asset FIRE_LINES_S2S_FX = $"P_meteor_trap_burn_s2s"
const float FIRE_TRAP_MINI_EXPLOSION_RADIUS = 75
const float FIRE_TRAP_LIFETIME = 10.5
const int GAS_FX_HEIGHT = 45

enum eAshState
{
	FIND_TARGET,
    DIM_HOP,
    KILL
}

void function placeRiseObjects()
{
    CreateNessy( <1124, -584, 550>, <0,0,0>, 12 )
    CreateSmallElevator( < -380, 362, 256 >, < -380, 362, 1000 >, 10 )
    CreateSmallElevator( < -8717, -1460, -9030>, < -8717, -1460, -5700>, 10 )

    CreateSimpleButton( <3300, 2021, 570>, <90, -180, 0>, "teleport to the lobby", Callback_MessageButtonTriggered, 5 )
    CreateSimpleButton( < -277, 359, 572 >, <0, 90, 30>, "ignite the floor", Callback_FireTriggered, 30 )
    CreateSimpleButton( < -1153, -290, 560 >, <90, 90, 0>, "summon Hash", Callback_AshButtonTriggered, 30 )

    file.terminals.append( CreateExpensiveScriptMoverModel( $"models/communication/terminal_com_station_tall.mdl", <4297, 2, 1623>, <0,180,0>, SOLID_VPHYSICS, 10000 ))
    file.terminals.append( CreateExpensiveScriptMoverModel( $"models/communication/terminal_com_station_tall.mdl", < -6151, -2590, 1556 >, <0,180,0>, SOLID_VPHYSICS, 10000 ))
    file.terminals.append( CreateExpensiveScriptMoverModel( $"models/communication/terminal_com_station_tall.mdl", < -3223, 1829, 320 >, <0,180,0>, SOLID_VPHYSICS, 10000 ))
    
    file.signal_ent = CreateScriptMover()

    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function Callback_MessageButtonTriggered( entity button, entity player )
{
    player.SetOrigin( < -8717, -1460, -5800> )
}

void function Callback_FireTriggered( entity button, entity player )
{
    foreach( vector origin in [ < -453, 424, 270 >, < -1726, 425, 290>, < -1169, 408, 260 >, < -786, 394, 260 >, < -786, 394, 270 > ] )
    {
        entity initialExplosion = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FIRE_CENTER_FX ), origin, <0,0,0> )
        EntFireByHandle( initialExplosion, "Kill", "", 3.0, null, null )
        EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "incendiary_trap_explode" )

        float duration = FLAME_WALL_THERMITE_DURATION
        entity inflictor = CreateOncePerTickDamageInflictorHelper( duration )
        inflictor.SetOrigin( origin )

        thread DestroyAfterDelay( initialExplosion, 10.0 )
        thread DestroyAfterDelay( inflictor, 10.0 )

        vector position = inflictor.GetOrigin()
        EmitSoundAtPosition( TEAM_UNASSIGNED, position, "incendiary_trap_burn" )

        RadiusDamage(
            inflictor.GetOrigin(),								// origin
            player,									            // owner
            inflictor,		 									// inflictor
            90,							                    // pilot damage
            600,									            // heavy armor damage
            1000,					                            // inner radius
            1000,					                            // outer radius
            SF_ENVEXPLOSION_NO_NPC_SOUND_EVENT,					// explosion flags
            0, 													// distanceFromAttacker
            1, 												    // explosionForce
            DF_EXPLOSION,										// damage flags
            eDamageSourceId.mp_titanability_slow_trap			// damage source id
        )
    }
}

void function Callback_AshButtonTriggered( entity button, entity player )
{
    if ( GetDisabledElements().contains( "ash_boss" ) )
    {
        NSSendPopUpMessageToPlayer( player, "hash is disabled on this server D:" )
        return
    }

    if ( !HasAllNessies() )
    {
        NSSendPopUpMessageToPlayer( player, "You don't have all the nessies [" + CountNessy() + " out of 4 ]" )
        return
    }
    ResetNessy()

    if ( file.ash_fight_started )
        return
    file.ash_fight_started = true

    int team = 10

    entity ash = CreateNPCTitan( "titan_stryder", team, <471, 1641, 183>, <0,0,0>, [] )
    SetSpawnOption_Warpfall( ash )
    SetSpawnOption_AISettings( ash, "npc_titan_stryder_leadwall_bounty" )
    ash.SetTitle("Hash")

    DispatchSpawn( ash )

    ash.SetMaxHealth( 25000 )
    ash.SetHealth( 25000 )
    ash.SetInvulnerable()
    ash.SetTitle("Hash")

    foreach( vector pos in [<1159, 1894, 580>, <2311, 2824, 352>, < -781, 66, 232 >, < -4084, -519, 719 >, < -5983, 296, 740 > ] )
    {
        entity titan = CreateNPCTitan( "npc_titan_atlas", team, pos, <0,0,0>, [] ) // why do I need []
        SetSpawnOption_NPCTitan( titan, 2 )
        SetSpawnOption_AISettings( titan, "npc_titan_atlas_stickybomb" )
        SetSpawnOption_Warpfall( titan )
        SetSpawnOption_CoreAbility( titan, "mp_titancore_laser_cannon" )
        DispatchSpawn( titan )
        
        titan.SetInvulnerable()
        titan.SetScriptName( "ions" )

        thread DelayedSetInvulnerable( titan )
    }

    thread DelayedAshSetup( ash )
}

void function DelayedAshSetup( entity ash )
{
    wait 5
    
    // camera is too unstable
    // foreach( entity player in GetPlayerArray() )
    //     thread HandleCamera( player, ash )

    thread WaitForCameraEnd( ash )
}

void function WaitForCameraEnd( entity ash )
{
    // WaitSignal( ash, "CameraHandleOver" )

    thread AshStateMachineRun( ash )

    wait 1

    foreach( entity player in GetPlayerArray() )
        NSSendInfoMessageToPlayer( player, "This is Hash" )
    
    wait 2
    
    foreach( entity ion in GetEntArrayByScriptName("ions") )
        thread ResupplyCoresThink( ion )
    
    thread ResupplyCoresThink( ash )
}

void function DelayedSetInvulnerable( entity ent, float delay = 10.0 )
{
    wait delay

    ent.SetInvulnerable()
}

void function AshStateMachineRun( entity ash )
{
    EndSignal( ash, "OnDeath" )
    EndSignal( ash, "OnDestroy" )

    OnThreadEnd(
	function() : ()
		{
			foreach( entity ion in GetEntArrayByScriptName("ions") )
                ion.Die()
            
            foreach( entity player in GetPlayerArray() )
                NSSendInfoMessageToPlayer( player, "Hash Died :D" )
            
            file.ash_fight_started = false
		}
	)

    int state = eAshState.FIND_TARGET
    array<entity> titanSpawnPoints = SpawnPoints_GetTitan()
    entity target

    for(;;)
    {
        switch( state )
        {
            case eAshState.FIND_TARGET:
                foreach( entity player in GetPlayerArray() )
                {
                    entity spawnpoint
                    
                    titanSpawnPoints = SpawnPoints_GetTitan()
                    if ( IsValid( player ) && IsAlive( player ) )
                        spawnpoint = GetClosest2D( titanSpawnPoints, player.GetOrigin(), 1000 )
                    
                    if ( IsValid( spawnpoint ) )
                    {
                        PhaseShift( ash, 0.1, 1 )
                        ash.SetOrigin( spawnpoint.GetOrigin() )
                        target = player
                        state = eAshState.DIM_HOP
                        ash.SetInvulnerable()
                        // ash.ClearInvulnerable()
                    }
                }

                break
            case eAshState.DIM_HOP:
                if ( !ash.IsPhaseShifted() )
                {
                    wait 0.1
                    ash.ClearInvulnerable()
                    state = eAshState.KILL
                }
                break
            case eAshState.KILL:
                if ( !IsValid( target ) || !IsAlive( target ) || Distance2D( ash.GetOrigin(), target.GetOrigin() ) > 3000 )
                {
                    ash.SetInvulnerable()
                    state = eAshState.FIND_TARGET
                }
                else 
                    ash.ClearInvulnerable()
                break
        }

        wait 0
    }
}


void function EntitiesDidLoad()
{
    thread RunRecordingLoop()

    SetupTerminals()
    HideTerminals()

    CreateHackPanel( <2135, 1861, 47>, <0,180,0>, OnPanelHacked )
}

void function RunRecordingLoop()
{
    wait RandomIntRange( 60, 180 )
    for(;;)
    {
        entity pilot = CreateElitePilot( 1, <0,1000,10000>, <0,0,0> )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
		DispatchSpawn( pilot )
		pilot.SetModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
        pilot.kv.skin = PILOT_SKIN_INDEX_GHOST
		pilot.Freeze()
        pilot.SetTitle( "follow me" )
        SetTeam( pilot, TEAM_BOTH )

        waitthread PlayRecoding_recording_riseHintPilot( pilot )
        wait RandomIntRange( 60, 180 )
    }
}

void function OnPanelHacked( entity panel, entity player )
{
    if ( file.mission_started )
        return
    file.mission_started = true

    entity sarah = CreateNPC( "npc_soldier", player.GetTeam(), <1968, 1670, 48>, <0,0,0> )
    SetSpawnOption_AISettings( sarah, "npc_soldier_hero_sarah")
    DispatchSpawn( sarah )
    sarah.SetInvulnerable()
    // sarah.Freeze()
    sarah.SetOrigin( <2068, 1770, 48> )

    ShowTerminals()

    thread StopExplosionOps( sarah, player )
}

void function StopExplosionOps( entity sarah, entity player )
{
    EndSignal( player, "OnDestroy" )
    EndSignal( player, "OnDeath" )

    TimeMeter time

    OnThreadEnd(
	function() : ( player, time )
		{
            file.mission_started = false

            if ( !IsValid(player) )
                return
            else if ( !IsAlive(player) )
            {
                Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m You died :(", false, false )
                return
            }

            Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m You completed the trial!", false, false )
            
            float finalTime = ( time.time - time.start )

            if ( finalTime > 60.0 )
            {
                Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m I will give you a reward, but you can do better next time!", false, false )
                player.TakeOffhandWeapon( OFFHAND_SPECIAL )
                player.GiveOffhandWeapon( "mp_ability_grapple", OFFHAND_SPECIAL, ["pm1"] )
            }
            else if ( finalTime > 40.0 )
            {
                Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m I will give you a good reward, but if you can do it even faster there will probably be a better reward.", false, false )
                player.TakeOffhandWeapon( OFFHAND_SPECIAL )
                player.GiveOffhandWeapon( "mp_ability_grapple", OFFHAND_SPECIAL, ["pm2"] )
            }
            else 
            {
                Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m This is quite fast, so the reward will also be quite good.", false, false )
                player.TakeOffhandWeapon( OFFHAND_SPECIAL )
                player.GiveOffhandWeapon( "mp_ability_shifter_super", OFFHAND_SPECIAL, [] )
            }
		}
	)

    wait 1

    Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m You need to disable towers for some reason.", false, false )
    NSSendInfoMessageToPlayer( player, "This is a time trial btw" )
    wait 2

    Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m Follow me I will show you where they are.", false, false )
    wait 1

    thread SarahMoveToShow( sarah, player )
    thread ShowTime( player, time )

    WaitSignal( file.signal_ent, "TrialOver" )

    PhaseShift( player, 0.1, 2 )

    player.SetOrigin( <1968, 1670, 48> )

    wait 3
}

void function SarahMoveToShow( entity sarah, entity player )
{
    EndSignal( file.signal_ent, "TrialOver" )
    EndSignal( player, "OnDestroy" )
    EndSignal( player, "OnDeath" )

    OnThreadEnd(
	function() : (sarah)
		{
            sarah.Unfreeze()
            PhaseShift( sarah, 0.2, 1 )
			sarah.Die()

            HideTerminals()
		}
	)

    sarah.Freeze()

    waitthread PlayRecoding_recording_riseSarahPart1( sarah )
    Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m Here is the first tower.", false, false )
    wait 1

    waitthread PlayRecoding_recording_riseSarahPart2( sarah )
    Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m And here is the second tower.", false, false )
    wait 1

    waitthread PlayRecoding_recording_riseSarahPart3( sarah )
    Chat_ServerPrivateMessage( player, "\x1b[32m[Sarah]\x1b[0m Over Here you can find the last tower.", false, false )
    wait 1
}

void function ShowTime( entity player, TimeMeter time )
{
    EndSignal( file.signal_ent, "TrialOver" )
    EndSignal( player, "OnDestroy" )
    EndSignal( player, "OnDeath" )

    time.time = Time()
    time.start = Time()

    string unique_id = UniqueString( "Race" )

    NSCreateStatusMessageOnPlayer( player, "Time", "" + ( time.time - time.start ), unique_id )

    OnThreadEnd(
		function() : ( player, time, unique_id )
		{
            if ( IsValid( player ) && IsAlive( player ) )
            {
                NSSendAnnouncementMessageToPlayer(player, "You completed the time trial", "Your Time Is " + ( time.time - time.start ) + " seconds", <1,1,0>, 1, 0 )
            }

            if ( IsValid( player ) )
                NSDeleteStatusMessageOnPlayer( player, unique_id )
		}
	)

    for(;;)
    {
        time.time = Time()

        NSEditStatusMessageOnPlayer( player, "Time", "" + ( time.time - time.start ), unique_id )
        
        wait 0.1
    }
}

void function SetupTerminals()
{
    foreach( terminal in file.terminals )
    {
        terminal.SetUsableByGroup( "pilot" )
        terminal.SetUsePrompts( "Hold %use% to lower the tower", "Press %use% to lower the tower" )
        terminal.SetUsable()
        terminal.SetScriptName("up")
        SetTeam( terminal, 100 )
        // Highlight_SetEnemyHighlight( terminal, "hunted_enemy" )
        
    }
}

void function WaitToHide( entity terminal )
{
    WaitSignal( terminal, "OnPlayerUse" )
    
    if ( terminal.GetScriptName() == "down" )
        return
    
    terminal.NonPhysicsMoveTo( terminal.GetOrigin() - <0,0,180>, 5, 1, 1 )
    terminal.UnsetUsable()
    // Highlight_ClearEnemyHighlight( terminal )
    terminal.SetScriptName("down")

    file.terminals_num -= 1

    if ( file.terminals_num <= 0 ) 
    {
        file.signal_ent.Signal("TrialOver")
    }
}

void function HideTerminals()
{
    foreach( terminal in file.terminals )
    {
        if ( terminal.GetScriptName() == "down" )
            continue

        terminal.NonPhysicsMoveTo( terminal.GetOrigin() - <0,0,180>, 5, 1, 1 )
        terminal.UnsetUsable()
        // Highlight_ClearEnemyHighlight( terminal )
        terminal.SetScriptName("down")

        terminal.Signal( "OnPlayerUse", { player = terminal } )
    }
    file.terminals_num = 0
}

void function ShowTerminals()
{
    file.terminals_num = file.terminals.len()

    foreach( terminal in file.terminals )
    {
        if ( terminal.GetScriptName() == "up" )
            continue
        
        terminal.NonPhysicsMoveTo( terminal.GetOrigin() + <0,0,180>, 1, 0.5, 0.5 )
        terminal.SetUsable()
        // Highlight_SetEnemyHighlight( terminal, "hunted_enemy" )
        terminal.SetScriptName("up")
        thread WaitToHide( terminal )
    }
}