from gensim.models import KeyedVectors
from gensim.test.utils import datapath
from pprint import pprint

wv_from_text = KeyedVectors.load_word2vec_format('entity_vector.model.bin', binary=True)  # C text format

print('Started Output Similar Words')
print('SQL likes these words:')
pprint(wv_from_text.most_similar('[SQL]', None, 30))
print('JavaScript likes these words:')
pprint(wv_from_text.most_similar('[JavaScript]', None, 30))
print('Chrome likes these words:')
pprint(wv_from_text.most_similar('Chrome', None, 30))
print('Laravel likes these words:')
pprint(wv_from_text.most_similar('Laravel', None, 30))