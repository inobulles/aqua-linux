from chatterbot import ChatBot
from chatterbot.trainers import ListTrainer
from chatterbot.trainers import ChatterBotCorpusTrainer

my_bot = ChatBot(name='PyBot', read_only=True,
                 logic_adapters=['chatterbot.logic.BestMatch'])

corpus_trainer = ChatterBotCorpusTrainer(my_bot)
corpus_trainer.train('chatterbot.corpus.french')

fp = open("whatsapp.txt", "r")
dialog = []

for l in fp.readlines():
	s = l.split(':')
	if len(s) > 1:
		dialog.append("".join(s[2: len(s)])[1: -1])

trainer = ListTrainer(my_bot)
trainer.train(dialog)

while 1:
	print("Maxime: ", my_bot.get_response(input("Input: ")))

fp.close()
