function [mapmat,R1,R2,R3,R4,modes,varexp,loading]=regionID(data);

dat=normalizeks(data);
for k = 1:size(dat,4);
    [out1,out2,out3] = eof_outputs(dat(:,:,:,k));
    
    mat = nan(size(out1,1),size(out1,2));
    
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
    modes(:,:,k)=out2; varexp(:,k)=out3;
    loading(:,:,:,k)=out1;
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
