function [datnew,latnew,lonnew,CoM] = RegionCoMInfo2(dat,lat,lon,bb,yearstartday,wind);
% This function returns the appropriate centers of mass for each region,
% considering their seasonal cycles.

% INPUTS:
% dat is chlorophyll data for the region you are interested in;
% dat should be lat x lon x 365d x #years
% lat and lon should match the first two dimensions of dat
% bb is a 1x4 bounding box array as such: [minlat, maxlat, minlon, maxlon].
% yearstartday is a 1x1 array of the day that you want to use as your start
% day when calculating CoM. Often the climatological minimum for the
% region.
% wind is the window of time to consider (365 for the full year).

% OUTPUTS:
% datnew is the chlorophyll data trimmed to your bounding box
% latnew and lonnew are the new lat and lon matrices for plotting your data
% CoM is the chl a Center of Mass

%un-log the data
dat=10.^dat;

if nargin==5;
    bb = [min(lat),max(lat),min(lon),max(lon)];
end

% get indices for lat and lon based on bb:
% lat:
a = find(lat>=bb(1)); latmin = a(end);
b = find(lat<=bb(2)); latmax = b(1);
latnew=lat(latmax:latmin);

%lon:
c = find(lon>=bb(3)); lonmin = c(1);
d = find(lon<=bb(4)); lonmax = d(end);
lonnew=lon(lonmin:lonmax);

datnew = dat(latmax:latmin,lonmin:lonmax,:,:); % chlorophyll data from inside bb

dattmp=nan(size(datnew));

if yearstartday==1 || wind==365-yearstartday;
for i = 1:size(datnew,1);
    for j = 1:size(datnew,2);
        for k = 1:size(datnew,4);
            x(1:length(yearstartday:365))=datnew(i,j,yearstartday:365,k);
            x(length(yearstartday:365)+1:365)=datnew(i,j,1:yearstartday-1,k);
            if sum(isnan(x))==0
                dattmp(i,j,:,k)=x;
            else
                dattmp(i,j,length(yearstartday:365)+1:365,k)=nan;
            end
            
            
        end
    end
end
datnew=dattmp; 
else

for i = 1:size(datnew,1);
    for j = 1:size(datnew,2);
        for k = 1:size(datnew,4)-1;
            x(1:length(yearstartday:365))=datnew(i,j,yearstartday:365,k);
            x(length(yearstartday:365)+1:365)=datnew(i,j,1:yearstartday-1,k+1);
            if sum(isnan(x))==0
                dattmp(i,j,:,k)=x;
            else
                dattmp(i,j,length(yearstartday:365)+1:365,k)=nan;
            end
           
            
        end
    end
end
datnew=dattmp; 
end

[CoM,~] = metric3inv(datnew,[1 wind]); 

    

