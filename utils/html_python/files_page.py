import html_python.page as page
import html_python.utils as utils
import html_python.style_css as style_css
import numpy as np
import os
import glob
import random
import numbers
from collections import OrderedDict


class FilesPage(page.Page):

    def __init__(self, output_folder, results_folder):
        # Initialize self.output_folder & self.results_folder
        page.Page.__init__(self, output_folder, results_folder)

        self.N_files = 20 # Fix the number of files to print in the table

        # List of gold files
        self.gold_files = [fn for fn in glob.iglob(os.path.join(self.results_folder, '*.rttm'))
                      if not os.path.basename(fn).startswith(('ldc_sad', 'diartk', 'noisemes_sad',
                                                              'opensmile', 'tocombo_sad', 'lena', 'yunitator'))]
        # Name of the html that will be generated
        self.name = 'files.html'

        # File descriptor
        self.html = open(os.path.join(self.output_folder, self.name), 'w')

        tabs = '<link rel="stylesheet" type="text/css" href="' + style_css.css_name + '">\n' + \
               '<div id="menu">\n' + \
               '<ul id="onglets">\n' + \
               '<li class="active"><a href="files.html"> Files </a></li>\n' + \
               '<li><a href="models.html"> Models </a></li>\n' + \
               '</ul>\n' + \
               '</div>'
        self.html.write(tabs)#write tabs

        # Compute statistics
        self._compute_statistics()

        if len(self.audio_stats) > self.N_files:
            self.random_indices = np.sort(random.sample(range(0, len(self.audio_stats)), self.N_files))
        else:
            self.random_indices = range(0, len(self.audio_stats))

    def _compute_statistics(self):

        self.audio_stats = []
        self.gold_stats = []

        # Empty OrderedDict that will contains the unique keys of the gold file
        # We use only the keys, it's to fake an OrderedSet that doesn't exist natively in python.
        # The difficulty here is that gold2.rttm could have some participants that gold1.rttm doesn't have.
        # We still want to consider them in all of the rttm to present the results in a table.
        self.gold_keys = OrderedDict({})
        for gold in self.gold_files: #for each reference rttm file

            wav_path = os.path.splitext(gold)[0]+'.wav'

            # Get .wav information
            audio_stats_file = utils.analyze_wav(wav_path)
            self.audio_stats.append(audio_stats_file)

            # Analyze gold
            dur_wav = audio_stats_file['duration (s)']
            gold_stats_file = utils.analyze_rttm(gold, dur_wav)
            self.gold_keys = OrderedDict.fromkeys(self.gold_keys.keys() + gold_stats_file.keys())
            self.gold_stats.append(gold_stats_file)

        self._compute_averages()
        self.audio_stats = np.array(self.audio_stats)
        self.gold_stats = np.array(self.gold_stats)

    def _compute_averages(self):

        # Get audio stats averages
        self.averages_audio = OrderedDict(zip(self.audio_stats[0].keys()[2:], [0.0] * (len(self.audio_stats[0]) - 2)))
        for line in self.audio_stats:
            for key in line.keys():
                if isinstance(line[key], numbers.Number) and line[key] is not None:  # None and non numbers are considered as being 0.0
                    self.averages_audio[key] += line[key]

        for k, v in self.averages_audio.items():
            self.averages_audio[k] = v/len(self.audio_stats)

        # Get gold stats averages
        self.averages_gold = OrderedDict(zip(self.gold_keys.keys()[1:], [0.0] * (len(self.gold_keys) - 1)))
        for line in self.gold_stats:
            for key in line.keys():
                if isinstance(line[key], numbers.Number) and line[key] is not None:  # None and non numbers are considered as being 0.0
                    self.averages_gold[key] += line[key]

        for k, v in self.averages_gold.items():
            self.averages_gold[k] = v/len(self.gold_stats)


    def _write_value(self, value, number_of_digits = 4):
        if isinstance(value, str):
            self.html.write('<td> %s </td>\n' % value)
        elif isinstance(value, float) or isinstance(value, np.float64) or isinstance(value, np.float32):
            self.html.write('<td> %.*f</td>\n' % (number_of_digits,value))
        elif isinstance(value, int):
            self.html.write('<td> %d </td>\n' % value)

    def write_audio_stats(self):
        keys = self.audio_stats[0].keys()

        # Open table
        self.html.write('<h2>Audio level statistics</h2>\n<table>\n')

        # Write first line of the table
        self.html.write('<tr>\n')
        for k in keys:
            self.html.write('<th> %s </th>\n' % k)
        self.html.write('</tr>\n')

        # Write audio statistics
        for d in self.audio_stats[self.random_indices]:
            self.html.write('<tr>\n')
            for key, value in d.items():
                self._write_value(value, 4)

            self.html.write('</tr>\n')

        # Write averages
        self.averages_audio["filename"] = "averages"
        for k in keys:
            if k in self.averages_audio:
                self._write_value(self.averages_audio[k], 4)
            else:
                self._write_value("")

        # Close table
        self.html.write('</table>')


    def write_gold_stats(self):

        keys = self.gold_stats[0].keys()

        # Open table
        self.html.write('<h2>Annotation level statistics</h2>\n<table>\n')

        # Write first line of the table
        self.html.write('<tr>\n')
        for k in self.gold_keys:
            self.html.write('<th> %s </th>\n' % k)
        self.html.write('</tr>\n')

        # Write gold statistics
        for d in self.gold_stats[self.random_indices]:
            self.html.write('<tr>\n')
            for key in self.gold_keys:
                if key in d:
                    self._write_value(d[key], 2)
                else:
                    self._write_value("")
            self.html.write('</tr>\n')

        # Write averages
        self.averages_gold["filename"] = "averages"
        for k in self.gold_keys:
            if k in self.averages_gold:
                self._write_value(self.averages_gold[k], 2)
            else:
                self._write_value("")

        # Close table
        self.html.write('</table>')

    def write_statistics(self):
        self.write_audio_stats()
        self.write_gold_stats()
        if len(self.audio_stats) > self.N_files:
            self.html.write("<br><br>Note : a random sample of %d files has been made to lighten the presentation." % self.N_files)

    def close(self):
        self.html.close()