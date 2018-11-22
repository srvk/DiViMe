import html_python.page as page
import html_python.utils as utils
import numpy as np
import os
import glob
import html_python.style_css as style_css
from collections import OrderedDict


class ModelsPage(page.Page):

    def __init__(self, output_folder, results_folder):
        # Initialize self.output_folder & self.results_folder
        page.Page.__init__(self, output_folder, results_folder)

        # Name of the html that will be generated
        self.name = 'models.html'

        # File descriptor
        self.html = open(os.path.join(self.output_folder, self.name), 'w')

        tabs = '<link rel="stylesheet" type="text/css" href="' + style_css.css_name + '">\n' + \
                    '<div id="menu">\n' + \
                    '<ul id="onglets">\n' + \
                    '<li><a href="files.html"> Files </a></li>\n' + \
                    '<li class="active"><a href="models.html"> Models </a></li>\n' + \
                    '</ul>\n' + \
                    '</div>'
        self.html.write(tabs) #write tabs

        # List of df files present in the results_folder
        self.df_files = [fn for fn in glob.iglob(os.path.join(self.results_folder, '*.df'))]

    def _get_statistics(self):
        self.sad_stats = []
        self.diar_stats = []
        for df_path in self.df_files:
            basename = os.path.splitext(os.path.basename(df_path))[0]
            if basename.startswith(('diartk','lena','yunitator')):
                self.diar_stats.append(utils.get_averages(df_path))
            else:
                self.sad_stats.append(utils.get_averages(df_path))

    def _write_SAD_statistics(self):
        # Write SAD table
        if len(self.sad_stats) == 0:
            self.html.write("No SAD model evaluations have been found.")
        else:
            # Open table
            self.html.write('<h2>SAD statistics</h2>\n<table>\n')
            # Write first line of the table
            self.html.write('<tr>\n')
            keys = self.sad_stats[0].keys()
            for k in keys:
                self.html.write('<th> %s </th>\n' % k)
            self.html.write('</tr>\n')

            # Write statistics
            for d in self.sad_stats:
                self.html.write('<tr>\n')
                for key, value in d.items():
                    utils.write_value(self.html, value, 4)
                self.html.write('</tr>\n')
            # Close table
            self.html.write('</table>')

    def _write_diar_statistics(self):
        # Write SAD table
        if len(self.diar_stats) == 0:
            self.html.write("No diarization model evaluations have been found.")
        else:
            # Open table
            self.html.write('<h2>Diarization statistics</h2>\n<table>\n')
            # Write first line of the table
            self.html.write('<tr>\n')
            keys = self.diar_stats[0].keys()
            for k in keys:
                self.html.write('<th> %s </th>\n' % k)
            self.html.write('</tr>\n')

            # Write statistics
            for d in self.diar_stats:
                self.html.write('<tr>\n')
                for key, value in d.items():
                    utils.write_value(self.html, value, 2)
                self.html.write('</tr>\n')
                
            # Close table
            self.html.write('</table>')

    def write_statistics(self):
        if len(self.df_files) == 0:
            self.html.write("No df files have been found... Please run the evaluation of choose another folder.")
        else:
            self._get_statistics()
            self._write_SAD_statistics()
            self._write_diar_statistics()




    def close(self):
        self.html.close()