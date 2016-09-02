#!/usr/bin/env python3
import os

import sphinxbase as sb
import pocketsphinx as ps

MODELDIR = '/home/administrator/pocketsphinx/pocketsphinx-5prealpha/model/ru'
#MODELDIR = '/home/administrator/pocketsphinx/pocketsphinx-5prealpha/model/en-us'

# Create a decoder with certain model
config = ps.Decoder.default_config()

config.set_string('-hmm', os.path.join(MODELDIR, 'zero_ru.cd_cont_4000'))
config.set_string('-lm', os.path.join(MODELDIR, 'ru.lm'))
config.set_string('-dict', os.path.join(MODELDIR, 'ru.dic'))
"""
config.set_string('-hmm', os.path.join(MODELDIR, 'en-us'))
config.set_string('-lm', os.path.join(MODELDIR, 'en-us.lm.bin'))
config.set_string('-dict', os.path.join(MODELDIR, 'cmudict-en-us.dict'))
"""
decoder = ps.Decoder(config)

# Decode streaming data.
decoder.start_utt()
stream = open(os.path.join('data', '1.wav'), 'rb')
while True:
    buf = stream.read(1024)
    if buf:
        decoder.process_raw(buf, False, False)
    else:
        break
decoder.end_utt()
stream.close()

hypothesis = decoder.hyp()
bestGuess = hypothesis.hypstr
print("Возможный текст:{}".format(bestGuess))

#print("TEST: ", [seg.word for seg in decoder.seg()])
