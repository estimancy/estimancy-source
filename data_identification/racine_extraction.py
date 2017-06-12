from treetagger import TreeTagger
tt = TreeTagger(language='french')


def extract_racine(word):
	if len(word.split())==1:
		if str(tt.tag(word)[0][1]) in ('NOM','ADJ'):
			racine= str(tt.tag(word)[0][2])
		else:
			racine=word
	if len (word.split())>1:
		racine = ""
		for i in word.split():
			if str(tt.tag(i)[0][1])in ('NOM','ADJ'):
				racine += " "+ str(tt.tag(i)[0][2])
			else:
				racine += " "+i
	return racine