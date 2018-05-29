function [shannon,simpson,even,richness] = ShannonRegion(regiondata,lat,lon);

% Inputs:
% regiondata is a latxlonxyr matrix of the region numbers (e.g. mapmat...)
% lat and lon are correspoding latitude and longitude arrays

% Outputs:
% shannon is Shannon's diversity index
% simpson is Simpson's diversity index
% even is the evenness of region representation in a pixel
% richness is the number of regions represented in a pixel over the time
% series.

for i = 1:size(regiondata,1);
    for j = 1:size(regiondata,2);
        dat=squeeze(regiondata(i,j,:));
        numU=sum(~isnan(unique(dat)));
        if numU==0;
            richness(i,j)=NaN;
            shannon(i,j)=NaN;
            simpson(i,j)=NaN;
            even(i,j)=NaN;
        else
            richness(i,j)=numU;
            
            I=~isnan(dat);
            datnew=dat(I);
            Un=unique(datnew);
            for k = 1:numU;
                N=length(datnew); n=sum(datnew==Un(k));
                p=n/N;
                tmpSh(k)=p.*log(p);
                tmpSi(k)=p.^2;
            end
            shannon(i,j)=-1.*sum(tmpSh);
            simpson(i,j)=1./(sum(tmpSi));
            if numU==1;
                even(i,j)=0;
            else
            even(i,j)=shannon(i,j)./log(numU);
            end
        end
        clear tmpSh tmpSi Un 
    end
end
%Z=isnan(even); even(Z)=0;

% 2x2 figure:

figure;
subplot(2,2,1);
hShH=ajpcolor(lon,lat,shannon);
colorbar;
title('Shannon H');

subplot(2,2,2);
hSiD=ajpcolor(lon,lat,simpson);
colorbar;
title('Simpson D');

subplot(2,2,3);
hev=ajpcolor(lon,lat,even);
colorbar;
title('Region evenness');

subplot(2,2,4);
hri=ajpcolor(lon,lat,richness);
colorbar;
title('Region richness');

