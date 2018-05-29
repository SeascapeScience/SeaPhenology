function [matnorm] = normalizeks(mat)
% normalize data in mat

% normalizes all the data together:
%matnorm=(mat-nanmean(mat(:)))./nanstd(mat(:));

% normalizes each pixel separately, but all years together:
% for i = 1:size(mat,1);
%     for j = 1:size(mat,2);
%             tmp=squeeze(mat(i,j,:,:));
%             matnorm(i,j,:,:)=(tmp-nanmean(tmp(:)))./nanstd(tmp(:));
%     end
% end

% normalizes eaceh pixel and year separately:
for i = 1:size(mat,1);
    for j = 1:size(mat,2);
        for k = 1:size(mat,4);
            tmp=squeeze(mat(i,j,:,k));
            matnorm(i,j,:,k)=(tmp-nanmean(tmp))./nanstd(tmp);
        end
    end
end