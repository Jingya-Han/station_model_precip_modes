function [MMMppdf1,MMMpamt1,MMMppdf2,MMMpamt2,...
    gridppdf1,gridppdf2,gridpamt1,gridpamt2]=cmip_MMMraindistp1p2(freqmodelsample,amountmodelsample,years,period1,period2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%%%%%%%
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% years: models start year to end year
% freqmodelsample: freq distribution samples (lens,length(modelsnm),length(BINCRATES),ey-sy+1)
% amountmodelsample: amount distribution samples
%%%%%%%%%%%%%%%%%% output %%%%%%%%%%%%%%%%%%%%
% MMMppdf1:


% freq and amount dist for period1 and period2 for all models
srow=find(years==period1(1));
erow=find(years==period1(end));
ksmodelppdf1=mean(freqmodelsample(:,:,:,srow:erow),4);
ksmodelpamt1=mean(amountmodelsample(:,:,:,srow:erow),4);

srow=find(years==period2(1));
erow=find(years==period2(end));
ksmodelppdf2=mean(freqmodelsample(:,:,:,srow:erow),4);
ksmodelpamt2=mean(amountmodelsample(:,:,:,srow:erow),4);

% mean across all co-located grids
mppdf1=mean(ksmodelppdf1,1);
mppdf2=mean(ksmodelppdf2,1);
mpamt1=mean(ksmodelpamt1,1);
mpamt2=mean(ksmodelpamt2,1);

% MMM of freq and amount dist for period1 and period2
MMMppdf1=mean(mppdf1,2);  MMMppdf1=squeeze(MMMppdf1);
MMMppdf2=mean(mppdf2,2);  MMMppdf2=squeeze(MMMppdf2);
MMMpamt1=mean(mpamt1,2);  MMMpamt1=squeeze(MMMpamt1);
MMMpamt2=mean(mpamt2,2);  MMMpamt2=squeeze(MMMpamt2);

% MMM of spatial pattern of rain distributions
gridppdf1=mean(ksmodelppdf1,2); gridppdf1=squeeze(gridppdf1);
gridppdf2=mean(ksmodelppdf2,2); gridppdf2=squeeze(gridppdf2);
gridpamt1=mean(ksmodelpamt1,2); gridpamt1=squeeze(gridpamt1);
gridpamt2=mean(ksmodelpamt2,2); gridpamt2=squeeze(gridpamt2);

end