from interactions import slash_command, SlashContext, Client, Intents
from bs4 import BeautifulSoup
import requests
import re

url = 'https://www.jftna.org/jft/'
urlSpad = 'https://www.spadna.org/'
bot = Client(intents=Intents.DEFAULT)


@slash_command(name="jft", description="daily reading")
async def my_long_command_function(ctx: SlashContext):
	await ctx.defer()
	r = requests.get(url)
	s = BeautifulSoup(r.text, 'html.parser')
	text = "```"
	for tag in s.find_all('tr'):
		text += tag.text
		text += '\n' 
	text += "```"
	await ctx.send(text)

@slash_command(name="spad", description="daily spiritual principle")
async def my_long_command_function1(ctx: SlashContext):
	await ctx.defer()
	r = requests.get(urlSpad)
	s = BeautifulSoup(r.text, 'html.parser')
	text = "```"
	for tag in s.find_all('tr'):
		text += tag.text
		text += '\n' 
	text += "```"
	await ctx.send(text)

#bot.start("???")

r = requests.get(urlSpad)
# print(r.text)
s = BeautifulSoup(r.text, 'html.parser')
# print(s)
for i, tag in enumerate(s.find_all('tr')):
		tag_text = re.sub(' +', ' ', tag.text)
		print(f"\n*** ROW {i+1}:")
		print(tag_text)
		 

