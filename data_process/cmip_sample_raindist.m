function [freqmodelsample,amountmodelsample,modelsnm,BINCRATES]=cmip_sample_raindist...
    (finalids,indexofgrid,cmip6folder,method,modelsnm,experiment,ensemble,sy,ey)
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
%%%%%%%%%%%% generate model samples for freq and amount distribution
%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% finalids:the ids of stations
% indexofgrid: the corresponding rows and cols for each model relative to stations
% cmip6folder: folder of freq and amount dist for each grid each model each year
% method: method used to cal rain distribution (e.g. ks, old)
% modelsnm: models name
% experiment: historical simulation extended with ssps (e.g. {'historical';'ssp370'})
% ensemble: ensemble member
% sy: model rain dist start year (extend with ssp)
% ey: end year of model rain distribution (extend with ssp)
%%%%%%%%%%%%%%%%%% output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% freqmodelsample: freq distribution samples (lens,length(modelsnm),length(BINCRATES),ey-sy+1)
% amountmodelsample: amount distribution samples
% modelsnm: models name
% BINCRATES: final bincrates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lens=length(finalids);
BINCRATES=[];
% find longest bincrates among models and among experiments
for im=1:length(modelsnm)
    imodel=modelsnm{im};
    imodel_ensemble=ensemble{im,1};
    for ien=1: length(imodel_ensemble)
        iensemble=imodel_ensemble{ien,1};
    load([cmip6folder,'/',method,'_raindist_',imodel,'_','historical','_',iensemble,'_19552014.mat'],'bincrates'); 
    histbin=bincrates;
    load([cmip6folder,'/',method,'_raindist_',imodel,'_',experiment,'_',iensemble,'_20152025.mat'],'bincrates'); % ssp
        if length(histbin) > length(bincrates) % find longest bincrates among experiments
            bincrates=histbin;
        end
    
        if length(bincrates) > length(BINCRATES) % find longest bincrates among models
            BINCRATES=bincrates;
        end 
    end
end
freqmodelsample=nan(lens,length(modelsnm),length(BINCRATES),ey-sy+1); % capacity of the sample
amountmodelsample=freqmodelsample;
for im=1:length(modelsnm)  
    imodel=modelsnm{im};
    imodel_ensemble=ensemble{im,1};
    freqensem=nan(lens,length(imodel_ensemble),length(BINCRATES),ey-sy+1); % capacity of the sample
    amountensem=freqensem;

    for ien=1: length(imodel_ensemble)
        iensemble=imodel_ensemble{ien,1};
    load([cmip6folder,'/',method,'_raindist_',imodel,'_','historical','_',iensemble,'_19552014.mat'],...
        'amountdist','freqdist');  
    histamount=amountdist;
    histfreq=freqdist;
    load([cmip6folder,'/',method,'_raindist_',imodel,'_',experiment,'_',iensemble,'_20152025.mat'],...
        'amountdist','freqdist'); % ssp  

       for ista=1:lens
           irow=indexofgrid(ista,1,im);
           icol=indexofgrid(ista,2,im);

           % cutoff to the longest bincrates
           hist_thefreq=histfreq(irow,icol,1:length(BINCRATES),:);
           ssp_thefreq=freqdist(irow,icol,1:length(BINCRATES),:);
           % merge historical simulations and ssp
           thefreqdist=cat(4,hist_thefreq, ssp_thefreq);
           thefreqdist(isnan(thefreqdist))=0;
           freqensem(ista,ien,:,:)=thefreqdist;

           hist_theamount=histamount(irow,icol,1:length(BINCRATES),:);
           ssp_theamount=amountdist(irow,icol,1:length(BINCRATES),:);
           theamountdist=cat(4,hist_theamount,ssp_theamount);
           theamountdist(isnan(theamountdist))=0;
           amountensem(ista,ien,:,:)=theamountdist; 
       end

    end
       freqmodelsample(:,im,:,:)=nanmean(freqensem,2);
       amountmodelsample(:,im,:,:)=nanmean(amountensem,2);
       clear amountdist freqdist

end

end