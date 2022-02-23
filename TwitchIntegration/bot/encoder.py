from Config import Configs
from pynput.keyboard import Key, Controller
from time import sleep

class encoder:
    def __init__(self):
        self._configs = Configs
    
    def send_code(sequence):
        keyboard= Controller()
        for nuclei in sequence: 
            if nuclei == "A":
                nuclei = "p"
            elif nuclei == "U":
                nuclei = "l"
            elif nuclei == "G":
                nuclei = "O"
            elif nuclei == "C":
                nuclei = "M"
            else:
                raise "Unhandled"
        
            keyboard.press(nuclei)
            keyboard.release(nuclei)
            
            sleep(0.01)

    
    def get_based_on_id(self,id):
        working_list = []

        for con in self._configs:
            if con.get_id() == id:
                working_list.append( con.get_sequence() )
        
        if len(working_list) == 0:
            return None
        else:
            return working_list

if __name__ == '__main__':
    e = encoder()
    print(e.get_based_on_id("boom"))

