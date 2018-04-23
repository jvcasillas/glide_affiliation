# This script opens each sound file in a directory, looks for a 
# corresponding TextGrid in (possibly) a different directory, and 
# extracts f0, F1, and F2 in 10% increments over the time course of 
# any labelled interval(s) in the specified TextGrid tier.  It also 
# extracts the duration of the labelled interval(s).  

# All these results are written to a .csv file 
# The script is a modified version of the modified version of the script 
# "collect_formant_data_from_files.praat" by Mietta Lennes, available 
# here: http://www.helsinki.fi/~lennes/praat-scripts/
# The 2nd interation of modifications were done by Dan McCloy (drmccloy@uw.edu) 
# in December 2011.

# The time course modifications and relative path directory changes were done 
# by Joseph V. Casillas (joseph.casillas@rutgers.edu) in April of 2018.

# This script is distributed under the GNU General Public License.
# Copyright 4.7.2003 Mietta Lennes

form Get pitch formants and duration from labeled segments in files
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory ../data/p06/wavs/carrier/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory ../data/p06/wavs/carrier/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultsfile ../data/p06/data/carrier/p06_carrier.csv
	comment Which tier do you want to analyze?
	integer Tier 1
	comment Formant analysis parameters
	positive Time_step 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 6000
	positive Window_length_(s) 0.025
	real Preemphasis_from_(Hz) 50
	comment Pitch analysis parameters
	positive Pitch_time_step 0.01
	positive Minimum_pitch_(Hz) 50
	positive Maximum_pitch_(Hz) 400
endform

# Make a listing of all the sound files in a directory:
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultsfile$)
	pause The file 'resultsfile$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile$'
endif

# Create a header row for the result file: (remember to edit this if 
# you add or change the analyses!)
header$ = "Filename,TextGridLabel,duration,f0_00,f1_00,f2_00,f3_00,f0_10,f1_10,f2_10,f3_10,f0_20,f1_20,f2_20,f3_20,f0_30,f1_30,f2_30,f3_30,f0_40,f1_40,f2_40,f3_40,f0_50,f1_50,f2_50,f3_50,f0_60,f1_60,f2_60,f3_60,f0_70,f1_70,f2_70,f3_70,f0_80,f1_80,f2_80,f3_80,f0_90,f1_90,f2_90,f3_90,f0_100,f1_100,f2_100,f3_100'newline$'"
fileappend "'resultsfile$'" 'header$'

# Open each sound file in the directory:
for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'

	# get the name of the sound object:
	soundname$ = selected$ ("Sound", 1)

	# Look for a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"

	# if a TextGrid exists, open it and do the analysis:
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

		select Sound 'soundname$'
		To Formant (burg)... time_step maximum_number_of_formants maximum_formant window_length preemphasis_from

		select Sound 'soundname$'
		To Pitch... pitch_time_step minimum_pitch maximum_pitch

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier

		# Pass through all intervals in the designated tier, and if 
		# they have a label, do the analysis:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				duration = end-start
				perc_10 = (duration * 0.1) + start
				perc_20 = (duration * 0.2) + start
				perc_30 = (duration * 0.3) + start
				perc_40 = (duration * 0.4) + start
				perc_50 = (duration * 0.5) + start
				perc_60 = (duration * 0.6) + start
				perc_70 = (duration * 0.7) + start
				perc_80 = (duration * 0.8) + start
				perc_90 = (duration * 0.9) + start

				# formants:
				select Formant 'soundname$'
				f1_00 = Get value at time... 1 start Hertz Linear
				f2_00 = Get value at time... 2 start Hertz Linear
				f3_00 = Get value at time... 3 start Hertz Linear
				f1_10 = Get value at time... 1 perc_10 Hertz Linear
				f2_10 = Get value at time... 2 perc_10 Hertz Linear
				f3_10 = Get value at time... 3 perc_10 Hertz Linear
				f1_20 = Get value at time... 1 perc_20 Hertz Linear
				f2_20 = Get value at time... 2 perc_20 Hertz Linear
				f3_20 = Get value at time... 3 perc_20 Hertz Linear
				f1_30 = Get value at time... 1 perc_30 Hertz Linear
				f2_30 = Get value at time... 2 perc_30 Hertz Linear
				f3_30 = Get value at time... 3 perc_30 Hertz Linear
				f1_40 = Get value at time... 1 perc_40 Hertz Linear
				f2_40 = Get value at time... 2 perc_40 Hertz Linear
				f3_40 = Get value at time... 3 perc_40 Hertz Linear
				f1_50 = Get value at time... 1 perc_50 Hertz Linear
				f2_50 = Get value at time... 2 perc_50 Hertz Linear
				f3_50 = Get value at time... 3 perc_50 Hertz Linear
				f1_60 = Get value at time... 1 perc_60 Hertz Linear
				f2_60 = Get value at time... 2 perc_60 Hertz Linear
				f3_60 = Get value at time... 3 perc_60 Hertz Linear
				f1_70 = Get value at time... 1 perc_70 Hertz Linear
				f2_70 = Get value at time... 2 perc_70 Hertz Linear
				f3_70 = Get value at time... 3 perc_70 Hertz Linear
				f1_80 = Get value at time... 1 perc_80 Hertz Linear
				f2_80 = Get value at time... 2 perc_80 Hertz Linear
				f3_80 = Get value at time... 3 perc_80 Hertz Linear
				f1_90 = Get value at time... 1 perc_90 Hertz Linear
				f2_90 = Get value at time... 2 perc_90 Hertz Linear
				f3_90 = Get value at time... 3 perc_90 Hertz Linear
				f1_100 = Get value at time... 1 end Hertz Linear
				f2_100 = Get value at time... 2 end Hertz Linear
				f3_100 = Get value at time... 3 end Hertz Linear

				# pitch:
				select Pitch 'soundname$'
				f0_00 = Get value at time... start Hertz Linear
				f0_10 = Get value at time... perc_10 Hertz Linear
				f0_20 = Get value at time... perc_20 Hertz Linear
				f0_30 = Get value at time... perc_30 Hertz Linear
				f0_40 = Get value at time... perc_40 Hertz Linear
				f0_50 = Get value at time... perc_50 Hertz Linear
				f0_60 = Get value at time... perc_60 Hertz Linear
				f0_70 = Get value at time... perc_70 Hertz Linear
				f0_80 = Get value at time... perc_80 Hertz Linear
				f0_90 = Get value at time... perc_90 Hertz Linear
				f0_100 = Get value at time... end Hertz Linear

				# Save result to text file:
				resultline$ = "'soundname$','label$','duration','f0_00','f1_00','f2_00','f3_00','f0_10','f1_10','f2_10','f3_10','f0_20','f1_20','f2_20','f3_20','f0_30','f1_30','f2_30','f3_30','f0_40','f1_40','f2_40','f3_40','f0_50','f1_50','f2_50','f3_50','f0_60','f1_60','f2_60','f3_60','f0_70','f1_70','f2_70','f3_70','f0_80','f1_80','f2_80','f3_80','f0_90','f1_90','f2_90','f3_90','f0_100','f1_100','f2_100','f3_100''newline$'"
				fileappend "'resultsfile$'" 'resultline$'

				# select the TextGrid so we can iterate to the next interval:
				select TextGrid 'soundname$'
			endif
		endfor

		# Remove the TextGrid, Formant, and Pitch objects
		select TextGrid 'soundname$'
		plus Formant 'soundname$'
		plus Pitch 'soundname$'
		Remove
	endif

	# Remove the Sound object
	select Sound 'soundname$'
	Remove
	# and go on with the next sound file!
	select Strings list
endfor

# When everything is done, remove the list of sound file paths:
Remove