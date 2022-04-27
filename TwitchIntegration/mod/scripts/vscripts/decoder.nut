global function Init_Decoder
global function DecodeDNA
global function ArrayToString

table< int, string > Special_char

enum nucleotideToNumber { // this is base 4
    A
    U
    C
    G
}

enum numberToString { // this is base 10 and its ascii but smaller
   a
   b
   c
   d
   e
   f
   g
   h
   i
   j
   k
   l
   m
   n
   o
   p
   q
   r
   s
   t
   u
   v
   w
   x
   y
   z
   A
   B
   C
   D
   E
   F
   G
   H
   I
   J
   K
   L
   M
   N
   O
   P
   Q
   R
   S
   T
   U
   V
   W
   X
   Y
   Z
   Special_Quot
   Special_Parenthesis_Left
   Special_Parenthesis_Right
}

void function Init_Decoder()
{
    Special_char['"'] <- "Special_Quot"
    Special_char['('] <- "Special_Parenthesis_Left"
    Special_char[')'] <- "Special_Parenthesis_Right"
}

void functionref( array< string > ) function DecodeDNA( string DNA )
{
    
}

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