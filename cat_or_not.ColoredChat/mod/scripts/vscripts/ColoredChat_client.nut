global function InitClientColoreChat

void function InitClientColoreChat() {
   thread DelayedCommand()
}
void function DelayedCommand(){
    wait(5)
    GetLocalClientPlayer().ClientCommand( "SetMessageColor " + GetConVarString("MessageColor") )
}