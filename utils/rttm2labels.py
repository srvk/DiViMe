#! /usr/bin/python
'''
Created on Oct 4, 2014
@author: fmetze,er1k
convert RTTM (segmented) to Audacity labels format
'''

import sys
import datetime
import re

def printbuf (begin, end, text):
    datetime1 = datetime.datetime.utcfromtimestamp(begin)
    datetime2 = datetime.datetime.utcfromtimestamp(end)
    allseconds1 = 60 * datetime1.minute + 3600 * datetime1.hour + datetime1.second
    allseconds2 = 60 * datetime2.minute + 3600 * datetime2.hour + datetime2.second
    print "%s.%s\t%s.%s\t%s" % (allseconds1, datetime1.strftime('%f'), allseconds2, datetime2.strftime('%f'), text)


for l in sys.stdin:

    m = re.match("^(.*) (.*) (.*) (\S+) (\S+) (.*) (.*) (.*) (.*)$", l)
    if m:
        type, file = m.group(1, 2)
        channel = int(m.group(3))
        starttime = float(m.group(4))
        duration = float(m.group(5))
        ortho = m.group(6)
        stype = m.group(7)
        name = m.group(8)
        conf = m.group(9)

        printbuf (starttime, starttime+duration, name)
        begin = starttime

    elif re.match(";.*", l) or re.match("#.*", l):
        pass

    else:
        raise Exception("cannot process line: " + l)

