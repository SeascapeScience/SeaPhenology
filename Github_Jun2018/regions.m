function [mapmat,R1,R2,R3,R4]=regions(data,out1);
% This function categorizes each pixel based upon its spatial loading in
% the EOF (represented in out1).

%Inputs: 
% data is chlorophyll data; NOTE, NOT THE NORMALIZED DATA
% out1 is the EOF spational loading data (3-D).

%Outputs:
% mapmat is a map of region assignments
% R# is the chlorophyll data for each region (1 through 4).

for k = 1:size(data,4);
    
    mat = nan(size(data,1),size(data,2));
    
    for i = 1:size(out1,1);
        for j = 1:size(out1,2);
            
            I = out1(:,:,1) > 0 & out1(:,:,2) > 0; %positive, positive
            mat(I) = 4;
            
            I = out1(:,:,1) > 0 & out1(:,:,2) < 0; %positive, negative
            mat(I) = 3;
            
            I = out1(:,:,1) < 0 & out1(:,:,2) > 0; %negative, positive
            mat(I) = 2;
            
            I = out1(:,:,1) < 0 & out1(:,:,2) < 0; %negative, negative
            mat(I) = 1;
        end
    end
    mapmat(:,:,k)=mat;
end


for j = 1:size(data,3);
    I1=mapmat==1;
    R1(:,:,j,:)=squeeze(data(:,:,j,:)).*I1;
    I2=mapmat==2;
    R2(:,:,j,:)=squeeze(data(:,:,j,:)).*I2;
    I3=mapmat==3;
    R3(:,:,j,:)=squeeze(data(:,:,j,:)).*I3;
    I4=mapmat==4;
    R4(:,:,j,:)=squeeze(data(:,:,j,:)).*I4;
end
I=R1==0; R1(I)=NaN;
I=R2==0; R2(I)=NaN;
I=R3==0; R3(I)=NaN;
I=R4==0; R4(I)=NaN;
