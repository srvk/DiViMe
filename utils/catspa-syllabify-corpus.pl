#!/usr/bin/perl

# Alex Cristia alecristia@gmail.com 2015-07-13 adapted VERY MINIMALLY this code from scripts
# distributed by Lawrence Phillips & Lisa Pearl, 12/23/13 (UCI-Brent-Syllabic Corpus) - credit is owed mainly to those authors

# Uses the maximum onset principle to fully syllabify a corpus
use File::Basename;

$language=$ARGV[0];
$filecorpus=$ARGV[1];
$output=$ARGV[2];
$dirname=dirname($filecorpus);

#print "\n the language is $language\n";
# /input/ OR /scripts/ ?
# Save valid onsets from ValidOnsets.txt
%onsets = {};
open(ONSETS, "<$dirname/$language-ValidOnsets.txt") or die("Couldn't open $dirname/$language-ValidOnsets.txt\n");
while(defined($fileline = <ONSETS>)){
    chomp($fileline);
    #print "$fileline\n";
    $onsets{$fileline} = 1; #This is an odd way of stating things
    #print "added";
}
#print "out of the while";
close(ONSETS);

# Save valid vowels from Vowels.txt
%vowels = {};
open(VOWELS, "<$dirname/$language-Vowels.txt") or die("Couldn't open $dirname/$language-Vowels.txt\n");
my $vowels = <VOWELS>;
close(VOWELS);
#print "$vowels\n";

# Go through CORPUS.txt,
# for nonsyllabified words: for each syllable, find its vowel, and its maximum onset, given acceptable onsets and beginning of word.
# print syllabified version to syllabified-CORPUS.txt.
open(SYLLABIFIED, ">$output") or die("Couldn't open $output for writing\n");
open(CORPUS, "<$filecorpus") or die("Couldn't open $filecorpus for reading");



while(defined($fileline = <CORPUS>)){
    #print "entered first while\n";
	chomp($fileline);
	$currline = $fileline;
    @wordarray = split(" ", $currline); # divide the line into a set of words
    $syllline="";#we start with a clean slate for each line
    while(@wordarray > 0){
        $currword = pop(@wordarray); # cut out the last word in the word array & put it in currword
        #print "now looking at $currword\n";
        @chararray = split(//, $currword);

        $syllword="";#we start with a clean slate for each word
        $currsyllable=""; #and for the syllable

        while(@chararray > 0){
            $currchar = pop(@chararray); # cut out the last char in the char array for this word & put it in currchar
            $currsyllable =  $currchar.$currsyllable; # append currchar to current syllable - that will be necessary regardless of whether it's a vowel or a coda
			# if hit a vowel..
            #if($currchar =~ /[ae3EiOo0u]/){
            if($currchar =~ /[$vowels]/){
            #  print "$currchar\n";
                #if(@chararray[@chararray-1] !=~ /[ae3EiOo0u]/){
                if(@chararray[@chararray-1] !=~ /[$vowels]/){
            #      print "@chararray[@chararray-1]\n";
                #if this char is a vowel and the previous one is not, then we need to make the onset
                $onset = ""; #we start with nothing as the onset
                    #then we want to take one letter at a time and check whether their concatenation makes a good onset
                    while(@chararray > 0 && exists($onsets{@chararray[@chararray-1] . $onset})){
                        #print "$onsets{@chararray[@chararray-1] . $onset}\n";
                        $currchar = pop(@chararray);
                        $onset = $currchar . $onset;
                    }
                    #we get here either because we've concatenated the onset+rest or because there was no onset and the preceding element is a vowel, so this is the end of the syllable
                    $currsyllable = $onset . $currsyllable;
                    # add syllable to word entry
                }
                $syllword = "\/" . $currsyllable . $syllword;
                $currsyllable = "";
            }#we end the if we are looking at a vowel
         }#when we end this while there are no more characters in this word, so we can add it
        $syllline=$syllword. " " . $syllline;
        #print "$syllword\n";

	} #while we work our way through the words in the line -- so when we exit this, we are ready to print out a syllabified line
	if($syllline){
		print SYLLABIFIED "$syllline\n";
	}
}#while there are lines in this file

close(SYLLABIFIED);
close(CORPUS);