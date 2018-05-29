Chlorophyll a phenology work flow – Identifying the regions:

1) Load interpolated (DINEOF) chlorophyll a data and metadata
load('MODAtl1degInterp.mat')
2) Change format to a 4-D matrix: lat-x-lon-x-365days-x-#years
- Do this with smoothingwork.m
- Here I have used a 7 day window for the moving average (14 d moving average) and no spatial smoothing

[MAT,MAT_movav] = smoothingwork(MOD1deg,t,lat,...
   	 lon,0,5,7);

NOTE: For SeaWiFS data, we are using years 1998-2002. For MODIS data we are using 2003-2016. This is a good time to trim the data to fit that.
data=MAT_movav(:,:,:,2:end-1);


**

3) Normalize the data
- done with normalizeks.m
- using the data you want (MAT_movav has the moving average; MAT does not)
- this function can be changed to normalize over different dimensions (i.e. year, pixel); it is currently set to normalize each pixel and year separately.
[matnorm] = normalizeks(data);

4) Perform EOF
- use eof_outputs.m to get eof maps, principal components (time series) and the variance explained by each component
- the input variable can be 3- or 4-dimensional: lat lon time, or lat lon day year
[out1,out2,out3] = eof_outputs(matnorm);

Outputs:
out1 - EOF maps: lat x lon x mode (x year)
out2 - principal component time series: mode x time (x year or percent if doing cumulative sum)
out3 - variance explained: mode (x year)

5) Identify regions using regions.m
	[mapmat,R1,R2,R3,R4]=regions(data,out1);

**6) The following can be used for steps 3-5 if you do not need all the outputs
-	use regionID.m; 

[mapmat,R1,R2,R3,R4,modes,varexp,loading]=regionID(data);

7) Now you can calculate the center of mass for the different regions,…
[datnew,latnew,lonnew,CoM] = RegionCoMInfo2(R1,lat,lon,[30 max(lat),min(lon),max(lon)],1,364);

8) …the “diversity” metrics of the regions…
[shannon,simpson,even,richness] = ShannonRegion(mapmat,lat,lon);

9) …and the change in these “diversity” metrics:
[evenTS,varTS,richTS,REven,PvalEven,RVar,PvalVar,Rrich,Pvalrich] = RegionChange(mapmat,4,lat,lon,clon,clat);
 - NOTE: you must load coast and name clon, clat for the coast data; and be sure not to overwrite your chl a data lat 


***********************************************************************



