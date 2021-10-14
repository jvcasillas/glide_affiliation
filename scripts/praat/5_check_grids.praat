####################################
# Praat script to check text grids #
# to check segemtation             #
# Created by                       #
# Joseph V. Casillas 04/25/2018    #
####################################


#### Enter the path to where the files are kept

form Enter information
	comment Folders where files are kept:
	sentence dirFiles ../../data/p04/wavs/carrier/
	sentence dirNew ../../data/p04/wavs/carrier/
endform


#### Prepare the loop
Create Strings as file list: "allFiles", dirFiles$ + "/*.wav"
select Strings allFiles
numberOfFiles = Get number of strings
writeInfoLine: numberOfFiles

#### Begin loop

for i to numberOfFiles
	select Strings allFiles
	fileName$ = Get string... i
	prefix$ = fileName$ - ".wav"
	tgName$ = prefix$ + ".TextGrid"
	Read from file... 'dirFiles$'/'fileName$'
	nameSound$ = selected$("Sound")
	Read from file... 'dirFiles$'/'tgName$'
        select Sound 'nameSound$'
	plus TextGrid 'nameSound$'
	Edit
	pause Continue?
	select Sound 'nameSound$'
	Write to WAV file... 'dirNew$'/'nameSound$'.wav
	select TextGrid 'nameSound$'
	Write to binary file... 'dirNew$'/'nameSound$'.TextGrid
	select all
	minus Strings allFiles
	Remove
	printline 'nameSound$'	'i'
endfor