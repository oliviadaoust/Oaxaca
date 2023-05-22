# Oaxaca Binder Decomposition

Decompositions of the income gap with leading metro area in 14 Latin American countries into an endowment component, reflecting sorting, and a returns-to-endowment component, capturing the portion of the gap that could be exploited through migration.

The enclosed data and code replicates all tables and graphs in "Territorial Productivity Differences within Countries in Latin America?", by Olivia D’Aoust, Virgilio Galdo, and Elena Ianchovichina.
Please cite this paper if you use this code.

All scripts require modification of cd pathnames to match the user's file system.  

1. Main do files

Cleaning/harmonizing SEDLAC for Oaxaca Blinder decomposition
	Country do files, CEPAL deflators, MEX and BRA deflators, MEX muninames are in "Cleaning" folder (used when deflators are not in the survey)
	Country data are organized by country and pulled from "SEDLAC" folder

First part of analysis looks at differential in labor income gaps per capita, based on adult head of household. 

"Decomp eform head" runs the income decompositions comparing the leading region for subgroups (all, b40, urban, skilled, rural) for all surveys but ARG and URY.  
"Decomp eform urban only head" runs the income decompositions by subgroups for ARG and URY (b40, urban, skilled, rural) as both countries only survey urban areas.

Second part looks at differential in individual labor income gaps among men and women.

"Decomps gender" and "Decomps urban gender" are similar, except for the fact that they look at individual labor incomes and restrict the sample based on gender. 

"Figures decomposition" replicates the global and gender figures with all countries.

The "countrycode "adm1"" do files in the "adm1" folders runs the decompositions comparing the leading region with other by administrative regions, as well as the corresponding figure. The corresponding shapefiles (IDs match) are in the "shp"
 folder.


2. Folder structure needed to replicate within in "outputs" should be structured as follows for each country (see COL, ARG examples in the "country outputs/" subfolder)
	countrycode 
		metro
			all
			b40
			gender0
				b40
				rural
				skilled
				urban
			gender1
				b40
				rural
				skilled
				urban
			rural 
			skilled
			urban
		adm1*

*only for Argentina, Brazil, Colombia, Mexico and Peru 

