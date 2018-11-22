# LDC Diarization Scoring

## General intro

For SAD, we employ the evaluation included in the LDC SAD, which returns the false alarm (FA) rate (proportion of frames labeled as speech that were non-speech in the gold annotation) and missed speech rate (proportion of frames labeled as non-speech that were speech in the gold annotation). For TD, we employ the evaluation developed for the DiHARD Challenge, which returns a Diarization error rate (DER), which sums percentage of speaker error (mismatch in speaker IDs), false alarm speech (non-speech segments assigned to a speaker) and missed speech (unassigned speech).

One important consideration is in order: What to do with files that have no speech to begin with, or where the system does not return any speech at the SAD stage or any labels at the TD stage. This is not a case that is often discussed in the litera- ture because recordings are typically targeted at moments where there is speech. However, in naturalistic recordings, some ex- tracts may not contain any speech activity, and thus one must adopt a coherent framework for the evaluation of such instances. We opted for the following decisions.

If the gold annotation was empty, and the SAD system returned no speech labels, then the FA = 0 and M = 0; but if the SAD system returned some speech labels, then FA = 100 and M = 0. Also, if the gold annotation was not empty and the sys- tem did not find any speech, then this was treated as FA = 0 and M=100.

As for the TD evaluation, the same decisions were used above for FA and M, and the following decisions were made for mismatch. If the gold annotation was empty, regardless of what the system returned, the mismatch rate was treated as 0. If the gold annotation was empty but a pipeline returned no TD labels (either because the SAD in that system did not detect any speech, or because the diarization failed), then this was penalized via a miss of 100 (as above), but not further penalized in terms of talker mismatch, which was set at 0.

## Main references: 

Ryant, N. (2018). LDC SAD. https://github.com/Linguistic-Data-Consortium, accessed: 2018-06-17.
Ryant, N. (2018). Diarization evaluation. https://github.com/nryant/dscore, accessed: 2018-06-17.



