global function ArrayToString

#if SERVER
global function DecodeDNA

const table<string,int> nucleotideToNumber = { // this is base 4
    A = 0
    T = 1
    C = 2
    G = 3
}

const array<int> numberToChar = [
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
    119,
    120,
    121,
    122,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    52,
    39,
    40,
    41
]

string function DecodeDNA( string DNA )
{
    print(DNA)
    string strFunction = ""
    array< string > base4s
    string base4
    int num
    int number
    string strBase4 = ""
    
    // nucleotide to base4
    for( int index = 0; index < DNA.len() ; index++ )
    {
        if ( index % 3 == 0 )
        {
            base4s.append( base4 )
            base4 = ""
        }
        print( DNA[DNA.len() - 1 - index] )
        print( DNA.len() - 1 - index )
        num = nucleotideToNumber[ format("%c", DNA[DNA.len() - 1 - index] )  ]
        print("num " + num)
        base4 += format( " %d", num )
    }

    // base4 to letter
    foreach( base4 in base4s )
    {
        array<string> strBase4 = split( base4, " " )
        number = 0
        for( int x = 0; x < strBase4.len() ; x++ )
        {
            num = strBase4[strBase4.len() - 1 - x].tointeger()
            number += (num * pow( 4,x ) ).tointeger()
        }
        strFunction += format( "%c", numberToChar[number] )
        print( format( "%c", numberToChar[number] ) )
        PrintArray( strBase4 )
    }


    return strFunction
}

// void function DNATo



#endif

string function ArrayToString( array<string> Array, bool spaces = false )
{
    string str
    if ( !spaces ) // const can't be empty they said >:(
    {
        foreach( string line in Array )
        {
            str = format( "%s%s", str, line )
        }
        return str
    }

    foreach( string line in Array )
    {
        str = format( "%s %s", str, line )
    }
    return str
}

void function PrintArray( array<string> Array )
{
    string str

    foreach( string line in Array )
    {
        str = format( "%s %s", str, line )
    }
    print( str )
}