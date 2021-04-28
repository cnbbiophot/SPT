function [ particleNoZeros ] = zero_remover(particleData,fileName)

%remove from the vector particles all lines that are only zeros
%INPUT: 
%particleData: a cell array with |number of molecules x 1| where each cell
%has the datsa for a molecule in all frames where the columns are: frame
%number:time in ms:position x (nm): position y in nm:intensity (ADC): PSF x
%(nm): PSF y (nm): background 

%OUTPUT: 
%particleDataFiltered: particleData as with no zeros

%Created by: CVS
%On March, 2019

nParticles=size(particleData,1);
particleNoZeros=particleData;

for n=1:nParticles
    m=1;
    nfram=size(particleData{n,1},1);
    while m<=nfram  
        if (particleNoZeros{n,1}(m,4)==0) && (particleNoZeros{n,1}(m,5)==0)
           particleNoZeros{n,1}(m,:)=[];
           nfram=nfram-1;
        else
           m=m+1;
        end
    end
end

save (fileName,'particleNoZeros','-v7.3','-append')



end
  