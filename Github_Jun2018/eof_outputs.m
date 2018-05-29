function [out1,out2,out3] = eof_outputs(metmatnorm);
% performs eof of a normalized dataset. 

% Inputs:
% metmatnorm can be 3-dim or 4-dim: lat x lon x time, or lat x lon x day x year
    % if it is 4-dim, a separate EOF is done for each year.
    
% Outputs:
% out1 - EOF maps: lat x lon x mode (x year or cumulative percent if doing cumul. sum)
% out2 - principal component time series: mode x time (x year)
% out3 - variance explained: mode (x year)
    
if length(size(metmatnorm))==4;
    for i = 1:size(metmatnorm,4);
        A = metmatnorm(:,:,:,i);
        [eof_maps,pc,expvar] = eof(A);
        out1(:,:,:,i) = eof_maps;
        out2(:,:,i) = pc;
        out3(:,i) = expvar;
        clear A;
    end
else
    A = metmatnorm;
    [eof_maps,pc,expvar] = eof(A);
    out1 = eof_maps;
    out2 = pc;
    out3 = expvar;
end