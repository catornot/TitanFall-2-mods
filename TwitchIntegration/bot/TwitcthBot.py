from twitchio.ext import commands
from twitchio.ext import pubsub
from encoder import encoder
import twitchio

bot_stuff = {

    "botNickname" : "TF2 madness", # this doesn't work why? idc
    "botPrefix" : "?",
    "channel" : ["cat_or_not"],
}

class Bot(commands.Bot):

    def __init__(self):
        super().__init__(
            token = bot_stuff["oauth"],
            prefix = bot_stuff["botPrefix"], 
            initial_channels = bot_stuff["channel"],
        )

        self.Encoder = encoder()

    async def event_ready(self):

        print(f'Logged in as | {self.nick}')

    async def event_message(self, message):
        if message.echo:
            return
        
        print(message.content)

        await self.handle_commands(message)
    
    @commands.command()
    async def apply(self, ctx: commands.Context):
        message = ctx.message.raw_data.split("?apply")[1][1:]
        data = self.Encoder.get_based_on_id(message)
        print(data)
        print(message)
        if data == None:
            return
        if len(data) != 1:
            return
        
        # sequence = data[0]
        sequence = data
        self.Encoder.send_code(sequence)

    @commands.command()
    async def help(self, ctx: commands.Context):
        await ctx.reply('https://github.com/catornot/TitanFall-2-mods/tree/main/TwitchIntegration/bot#readme')
    

if __name__ == '__main__':
    bot = Bot()
    bot.run()


# also all of this is just PAIN
#https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/
#2 hours to find this wow

# import twitchio
# import asyncio
# from twitchio.ext import pubsub

# my_token = bot_stuff["oauth"]
# client = twitchio.Client(token=my_token)
# client.pubsub = pubsub.PubSubPool(client)

# users_oauth_token = bot_stuff["oauth"]
# users_channel_id = 29672771

# @client.event()
# async def event_pubsub_channel_points(event: pubsub.PubSubChannelPointsMessage):
#     print(event.reward.title)

# async def main():
#     topics = [
#         pubsub.channel_points(users_oauth_token)[users_channel_id],
#     ]
#     await client.pubsub.subscribe_topics(topics)
#     await client.start()

# if __name__ == '__main__':
#     client.loop.run_until_complete(main())

