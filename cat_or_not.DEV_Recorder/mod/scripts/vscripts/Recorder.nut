untyped

global function Init_Recorder
// global function RunTo

const string HEADER = "// ======= generated script using DEV_recorder by catornot =======\n\n" +
                    "global function PlayRecoding_%n\n\n" +
                    "const float FAST = 0.000000000000000000001\n" +
                    "const table WALLRUN_MAP = { left = \"pt_wallrun_hang_left\", right = \"pt_wallrun_hang_right\", back = \"pt_wallrun_hang_up\", front = \"pt_wallrun_hang_front\" }\n\n" +
                    "struct Recording {\n" +
                    "	entity mover\n" +
                    "	entity pilot\n" +
                    "	bool state\n" +
                    "}\n\n" +
                    "void function PlayRecoding_%n( entity ornull model = null )\n{\n"


const string FOOTER = "}\n\n" +
                    "Recording function CreateRecording( vector origin, vector angles, entity ornull model = null )\n" +
                    "{\n" +
                    "Recording recording\n\n" +
                    "recording.mover = CreateExpensiveScriptMover( origin, angles )\n" +
                    "if ( !IsValid( model ) )\n" +
                    "{\n" +
                    "	recording.pilot = CreateElitePilot( 1, origin, angles )\n" +
                    "	// recording.pilot.SetModel( $\"models/humans/heroes/mlt_hero_jack.mdl\" )\n" +
                    "	DispatchSpawn( recording.pilot )\n" +
                    "	// recording.pilot.SetModel( $\"models/humans/heroes/mlt_hero_jack.mdl\" )\n" +
                    "	recording.pilot.Freeze()\n" +
                    "}\n" +
                    "else\n" +
                    "{\n" +
                    "	expect entity( model )\n" +
                    "	model.SetOrigin( origin )\n" +
                    "	model.SetAngles( angles )\n" +
                    "	recording.pilot = model\n" +
                    "}\n" +
                    "recording.pilot.SetParent( recording.mover )\n\n" +
                    "return recording\n" +
                    "}\n\n" +
                    "void function RunTo( Recording recording, vector origin, vector angles )\n{\n" +
                    "	print( \"running to\" + origin )\n" +
                    "	recording.mover.NonPhysicsMoveTo( origin, FAST, 0, 0 )\n" +
                    "	recording.mover.NonPhysicsRotateTo( angles, FAST, 0, 0 )\n" +
                    "	recording.state = !recording.state\n\n" +
                    "	// recording.pilot.Anim_Play( recording.state ? \"Sprint_mp_forward\" : \"Sprint_mp_backward\" )\n" +
                    "	recording.pilot.Anim_Play( \"Sprint_mp_forward\" )\n" +
                    "	recording.pilot.Anim_SetInitialTime( recording.pilot.GetSequenceDuration( \"Sprint_mp_forward\" ) * ( recording.state ? 0.0 : 0.05 ) )\n" +
                    "}\n\n" +
                    "void function SlideTo( Recording recording, vector origin, vector angles )\n" +
                    "{\n" +
                    "	print( \"sliding to\" + origin )\n" +
                    "	recording.mover.NonPhysicsMoveTo( origin, FAST, 0, 0 )\n" +
                    "	recording.mover.NonPhysicsRotateTo( angles, FAST, 0, 0 )\n" +
                    "	recording.pilot.Anim_Play( \"Slide_forward_mp\" )\n" +
                    "}\n\n" +
                    "void function CrouchTo( Recording recording, vector origin, vector angles )\n" +
                    "{\n" +
                    "	print( \"crouching to\" + origin )\n" +
                    "	recording.mover.NonPhysicsMoveTo( origin, FAST, 0, 0 )\n" +
                    "	recording.mover.NonPhysicsRotateTo( angles, FAST, 0, 0 )\n" +
                    "	recording.state = !recording.state\n\n" +
                    "	// recording.pilot.Anim_Play( recording.state ? \"ACT_MP_CROUCHWALK_FORWARD\" : \"Sprint_mp_backward\" )\n" +
                    "	recording.pilot.Anim_Play( \"ACT_MP_CROUCHWALK_FORWARD\" )\n" +
                    "	recording.pilot.Anim_SetInitialTime( recording.pilot.GetSequenceDuration( \"ACT_MP_CROUCHWALK_FORWARD\" ) * ( recording.state ? 0.0 : 0.05 ) )\n" +
                    "}\n\n" +
                    "void function JumpTo( Recording recording, vector origin, vector angles )\n" +
                    "{\n" +
                    "	print( \"jumping to\" + origin )\n" +
                    "	recording.mover.NonPhysicsMoveTo( origin, FAST, 0, 0 )\n" +
                    "	recording.mover.NonPhysicsRotateTo( angles, FAST, 0, 0 )\n" +
                    "	recording.pilot.Anim_Play( \"jump_start\" )\n" +
                    "}\n\n" +
                    "void function FallTo( Recording recording, vector origin, vector angles )\n" +
                    "{\n" +
                    "	print( \"falling to\" + origin )\n" +
                    "	recording.mover.NonPhysicsMoveTo( origin, FAST, 0, 0 )\n" +
                    "	recording.mover.NonPhysicsRotateTo( angles, FAST, 0, 0 )\n" +
                    "	recording.pilot.Anim_Play( \"jump_start\" )\n" +
                    "}\n\n" +
                    "void function WallRunTo( Recording recording, string side, vector origin, vector angles )\n{\n" +
                    "	print( \"wallrunning to\" + origin )\n" +
                    "	recording.pilot.Anim_Play( WALLRUN_MAP[side] )\n" +
                    "	recording.mover.NonPhysicsRotateTo( angles, FAST, 0, 0 )\n" +
                    "	recording.mover.NonPhysicsMoveTo( origin, FAST, 0, 0 )\n" +
                    "}\n\n"

void function Init_Recorder()
{
    RegisterSignal( "StopRecord" )

    AddClientCommandCallback( "start", StartRecorder )

    PrecacheModel( $"models/humans/pilots/pilot_medium_geist_m.mdl" )
    PrecacheModel( $"models/humans/heroes/mlt_hero_jack.mdl" )
    PrecacheModel( $"models/weapons/rspn101/w_rspn101.mdl" )
}

bool function StartRecorder( entity player, array<string> args )
{
    string name = "recording_" + string( RandomIntRange( 10000, 99999 ) )
    if ( args.len() != 0 )
        name = args[0]
    
    thread RecordMovmement( player, name )

    return true
}

bool function StopRecord( entity player, array<string> args )
{
    Signal( player, "StopRecord" )
    return true
}

void function RecordMovmement( entity player, string name )
{
    EndSignal( player, "StopRecord" )
    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )
    
    array<string> movement = [ 
        "print( \"starting pre-recorded movement\" )\n",
        "Recording recording = CreateRecording( " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + ", model )\n",
        "EndSignal( recording.pilot, \"OnDeath\" )\n",
        "OnThreadEnd(",
        "	function() : ( recording )",
        "	{",
        "		if ( IsValid( recording.mover ) )",
        "			recording.mover.Destroy()",
        "		if ( IsValid( recording.pilot ) )",
        "			recording.pilot.Destroy()",
        "	}",
        ")\n"
    ]

    OnThreadEnd(
        function() : ( player, movement, name )
		{
            movement.append( "print( \"recoding ended naturally\" )" )
            string path = "../R2Northstar/mods/cat_or_not.DEV_Recorder/mod/scripts/vscripts/saved_recordings/" + name + ".nut"
            WriteOut( path, name, movement )
		}
    )

    for(;;)
    {
        if ( player.IsWallRunning() )
        {
            string side = "left"
            if ( TraceWallrun( player, "right" ) )
                side = "left"
            else if ( TraceWallrun( player, "left" ) )
                side = "right"
            else if ( TraceWallrun( player, "front" ) )
                side = "back"
            else if ( TraceWallrun( player, "back" ) )
                side = "front"
            movement.append( "WallRunTo( recording, \"" + side +"\", " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + " )" )
        }
        else if ( player.IsCrouched() )
        {
            if ( player.GetVelocity().x > 100 || player.GetVelocity().y > 100 )
                movement.append( "SlideTo( recording, " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + " )" )
            else 
                movement.append( "CrouchTo( recording, " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + " )" )
        }
        else if ( !player.IsOnGround() )
        {
            if ( player.GetVelocity().z < 0 )
                movement.append( "FallTo( recording, " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + " )" )
            else 
                movement.append( "JumpTo( recording, " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + " )" )
        }
        else
            movement.append( "RunTo( recording, " + MyVectorToString( player.GetOrigin() ) + ", " + MyVectorToString( player.GetAngles() ) + " )" )
        
        movement.append( "WaitFrame()" )
        WaitFrame()
    }
}

string function MyVectorToString( vector vec )
{
    return "< " + vec.x + ", " + vec.y + ", " + vec.z + " >"
}


// thx Pebbers
void function WriteOut( string filename, string name, array<string> code ) {
    string repHeader = Replace( HEADER, "%n", name, 2 )
    string repFooter = FOOTER
    // string repFooter = Replace( FOOTER, "%n", name, 0 )

    foreach( string line in code )
    {
        printt( line )
    }

    // DevTextBufferClear()

    // DevTextBufferWrite( repHeader )
    // foreach( string line in code )
    // {
    //     DevTextBufferWrite( "	" + line + "\n" )
    // }
    // DevTextBufferWrite( repFooter )

    // DevP4Checkout( filename )
	// DevTextBufferDumpToFile( filename )
	// DevP4Add( filename )
	// printt( "Wrote " + filename )
}

string function Replace( string toReplace, string placeholder, string to, int times ) {
    string res = toReplace

    for ( int i = 0; i < times; i++ )
    {
        res = StringReplace( res, placeholder, to )
    }

    return res
}

bool function TraceWallrun( entity player, string side )
{
    vector traceStart = player.GetOrigin()
    vector traceEnd = player.GetOrigin()
    array<entity> ignoreEnts = [ player ]

    switch ( side ) {
        case "left":
            traceEnd += player.GetRightVector() * -50
            break
        case "right":
            traceEnd += player.GetRightVector() * 50
            break
        case "front":
            traceEnd += player.GetForwardVector() * 50
            break
        case "back":
            traceEnd += player.GetForwardVector() * -50
            break
    }

    TraceResults results = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
    return IsValid( results.hitEnt )
}