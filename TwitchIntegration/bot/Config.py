class Config:
    def __init__(self, sequence:str, id:str):
        #check for compatibility
        if len(sequence) % 3 == 0:

            # self._sequence = []
            # prevI = 0
            # for i in range(int( len( sequence ) / 3 )):
            #     i += 1
            #     self._sequence.append( sequence[prevI:i*3] )
            #     prevI = i*3
            # this is just not ideal
            self._sequence = sequence 

            self._id = id
        else:
            raise("needs to be a multiple of 3")
    
    def get_sequence(self):
        return self._sequence
    
    def get_id(self):
        return self._id

# put stuff here idk
Configs = [
    Config("AAA","boom"),
    Config("AAU","boom2"),

]
        
