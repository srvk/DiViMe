# VCM

## General intro
Two independent models: one (modelLing) to predicts lingustic vs. non-linguistic infant vocalisations; the other one (modelSyll) predicts canonical vs. non-canonical syllables if given a lingustic infant vocalication. 

Specifically, the modelLing was trained on Alex's infant lingustic dataset (refer to this paper: https://static1.squarespace.com/static/591f756559cc68d09fc2e308/t/5b3a94cb758d4645603085db/1530565836736/ZhangEtAl_2018.pdf), and modelSyll was trained on Anne's infant syllable vocalisation dataset (refer to this paper: https://pdfs.semanticscholar.org/2b25/bc84d2c4668e6d17f4f9343106f726198cd0.pdf). 

Feature set: 88 eGeMAPS extracted by openSMILE-2.3.0 on the segment level. 

Model: two hidden layers feed-forward neural networks with 1024 hidden nodes per each hidden layer. A log_softmax layer is stacked as an output layer. The optimiser was set to SGD with a learning rate 0.01, and the batch size is 64.  

Setups: Both the infant linguistic and syllable vocalisation datasets were split into train, development, and test partitions following a speaker independent strategy. 

Results: The results are 67.5% UAR and 76.6% WAR on the test set for the lingustic voc classification; and are 70.4% UAR and 69.2% WAR for the syllable voc classification. 


## Main references: 

There is no official reference for this tool. 
