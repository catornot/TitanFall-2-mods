global function Init_client

void function Init_client(){
    thread ButtonsInit()
}

void function ButtonsInit(){
    WaitFrame()
    RegisterButtonPressedCallback(KEY_P, P_pressed)
    RegisterButtonPressedCallback(KEY_L, L_pressed)
    RegisterButtonPressedCallback(KEY_M, M_pressed)
    RegisterButtonPressedCallback(KEY_O, O_pressed)
}

void function P_pressed( entity player){
    GetPlayerArray()
}
void function L_pressed( entity player){
    GetPlayerArray()
}
void function M_pressed( entity player){
    GetPlayerArray()
}
void function O_pressed( entity player ){
    GetPlayerArray()
}

