global function DecodeDNA
global function ArrayToString

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