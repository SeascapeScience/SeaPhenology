function [MAT,MAT_movav] = smoothingwork(dat,allTimeMat,latSub,...
    lonSub,spatial_smoothing_pref,kern,movavwindow);
% Inputs:
%   - dat: a m-by-n-by-z, lat-by-lon-by-day, matrix of chl data; can be log transformed;
%     data processed in dineof are already in log-10 space.
%   - allTimeMat: a datetime formatted matrix, z-by-1 
%   - latSub, lonSub: latitude and longitude in decimal degrees, m-by-1 and
%     n-by-1 respecively, needed only if the spline data are calculated
%   - sptial_smoothing_pref: 0 if you do not want any spatial smoothing; 1 if
%     you want median filter for spatial smoothing; if dineof has been
%     applied this is not necessary and will automatically be a zero.
%   - kern: spatial smoothing kernel (number of cells around for median-ing?).
%     If spatial_smoothing_pref is 0 this can be anything.
%   - movavwindow: window used for the moving average; I use 7, which gives
%     a 2-week moving average (7 days on either side). OR 4 d for 8-day.
% Outputs:
%   - MAT: a m-by-n-by-365-by-year matrix of spatially smoothed data; median
%     filter applied twice if spatial_smoothing_pref == 1;
%   - MAT_movav: same as above with a moving average of 2*movavwindow
%     applied

        

% spatial smoothing with a median filter
if spatial_smoothing_pref==1;
    for i = 1:size(dat,3);
        M = mediannan(squeeze(dat(:,:,i)),kern); % can change kernel size here.
        dat_mod1(:,:,i) = M;
        
        %do it again:
        M = mediannan(squeeze(dat_mod1(:,:,i)),kern); % can change kernel size here.
        dat_mod2(:,:,i) = M;
    end
    dat_new = dat_mod2;
else
    dat_new = dat;
end

tm=allTimeMat;
% get rid of leap year extra day:
[y,m,d] = ymd(tm);
v = [m,d];
I = find(v(:,1)==2 & v(:,2)==29);
for i = 1:length(I);
    tmp = cat(3,dat_new(:,:,I(i)),dat_new(:,:,I(i)-1));
    tmp = mean(tmp,3);
    dat_new(:,:,I(i))=tmp;
end
dat_new(:,:,I)=[];
tm(I) = [];

[y] = ymd(tm);
yr = min(y):max(y);
jd = day(tm,'dayofyear');

% resize spatially smoothed data to be lat x lon x 365(days) x year
MAT = nan(size(dat_new,1),size(dat_new,2),365,length(yr));
for i = 1:size(dat_new,1);
    for j = 1:size(dat_new,2);
        mat = nan(365,length(yr));
        for k = 1:length(yr);
            K = y==yr(k); 
            if sum(K)==365;
                mat(:,k) = squeeze(dat_new(i,j,K));
            else
            mat(1:length(jd(K)),k) = squeeze(dat_new(i,j,K));
            %could add simple spline for filling in NaNs.
            end
        end
        MAT(i,j,:,:) = mat;
    end
end

% get moving average
MAT_movav = nan(size(MAT));

for i = 1:size(MAT,1);
    for j = 1:size(MAT,2);
        for k = 1:size(MAT,4);
            if k==1 || k==yr(end);
                t1 = squeeze(MAT(i,j,:,k)); %365 days of data
                pretmp = squeeze(nanmean(MAT(i,j,end-movavwindow:end,:),4)); %cushion from previous year
                posttmp = squeeze(nanmean((MAT(i,j,1:1+movavwindow,:)),4)); % cushion from next year
                tmp = [pretmp;t1;posttmp];
                [Y,~] = nanmoving_average(tmp,movavwindow,1,1);
                MAT_movav(i,j,:,k) = Y(movavwindow+1:movavwindow+365);
            else
                t1 = squeeze(MAT(i,j,:,k)); %365 days of data
                pretmp = squeeze(nanmean(MAT(i,j,end-movavwindow:end,:),4)); %cushion from previous year
                posttmp = squeeze(nanmean((MAT(i,j,1:1+movavwindow,:)),4)); % cushion from next year
                tmp = [pretmp;t1;posttmp];
                [Y,~] = nanmoving_average(tmp,movavwindow,1,1);
                MAT_movav(i,j,:,k) = Y(movavwindow+1:movavwindow+365);
            end
        end
    end
end

% THE FOLLOWING CODE FITS A SPLINE TO THE DATA - NOT GENERALLY USED.
% %smoothing AJP spline:
% warning('off','SPLINES:CHCKXYWP:NaNs');
% MAT_spl = nan(size(MAT_movav));
% for i = 1:size(MAT_movav,1);
%     for j = 1:size(MAT_movav,2);
%         for k = 1:size(MAT_movav,4);
%             y = repmat(yr(k),365,1);
%             la = repmat(latSub(i),365,1); lo = repmat(lonSub(i),365,1);
%             dat = [y,(1:365)',la,lo,squeeze(MAT_movav(i,j,:,k))];
%             if sum(isnan(dat(:,5))) == 365; MAT_spl(i,j,:,k) = NaN;
%             else [~,~,sp]=AJPspline(dat,12,1);
%                 MAT_spl(i,j,:,k) = fnval(sp,1:365);
%             end
%         end
%     end
% end

% % non-smoothing cubic spline interpolation of missing days:
% MAT_spl = nan(size(MAT_movav));
% for i = 1:size(MAT_movav,1);
%     for j = 1:size(MAT_movav,2);
%         for k = 1:size(MAT_movav,4);
%             K1 = find(isnan(MAT_movav(i,j,:,k)));
%             if length(K1)==365;
%                 MAT_spl(i,j,:,k)=nan(1,365);
%             else
%             K2 = find(~isnan(MAT_movav(i,j,:,k)));
%             MAT_spl(i,j,:,k) = spline(K2,MAT_movav(i,j,K2,k),1:365);
%             end
%         end
%     end
% end


