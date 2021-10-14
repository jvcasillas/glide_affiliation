Create Strings as file list... soundFiles ./*.wav
select Strings soundFiles
numberOfFiles = Get number of strings

for i to numberOfFiles
	select Strings soundFiles
	soundName$ = Get string... i
	Read from file... ./'soundName$'
	Scale peak... 0.99
	Write to binary file... ./'soundName$'
	Remove
endfor