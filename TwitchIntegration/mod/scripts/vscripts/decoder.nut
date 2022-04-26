global function DecodeDNA
global function ArrayToString

const table< string, int > nucleotideToNumber
{
    "A" : 0,
    "U" : 1,
    "C" : 2,
    "G" : 3
}

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