from twitchio.ext import commands
from twitchio.ext import pubsub
from encoder import encoder
import twitchio
from BotKey import *
from time import sleep

bot_stuff = {
    "client_id" : Client_id,
    "client_secret" : Client_secret,
    "oauth" : Oauth,
    "botPrefix" : BotPrefix,
    "channel" : Channel,
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
        message = message.split(" ")
        data = self.Encoder.get_based_on_id(message[0])[0]
        print(data)
        print(message)
        if data == None:
            return

        sequence = data
        for char in data:
            if char == ';':
                if len( message ) < 2:
                    print("not enough arguments")
                    return
                else:
                    sequence = data.replace( ";", message[1] )

        sequence = self.Encoder.functionToSequence( data ) + "GGG"
        print( sequence )
        sleep( 5 )
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

