from msilib import sequence
from Config import Configs, Keys
from pynput.keyboard import Key, Controller
from time import sleep
import math

nucleotideOrder = [
    "A",
    "U",
    "C",
    "G"
]

ascii_list = {
   'a' : 0,
   'b' : 1,
   'c' : 2,
   'd' : 3,
   'e' : 4,
   'f' : 5,
   'g' : 6,
   'h' : 7,
   'i' : 8,
   'j' : 9,
   'k' : 10,
   'l' : 11,
   'm' : 12,
   'n' : 13,
   'o' : 14,
   'p' : 15,
   'q' : 16,
   'r' : 17,
   's' : 18,
   't' : 19,
   'u' : 20,
   'v' : 21,
   'w' : 22,
   'x' : 23,
   'y' : 24,
   'z' : 25,
   'A' : 26,
   'B' : 27,
   'C' : 28,
   'D' : 29,
   'E' : 30,
   'F' : 31,
   'G' : 32,
   'H' : 33,
   'I' : 34,
   'J' : 35,
   'K' : 36,
   'L' : 37,
   'M' : 38,
   'N' : 39,
   'O' : 40,
   'P' : 41,
   'Q' : 42,
   'R' : 43,
   'S' : 44,
   'T' : 45,
   'U' : 46,
   'V' : 47,
   'W' : 48,
   'X' : 49,
   'Y' : 50,
   'Z' : 51,
   '"' : 52,
   '(' : 53,
   ')' : 54
}

class encoder:
    def __init__(self):
        self._configs = Configs

    def functionToSequence( self, function, arg = None  ):
        sequence = ''

        for char in function:
            if char != ';':
                base4 = self.__charToBase4( char )
                sequence += self.__Base4ToSequence( base4 )

            elif arg != None:
                for Char in arg:
                    base4 = self.__charToBase4( Char )
                    sequence += self.__Base4ToSequence( base4 )

        return sequence

    def __charToBase4( self, char ):
        workingNum = ascii_list[char]
        base4 = ""

        if workingNum == 0: return '0'

        while( abs( int( workingNum ) ) != 0 ):
            base4 += str( abs( int( math.remainder(workingNum, 4) ) ) )
            workingNum = abs( int( workingNum / 4 ) )

        if base4[-1] == '0':
            return base4[0:-1]
        return base4

    def __Base4ToSequence( self, base4 ):
        sequence = ""
        for i in base4:
            sequence += nucleotideOrder[ int(i) ]

        if ( len( sequence ) < 3 ):
            sequence += "A" * ( 3 - len( sequence ) )

        return sequence

    def send_code( self, sequence ):
        keyboard= Controller()
        for nucleo in sequence:
            if nucleo == "A":
                key = "f14"
            elif nucleo == "U":
                key = "f15"
            elif nucleo == "G":
                key = "f16"
            elif nucleo == "C":
                key = "f17"
            else:
                raise "Unhandled"

            keyboard.press(Keys[nucleo])
            keyboard.release(Keys[nucleo])

            sleep(0.01)

    def get_based_on_id(self,id):
        working_list = []

        for con in self._configs:
            if con.get_id() == id:
                working_list.append( con.get_function() )

        if len(working_list) == 0:
            return None
        else:
            return working_list

if __name__ == '__main__':
    e = encoder()
    function = e.get_based_on_id("give")
    print( e.functionToSequence( function[0] ) )

