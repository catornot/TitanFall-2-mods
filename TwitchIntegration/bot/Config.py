class Config:
    def __init__(self, function:str, id:str):
        self._id = id
        self._function = function

    def get_function(self):
        return self._function

    def get_id(self):
        return self._id

# put stuff here idk
Configs = [
    Config("createGrunt()","grunt"),
    Config("giveWeaponToStreamer(;)","give"),

]

