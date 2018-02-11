praatScripts
============

# Basic info

- This folder contains the praat scripts used to clean the original 
audio files and extract data for the two production tasks



# Process

1. '0_label_from_text_file.praat'
	- The 'label_from_text_file.praat' file takes a word list (stim_list.txt) 
and fills in the already segmented textgrid.
	- Must make 'stim_list.txt' file first
	- It is still necessary to double check alignment and accuracy
2. '1_save_labeled_intervals_to_wav_sound_files.praat'
	- The 'save_labeled_intervals_to_wav_sound_files.praat' file uses the 
	segmented textgrid from (1) and creates individual sound files
	- The sound files are saved in a 'wav' folder
	- These are the files to be analyzed
	- I have moved them by hand to 'carrier' or 'syllabified' according to the task
3. '2_normalizeScalePeakIntensity.praat'
	- The 'normalizeScalePeakIntensity.praat' normalizes the peak intensity 
	of all of the files in at the same level
	- This was hand applied to every wav folder and then placed back in scripts
4. '3a_createTextGrids_syllabified.praat' and '3a_createTextGrids_carrier.praat'
	- The 'createTextGrids.praat' file reads in every .wav file from the 
	selected folder ('carrier' or 'syllabified') for each participant and creates a 
	corresponding textgrid.
	- The textgrid labels onset and offset of each segment of the target word
5. '4a_extractVals_syllabified.praat' and '4b_extractVals_carrier.praat'
	- These files will read in all .wav files and their corresponding textgrids 
	in order to extraxt labeled information from (4).
	- This will create a .csv for each each participant for each session
	- All the .csv files will then be read into R and ajoined
	- Note that the output .csv does not contain a header. They are added later 
	in R.
   







