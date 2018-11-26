# Yunitator

## General intro


Given that there is no reference for this tool, we provide a more extensive introduction based on a presentation Florian Metze gave on 2018-08-13 in an ACLEW Meeting.

The data used for training were:

- ACLEW Starter dataset 
- VanDam public 5-min dataset (about 13h; https://homebank.talkbank.org/access/Public/VanDam-5minute.html); noiseme-sad used to detect and remove intraturn silences

Talker identity annotations collapsed into the following 4 types:

- children (including both the child wearing the device and other children; class prior: .13)
- female adults (class prior .09)
- male adults (class prior .03)
- non-vocalizations  (class prior .75)

The features were MED (multimedia event detection) feature, extracted with OpenSMILE. They were extracted in 2s windows moving 100ms each step. There were 6,669 dims at first, PCA-ed down to 50 dims

The model was a RNN, with 1 bidirectional GRU layer and 200 units in each direction. There was a softmax output layer, which therefore doesn't predict overlaps..

The training regime used 5-fold cross-validation, with 5 models trained on 4/5 of the data and tested on the remainder. The outputs are poooled together to measure performance. The final model was trained on all the data.

The loss function was cross entropy with classes weighted by 1/prior. The batch size was 5 sequences of 500 frames. The optimizer was SGD with Nesterov momentum=.9, the inital LR was .01 and the LR schedule was *=0.8 if frame accuracy doesn’t reach new best in 4 epochs

The resulting F1 for the key classes were:

- Child .55 (Precision .55, recall .55)
- Male adult .43 (P .31, R .61)
- Female adult .55 (P .5, R .62)


## Main references: 

There is no official reference for this tool. 
