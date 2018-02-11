####################################
# Praat script to create textgrids #
# Created by                       #
# Joseph V. Casillas 10/26/2015    #
####################################


#### Enter the path to where the files are kept

form Enter information
	comment Folders where files are kept:
	sentence dirFiles ../data/p0X/syllabified/
	sentence newDir ../data/p0X/syllabified/
	positive number 1
endform


#### Prepare the loop
Create Strings as file list: "allFiles", dirFiles$ + "/*.wav"
select Strings allFiles
numberOfFiles = Get number of strings
clearinfo
#### Begin loop

for i from number to numberOfFiles
	select Strings allFiles
	fileName$ = Get string... i
	prefix$ = fileName$ - ".wav"
	Read from file... 'dirFiles$'/'fileName$'
	nameSound$ = selected$("Sound")
        To TextGrid: "syll1-on syll1-off syll2-on syll2-off syll3-on syll3-off syll4-on syll4-off syll5-on syll5-off", ""
	select TextGrid 'nameSound$'
        select Sound 'nameSound$'
	plus TextGrid 'nameSound$'
	Edit
	pause Continue?
	select Sound 'nameSound$'
	Write to WAV file... 'newDir$'/'nameSound$'.wav
	select TextGrid 'nameSound$'
	Write to binary file... 'newDir$'/'nameSound$'.TextGrid
	select all
	minus Strings allFiles
	Remove
	printline 'nameSound$'	'i'
endfor