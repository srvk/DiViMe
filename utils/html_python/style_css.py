import os

css_name = "style.css" # global variable


class StyleCSS:

    def __init__(self, output_folder):
        # The output folder where to store the html/css files.
        self.output_folder = output_folder

        if not os.path.exists(self.output_folder):
            os.makedirs(self.output_folder)

        self.css = open(os.path.join(self.output_folder, 'style.css'), 'w')

        # tabs style
        tabs_style = "ul {background: #333;list-style: none;overflow: hidden;text-align: center;}\n" + \
                    "ul li {display: inline-block;}\n" + \
                    "ul li a {padding: 5px 10px;background: #333;color: #fff;line-height: 3em;display: block; }\n" + \
                    "ul li a:hover {background: #e4e4e4;color: #333;}\n" + \
                    "li.active>a {background: #e4e4e4;color: #333;}\n" + \
                    "a {display : block;color : #666;text-decoration : none;padding : 4px;}\n"

        # table style
        table_style = "table {margin: 0 auto;}\n" +\
                      "td, th {border: 1px solid  #ddd;padding: 8px;text-align: center;}\n" +\
                      "tr:nth-child(even){background-color:  #f2f2f2;}\n" +\
                      "tr:hover {background-color:  #ddd;}\n" +\
                      "th {padding-top: 12px;padding-bottom: 12px;text-align: center;background-color:  #333;color: white;}\n"
        self.css.write(tabs_style)
        self.css.write(table_style)
        self.css.close()