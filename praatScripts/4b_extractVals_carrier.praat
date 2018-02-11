filePath$ = "../data/session6/lmw_prodShadow6_2015_Aug_09_1440/wavs/"

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
	points = Get number of points... 1
	labels = Count labels: 4, "exclude"
	labID$ = Get label of interval: 4, 1

	if labels = 0
	
		if points = 1
		voicing = Get time of point... 2 1
		release = Get time of point... 1 1
		vot = (voicing - release) * 1000
		window = release + 0.025

		vowelStart = Get start point: 3, 2
		vowelEnd  = Get end point: 3, 3
		durationV =  vowelEnd - vowelStart
		mp = vowelStart + (durationV * 0.50)

		# get formants
		select Sound 'prefix$'
		do ("To Formant (burg)...", 0, 5, 5500, 0.025, 50)
		f1H = do ("Get value at time...", 1, mp, "Hertz", "Linear")
		f2H = do ("Get value at time...", 2, mp, "Hertz", "Linear")

		f1 = hertzToMel(f1H)
		f2 = hertzToMel(f2H)

		if vot > 0 and vot < 0.025

			select Sound 'prefix$'
			Extract part... release voicing "Gaussian1" 1 "yes"
			nameSpectrum$ = prefix$ + "_part"
			select Sound 'nameSpectrum$'
			To Spectrum... yes
			select Spectrum 'nameSpectrum$'
			cog = Get centre of gravity... 2
			sd = Get standard deviation... 2
			sk = Get skewness... 2
			kt = Get kurtosis... 2

			select Sound 'prefix$'
			To Intensity... 100 0 yes
			riB = Get mean... release voicing dB
			riV = Get mean... vowelStart vowelEnd dB
			ri = riV - riB

		elsif vot < 0
	
			select Sound 'prefix$'
			Extract part... release window "Gaussian1" 1 "yes"
			nameSpectrum$ = prefix$ + "_part"
			select Sound 'nameSpectrum$'
			To Spectrum... yes
			select Spectrum 'nameSpectrum$'
			cog = Get centre of gravity... 2
			sd = Get standard deviation... 2
			sk = Get skewness... 2
			kt = Get kurtosis... 2

			select Sound 'prefix$'
			To Intensity... 100 0 yes
			riB = Get mean... release window dB
			riV = Get mean... vowelStart vowelEnd dB
			ri = riV - riB

		elsif vot > 0.025
	
			select Sound 'prefix$'
			Extract part... release window "Gaussian1" 1 "yes"
			nameSpectrum$ = prefix$ + "_part"
			select Sound 'nameSpectrum$'
			To Spectrum... yes
			select Spectrum 'nameSpectrum$'
			cog = Get centre of gravity... 2
			sd = Get standard deviation... 2
			sk = Get skewness... 2
			kt = Get kurtosis... 2

			select Sound 'prefix$'
			To Intensity... 100 0 yes
			riB = Get mean... release window dB
			riV = Get mean... vowelStart vowelEnd dB
			ri = riV - riB
	
		endif

	endif

	printline 'prefix$','f1:2','f2:2','vot:2','ri:2','cog:2','sd:2','sk:2','kt:2','labID$'
	select all
	minus Strings dirFiles
	Remove
	endif
endfor

select all
Remove
