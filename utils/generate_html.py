# generate_html.py
"""
Given a list of folders that have been fed to the different models,
generate a html file presenting the following results :

wip

Use case :
     python tools/generate_html.py -f data/ -o data/html
It will scan folder data/ and generates the html interface at data/html.
"""

import argparse
import os
import glob
from html_python.files_page import FilesPage
from html_python.models_page import ModelsPage
from html_python.style_css import StyleCSS
from html_python.page import Page

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--folder', type=str,
                        help='<Required> Folder that needs to be analyzed', required=True)
    parser.add_argument('-o', '--output', type = str,
                       help='<Required> The folder where the html files will be generated.', required=True)

    args = parser.parse_args()

    # define data dir
    data_dir = "/vagrant"
    args.folder = os.path.join(data_dir, args.folder)
    args.output = os.path.join(data_dir, args.output)

    style_css = StyleCSS(args.output)
    files_html = FilesPage(args.output, args.folder)
    files_html.write_statistics()

    models_html = ModelsPage(args.output, args.folder)
    models_html.write_statistics()
    models_html.close()

if __name__ == '__main__':
    main()
