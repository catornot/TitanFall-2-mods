global function Init_twitchRiff
// global function get_command_P
// global function get_command_L
// global function get_command_O
// global function get_command_M

struct {
	array< array<string> > DNA = []
    array< string > codon = []

} file

void function Init_twitchRiff(){
    #if SERVER
    // if ( GetTwicthState() ){
        // generateRandomCommandNames()

        AddClientCommandCallback( "gkjreiughieu" , AddAToCodon)
        AddClientCommandCallback( "fndwjbfiupwh" , AddUToCodon)
        AddClientCommandCallback( "hewjgfiywvii" , AddCToCodon)
        AddClientCommandCallback( "wiuehbuifhfu" , AddGToCodon)
    // }
    #endif
}

#if SERVER

bool function AddAToCodon(entity player, array<string> args){
    thread AddNucleotideToDNA( "A" )
    return true;
}

bool function AddUToCodon(entity player, array<string> args){
    thread AddNucleotideToDNA( "U" )
    return true;
}
bool function AddCToCodon(entity player, array<string> args){
    thread AddNucleotideToDNA( "C" )
    return true;
}
bool function AddGToCodon(entity player, array<string> args){
    thread AddNucleotideToDNA( "G" )
    return true;
}

void function AddNucleotideToDNA(string nucleotide){
    file.codon.append( nucleotide )

    SendHudMessage( GetPlayerArray()[0], nucleotide, -1, 0.2, 255, 255, 0, 0, 0.15, 20, 0.15 )

    if ( file.codon.len() == 3 ){
        file.DNA.append( file.codon )
        file.codon.clear()
    }
}

#endif

// void function generateRandomCommandNames(){

//     string long_string = "gfihvuyfhbewufbwejyhfbvydwfgyuewcbruyewbfuh4cbyucrg4yufcu32bvfcgy23tygryu34g6r7g346c6734igcr7y6i34rgyicg43yurigewyurcgewurcbewrbyucrgy432grcuewgryg43ygcyurgyu4rgr3wygcgryuewgryucegrygryugewyrgcewyrcgwue"
    
    
// 	command.P = long_string.slice(10,RandomInt(10)+10)
//     command.L = long_string.slice(20,RandomInt(10)+20)
//     command.M = long_string.slice(30,RandomInt(10)+30)
//     command.O = long_string.slice(40,RandomInt(10)+40)
// }

// this is just useless
// string function get_command_P(){
//     return command.P
// }
// string function get_command_M(){
//     return command.M
// }
// string function get_command_L(){
//     return command.L
// }
// string function get_command_O(){
//     return command.O
// }