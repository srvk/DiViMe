# parse_cha_xml.py
#
# Given CHATTER format xml (http://talkbank.org/software/chatter.html)
# supplied as an argument, or via a pipe, print out STM format text
#
# To toggle whether UNIBET words are printed out, or instead appear as "<unk>"
# set the switch --oov.  To instead print their replacements, set the switch --replacment
#
# usage ./parse_cha_xml.py P1_6W_SE_C6.xml
#
# Change Log: 
# 17 Jan 2018 - print plaintext utterances even if no timecode present
# - added handling of "happening" and formType elements
#   to support things like "singing", yell, shout etc.
# - added metadata for speaker e.g. <name,sex,role> as
#   found in 'participant' tags

from xml.dom.minidom import parse
import sys,argparse,os

reload(sys)
sys.setdefaultencoding("utf-8")

parser=argparse.ArgumentParser(description="""Description""")
parser.add_argument('--oov', action='store_true', help='print <oov> symbols for nonwords')
parser.add_argument('--replacement', action='store_true', help='print replacement words')
parser.add_argument('--stm', action='store_true', help='produce STM format')
parser.add_argument('infile', nargs='?', type=argparse.FileType('r'), help='CHATTER (xml) format input file',
                    default=sys.stdin)
args=parser.parse_args()

# a table of speaker IDs and related metadata

infile = args.infile.name
if infile == '<stdin>':
    dom = parse(sys.stdin)
else:
    dom = parse(infile)
utts = dom.getElementsByTagName('u') # utterances
participants = dom.getElementsByTagName('participant')

oov = args.oov
stm = args.stm
replace = args.replacement
#recording = infile[infile.rfind("/")+1:]
# get only base name (chop off .xml extension)
recording = os.path.splitext(os.path.basename(infile))[0]

#utterance = ""

parts = {}
for part in participants:
    label = "<"; ident = ""
    name = ""; role = ""; sex = "u"
    for key in part.attributes.keys():
        if key == "id":
            ident = part.attributes[key].nodeValue.encode('utf8')
        if key == "name": 
            name = part.attributes[key].nodeValue.encode('utf8')
            name = name.replace(" ","")
        if key == "role":
            role = part.attributes[key].nodeValue.encode('utf8')
            role = role.replace(" ","")
        if key == "sex":
            sex = part.attributes[key].nodeValue.encode('utf8')
            if sex == "male": sex = "m"
            if sex == "female": sex = "f"
    parts[ident]=("<"+name+","+sex+","+role+">").lower()
#    print parts[ident]

# add the word found inside node passed in as argument
def addWord( node ):
    global utterance
    for wordlet in node.childNodes:
        if wordlet.nodeType == wordlet.TEXT_NODE:
            unibet = False
            s = wordlet.nodeValue
            try: s.decode('ascii')
            except UnicodeDecodeError: unibet = True
            utterance += " "
            if oov and unibet:
                utterance += "<unk>"
            else:
                utterance += wordlet.nodeValue.encode('utf8')


def addReplacement ( group ):
    added = False
    for subword in group.childNodes:
        if subword.nodeType == subword.ELEMENT_NODE and subword.tagName == 'replacement':
            for replacement in subword.childNodes:
                if replacement.nodeType == replacement.ELEMENT_NODE and replacement.tagName == 'w':
                    addWord( replacement )
                    added = True
    # didn't find a <replacement> - just output the word
    if not added: addWord( group )

def addUnibetOrReplacement( node ):
    global utterance
    for key in node.attributes.keys():
        if key == "untranscribed":
            if oov:
                utterance += " " + "<unk>"
            else:
                addWord( node )
        if key == "type" and (node.attributes[key].nodeValue == "fragment"):
            utterance += " " + node.firstChild.nodeValue
        if key == "formType":
            if node.attributes[key].nodeValue == "UNIBET":
                if replace:
                    addReplacement( node )
                else:
                    addWord( node )
            else: # for all other form types
                  # e.g. singing, babbling, kana, onomotapoeia, family-specific, letter, child-invented
                  # output word
                addWord( node )

for utt in utts:
    utterance = ""
    start = 0
    has_timecode = False
    # speaker
    for key in utt.attributes.keys():
        if key == "who":
            speaker=utt.attributes[key].nodeValue
            spk_reco_clause = recording+" "+speaker+" "+recording+"_"+speaker

    for word in utt.childNodes:
        # time code
        if word.nodeType == word.ELEMENT_NODE and word.tagName == 'media':
            has_timecode = True
            for key in word.attributes.keys():
                if key == "start":
                    start = word.attributes[key].nodeValue
                if key == "end":
                    end = word.attributes[key].nodeValue
                    if stm:
                        # Don't output if start == end; confuses downstream systems
                        if start != end:
                            print spk_reco_clause+" "+start+" "+end+" "+parts[speaker]+\
                              utterance.lower().replace("_"," ").replace("-","")
                        sys.stdout.flush()
                    else: 
                        print utterance.lower().replace("_"," ").replace("-","")
                        sys.stdout.flush()
                    utterance = ""

        # tb:wordType ("<w>" tag)
        if word.nodeType == word.ELEMENT_NODE and word.tagName == 'w':
            if len(word.attributes.keys())==0:
                if word.childNodes.length == 1:
                    addWord( word )
                else:
                    if replace:
                        addReplacement( word )
                    else:
                        addWord( word )
            else:
                addUnibetOrReplacement( word )
        # tb:element type ("<e>" tag):
        if word.nodeType == word.ELEMENT_NODE and word.tagName == 'e':
            for wordlet in word.childNodes:
                if wordlet.nodeType == wordlet.ELEMENT_NODE and wordlet.tagName == 'happening':
                    for txt in wordlet.childNodes:
                        thetxt = txt.nodeValue
                        utterance += " <" + thetxt.encode('utf8') + ">"
        # tb:groupType or phoneticGroupType ("<g>" or "<pg>" tag):
        if word.nodeType == word.ELEMENT_NODE and (word.tagName == 'g' or word.tagName == 'pg'):
            for group in word.childNodes:
                if group.nodeType == group.ELEMENT_NODE and group.tagName == 'w':
                    if len(group.attributes.keys())==0:
                        if group.childNodes.length == 1:
                            addWord( group )
                        else:
                            if replace:
                                addReplacement( group )
                            else:
                                addWord( group )
                    else:
                        # print oov (or unibet encoded word)
                        if oov:
                            utterance += " " + "<unk>"
                        else:
                            addUnibetOrReplacement( group )
    # done with utterance. if it had no timecode, was not printed(!) so
    # print now
    if not has_timecode:
        print utterance.lower().replace("_"," ").replace("-","")
        sys.stdout.flush()
        utterance = ""
