function [evenTS,varTS,richTS,REven,PvalEven,RVar,PvalVar,Rrich,Pvalrich] = RegionChange(regiondata,win,lat,lon,clon,clat);

% Inputs:
% regiondata is a latxlonxyr matrix of the region numbers (e.g. mapmat...)
% win is the length of sliding window you want
% lat and lon are corresponding latitude and longitude arrays
% clon,clat are coast lat lons (load coast).

% Outputs:
% evenTS/varTS/richTS = evenness/variance/richness time series
% REven/Rvar/Rrich = evenness/variance/richness time series correlation coefficients
% PvalEven/PvalVar/Pvalrich = evenness/variance/richness p-values

evenTS=nan(size(regiondata,1),size(regiondata,2),(size(regiondata,3)-win+1));
varTS=nan(size(evenTS));
richTS=nan(size(evenTS));
for i = 1:size(regiondata,1);
    for j = 1:size(regiondata,2);
        dat=squeeze(regiondata(i,j,:));
        numU=sum(~isnan(unique(dat)));
        for z=1:length(dat)-win+1;
            if numU==0;
                evenTS(i,j,z)=NaN;
                varTS(i,j,z)=NaN;
                richTS(i,j,z)=NaN;
            else
                I=~isnan(dat(z:z+win-1));
                tmp=dat(z:z+win-1);
                datnew=tmp(I);
                if isempty(datnew);
                    evenTS(i,j,z)=NaN;
                    varTS(i,j,z)=NaN;
                    richTS(i,j,z)=NaN;
                else
                    numr=sum(~isnan(unique(datnew)));
                    richTS(i,j,z)=numr;
                    varTS(i,j,z)=var(datnew);
                    Un=unique(datnew);
                    for k = 1:length(numU);
                        N=length(datnew); n=nansum(datnew==Un(k));
                        p=n/N; %if we want to be conservative about this, N should be win
                        tmpSh(k)=p.*log(p);
                    end
                    shannon=-1.*nansum(tmpSh);
                    if numU==1;
                        evenTS(i,j,z)=0;
                    else
                    evenTS(i,j,z)=shannon./log(numU); 
                    end
                end
            end
             clear tmpSh Un numr
        end
    end
end

for i = 1:size(regiondata,1);
    for j = 1:size(regiondata,2);
        
        dat=squeeze(evenTS(i,j,:));
        numU=sum(~isnan(unique(dat)));
        if numU==1;
            REven(i,j)=0; PvalEven(i,j)=1;
        else
        [r,p] = corr((1:size(evenTS,3))',squeeze(evenTS(i,j,:)),'rows','pairwise');
        REven(i,j)=r; PvalEven(i,j)=p;
        end
        
        [r,p] = corr((1:size(varTS,3))',squeeze(varTS(i,j,:)),'rows','pairwise');
        RVar(i,j)=r; PvalVar(i,j)=p;
        
        if numU==1;
            Rrich(i,j)=0; Pvalrich(i,j)=1;
        else
        [r,p] = corr((1:size(richTS,3))',squeeze(richTS(i,j,:)),'rows','pairwise');
        Rrich(i,j)=r; Pvalrich(i,j)=p;
        end
    end
end

% Map figure:
figure; 
subplot(3,2,1);
ajpcolor(lon,lat,REven);
colormap(rwb); caxis([-1 1]);
title('Evenness CorrCoeff')
hold on; plot(clon,clat,'k');

subplot(3,2,2);
I=PvalEven<=0.05;
ajpcolor(lon,lat,REven.*I);
colormap(rwb); caxis([-1 1]);
title('Evenness CorrCoeff,p <=0.05')
hold on; plot(clon,clat,'k');

subplot(3,2,3);
ajpcolor(lon,lat,RVar);
colormap(rwb); caxis([-1 1]);
title('Variance CorrCoeff')
hold on; plot(clon,clat,'k');

subplot(3,2,4);
I=PvalVar<=0.05;
ajpcolor(lon,lat,RVar.*I);
colormap(rwb); caxis([-1 1]);
title('Variance CorrCoeff,p <=0.05')
hold on; plot(clon,clat,'k');

subplot(3,2,5);
ajpcolor(lon,lat,Rrich);
colormap(rwb); caxis([-1 1]);
title('Richness CorrCoeff')
hold on; plot(clon,clat,'k');

subplot(3,2,6);
I=Pvalrich<=0.05;
ajpcolor(lon,lat,Rrich.*I);
colormap(rwb); caxis([-1 1]);
title('Richness CorrCoeff,p <=0.05')
hold on; plot(clon,clat,'k');
