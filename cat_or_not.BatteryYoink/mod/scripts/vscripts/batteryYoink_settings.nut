global function batteryYoink_settings_Init

void function batteryYoink_settings_Init()
{
    AddPrivateMatchModeSettingEnum("#MODE_SETTING_CATEGORY_BATTERYYOINK", "number_of_npc", "2")
}

int function getNpcSpawnAmount(){
    return GetCurrentPlaylistVarInt("number_of_npcs", 2)
}