####################################
# Praat script to create textgrids #
# Created by                       #
# Joseph V. Casillas 10/26/2015    #
####################################


#### Enter the path to where the files are kept

form Enter information
	comment Folders where files are kept:
	sentence dirFiles ../data/p03/wavs/carrier/
	sentence newDir ../data/p03/wavs/carrier/
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
        To TextGrid: "totalDur notes", ""
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