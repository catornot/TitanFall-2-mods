global function DecodeDNA
global function ArrayToString

const table< string, int > nucleotideToNumber // this is base 4
{
    "A" : 0,
    "U" : 1,
    "C" : 2,
    "G" : 3
}

const table< int, string > numberToString // this is base 10 and its ascii but smaller
{
    
} 
// we may have chr and ord

void functionref( array< string > ) function DecodeDNA( string DNA )
{
    
}

string function ArrayToString( array<string> Array, bool spaces = false )
{
    string str
    string space = ' '
    if ( !spaces )
        space = ''

    foreach( string line in Array )
    {
        str = format( "%s%s%s", ArrayToString, space, line )
    }

    return str
}