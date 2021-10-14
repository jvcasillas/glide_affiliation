filePath$ = "../../data/p08/wavs/syllabified/"

Create Strings as file list... dirFiles 'filePath$'/*.wav
select Strings dirFiles
clearinfo
numberOfFiles = Get number of strings
clearinfor

for i to numberOfFiles
	select Strings dirFiles
	fileName$ = Get string... i
	prefix$ = fileName$ - ".wav"
	Read from file... 'filePath$'/'prefix$'.wav
	Read from file... 'filePath$'/'prefix$'.TextGrid
	#points = Get number of points... 1
	#labels = Count labels: 4, "exclude"
	labID$ = Get label of interval: 7, 1

	syll1 = Get number of intervals: 1
	syll2 = Get number of intervals: 2
	syll3 = Get number of intervals: 3
	syll4 = Get number of intervals: 4
	syll5 = Get number of intervals: 5
	onset = Get number of intervals: 6

	if syll1 > 1

		syll1Lab$ = Get label of interval: 1, 2
		syll1Start = Get starting point: 1, 2
		syll1End = Get starting point: 1, 3
		syll1Dur = syll1End - syll1Start

	elsif syll1 = 1

		syll1Lab$ = "NA"
		syll1Dur = 0

	endif

	if syll2 > 1

		syll2Lab$ = Get label of interval: 2, 2
		syll2Start = Get starting point: 2, 2
		syll2End = Get starting point: 2, 3
		syll2Dur = syll2End - syll2Start

	elsif syll2 = 1

		syll2Lab$ = "NA"
		syll2Dur = 0

	endif

	if syll3 > 1

		syll3Lab$ = Get label of interval: 3, 2
		syll3Start = Get starting point: 3, 2
		syll3End = Get starting point: 3, 3
		syll3Dur = syll3End - syll3Start

	elsif syll3 = 1

		syll3Lab$ = "NA"
		syll3Dur = 0

	endif

	if syll4 > 1

		syll4Lab$ = Get label of interval: 4, 2
		syll4Start = Get starting point: 4, 2
		syll4End = Get starting point: 4, 3
		syll4Dur = syll4End - syll4Start

	elsif syll4 = 1

		syll4Lab$ = "NA"
		syll4Dur = 0

	endif

	if syll5 > 1

		syll5Lab$ = Get label of interval: 5, 2
		syll5Start = Get starting point: 5, 2
		syll5End = Get starting point: 5, 3
		syll5Dur = syll5End - syll5Start

	elsif syll5 = 1

		syll5Lab$ = "NA"
		syll5Dur = 0

	endif

	if onset > 1

		critOnsetLab$ = Get label of interval: 6, 2
		critOnsetStart = Get starting point: 6, 2
		critOnsetEnd = Get starting point: 6, 3
		critOnsetDur = critOnsetEnd - critOnsetStart

	elsif onset = 1

		critOnsetLab$ = "NA"
		critOnsetDur = 0

	endif


	printline 'prefix$','syll1Lab$','syll1Dur:2','syll2Lab$','syll2Dur:2','syll3Lab$','syll3Dur:2','syll4Lab$','syll4Dur:2','syll5Lab$','syll5Dur:2','critOnsetLab$','critOnsetDur:2','labID$'
	select all
	minus Strings dirFiles
	Remove
	endif
endfor

select all
Remove
