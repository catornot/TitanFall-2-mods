//
//This is the config file for the Player Info Tracker Mod, if you are working on a mod yourself feel free to use anything inside this script if you find it helpful
//Further down you will find the section to change the in-game display.
//
global function userDataPreCache

//CHANGE SETTINGS HERE
struct{
	// Toggles for each tracker value, change to false to disable a tracker and remove it from the screen. Leave at least 1 to true. Values must be lowercase.
	bool displayName = true // toggle for Username
	bool displayPing = true // toggle for Ping
	bool displayGen = true // toggle for Gen
	bool displayXP = true // toggle for XP
	bool displayHealth = true // toggle for Health

	// Settings below to change the appearance of the tracker
	float size = 25 // Text size, Default: 25
	float verticalPos = 0.16 // Vertical Postion on-screen. 0.00 is max up, 1.00 is max down, default 0.16
	float horizPos = 0.16 // Horizontal position on-screen. 0.00 is max left, 1.00 is max right, default 0.16
	vector color = Vector(1.0, 1.0, 1.0) //color of on-screen display, standard rgb values. Supported Range 0.00 to 1.00. For easy conversion of standard rgb values that look like 255,255,255 (white) lookup a rgb value to percentage converter. 1.00 would be considered 100% 0.50 for 50%, etc..
	float alpha = 0.5 // this is the opacity of the on-screen display, 1.00 is solid, 0.00 would be completely see through and such will be invisible.
	float textSize = 25.0 // value for font size, 25 is default
	float boldVal = 0.0 // How thick or bold the text appears, default: 0.0

	//Script stuff
	bool doOnce = true // used for script. You can ignore this one. DO NOT CHANGE
} settings

var menuPingData = null
var pingData = null
var genData = null
var xpData = null
var healthData = null
var nameData = null

void function userDataPreCache(){
	thread menusTread()
}

//For when player is in lobbies and browser.
void function menusTread(){
	WaitFrame()
	// So the mod won't scream into the console endlessly
	int noConsoleSpam = 0
	while(IsLobby() && IsMenuLevel()){
		if(noConsoleSpam <= 0 ){
		print("<##############>The userstat mod is waiting for a game.<##############>")
		noConsoleSpam = 2
	}
		else
		// This is the best thing I found
		WaitForever()
	}
	thread userDataMsg1()
}

void function userDataMsg1(){
	if(settings.displayName){
		WaitFrame()
		nameData = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0)
		RuiSetInt(nameData, "lineNum", 1)
		RuiSetFloat2(nameData, "msgPos", <settings.horizPos, settings.verticalPos, 0.0>)
		RuiSetString(nameData, "msgText", "Player: N/A")
		RuiSetFloat(nameData, "msgFontSize", settings.textSize)
		RuiSetFloat(nameData, "msgAlpha", settings.alpha)
		RuiSetFloat(nameData, "thicken", settings.boldVal)
		RuiSetFloat3(nameData, "msgColor", settings.color)
		if(settings.doOnce){
			settings.verticalPos = settings.verticalPos + 0.02
		}
		thread userDataMsg2()
	}
	else
	thread userDataMsg2()
}

void function userDataMsg2(){
	if(settings.displayPing){
		WaitFrame()
		pingData = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0)
		RuiSetDrawGroup(pingData, RUI_DRAW_COCKPIT)
		RuiSetInt(pingData, "lineNum", 1)
		RuiSetFloat2(pingData, "msgPos", <settings.horizPos, settings.verticalPos, 0.0>)
		RuiSetString(pingData, "msgText", "Ping: N/A:")
		RuiSetFloat(pingData, "msgFontSize", settings.size)
		RuiSetFloat(pingData, "msgAlpha", settings.alpha)
		RuiSetFloat(pingData, "thicken", settings.boldVal)
		RuiSetFloat3(pingData, "msgColor", settings.color)
		if(settings.doOnce){
			settings.verticalPos = settings.verticalPos + 0.02
		}
		thread userDataMsg3()
	}
	else
	thread userDataMsg3()
}

void function userDataMsg3(){
	if(settings.displayGen){
		WaitFrame()
		genData = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0)
		RuiSetInt(genData, "lineNum", 1)
		RuiSetFloat2(genData, "msgPos", <settings.horizPos, settings.verticalPos, 0.0>)
		RuiSetString(genData, "msgText", "Gen: N/A")
		RuiSetFloat(genData, "msgFontSize", settings.textSize)
		RuiSetFloat(genData, "msgAlpha", settings.alpha)
		RuiSetFloat(genData, "thicken", settings.boldVal)
		RuiSetFloat3(genData, "msgColor", settings.color)
		if(settings.doOnce){
			settings.verticalPos = settings.verticalPos + 0.02
		}
		thread userDataMsg4()
	}
	else
	thread userDataMsg4()
}

void function userDataMsg4(){
	if(settings.displayXP){
		WaitFrame()
		xpData = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0)
		RuiSetInt(xpData, "lineNum", 1)
		RuiSetFloat2(xpData, "msgPos", <settings.horizPos, settings.verticalPos, 0.0>)
		RuiSetString(xpData, "msgText", "XP This Match: N/A")
		RuiSetFloat(xpData, "msgFontSize", settings.textSize)
		RuiSetFloat(xpData, "msgAlpha", settings.alpha)
		RuiSetFloat(xpData, "thicken", settings.boldVal)
		RuiSetFloat3(xpData, "msgColor", settings.color)
		// Moves the next UI element down
		if(settings.doOnce){
			settings.verticalPos = settings.verticalPos + 0.02
		}
		thread userDataMsg5()
	}
	else
	thread userDataMsg5()
}

void function userDataMsg5(){
	if(settings.displayHealth){
		WaitFrame()
		healthData = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0)
		RuiSetInt(healthData, "lineNum", 1)
		RuiSetFloat2(healthData, "msgPos", <settings.horizPos, settings.verticalPos, 0.0>)
		RuiSetString(healthData, "msgText", "Health: N/A")
		RuiSetFloat(healthData, "msgFontSize", settings.textSize)
		RuiSetFloat(healthData, "msgAlpha", settings.alpha)
		RuiSetFloat(healthData, "thicken", settings.boldVal)
		RuiSetFloat3(healthData, "msgColor", settings.color)
		settings.doOnce = false
		thread userDataMain()
	}
	else
	thread userDataMain()
}

void function userDataMain(){
	while(true){
	if(!IsLobby() && !IsMenuLevel()){
	WaitFrame()
	// Getting user info
	entity player = GetLocalViewPlayer()
	int pingNum = player.GetPlayerGameStat( PGS_PING )
	int genNum = player.GetGen()
	int xpNum = player.GetXP()
	int hpNum = player.GetHealth()
	vector locationVector =  player.GetOrigin()
	string username = player.GetPlayerName()
	// Creating UI Strings
	string playerName = ("Player: " + username)
	string pingStrg = ("Ping: " + pingNum)
	string genStrg = ("Gen: " + genNum)
	string xpStrg = ("XP: " + xpNum)
	string hpStrg = ("Health: " + hpNum)
	string posStrg = ("position: " + locationVector)
	// I am so sorry for this but I work with C# and squirrel is wack tbh this entire script just feels wrong
	// isg if there is something in squirrel that works like a C#'s switch/case I will scream
	// Setting UI strings while accounting for disabled displays
	if(settings.displayPing){
		RuiSetString(pingData, "msgText", pingStrg)
	}
	if(settings.displayGen){
		RuiSetString(genData, "msgText", genStrg)
	}
	if(settings.displayXP){
		// RuiSetString(xpData, "msgText", xpStrg)
		RuiSetString(xpData, "msgText", posStrg)
	}
	if(settings.displayHealth){
		RuiSetString(healthData, "msgText", hpStrg)
	}
	if(settings.displayName){
		RuiSetString(nameData, "msgText", playerName)
	}
	}
 }
}
