% rain distributions for each model each ensemble member in period 1 and 2
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu

function [modelsampleraindist,BINCRATES]=cmip_im_ien_raindist(indexofgrid,cmip6folder,method,modelsnm,...
    experiment,ensemble,sy,ey,period1,period2)

lens=length(indexofgrid);
BINCRATES=[];
% find longest bincrates among models and among experiments
for im=1:length(modelsnm)
    imodel=modelsnm{im};
    imodel_ensemble=ensemble{im,1};
    for ien=1: length(imodel_ensemble)
        iensemble=imodel_ensemble{ien,1};
        switch experiment
     case {'historical', 'ssp370','ssp585','ssp126','ssp245'}
    load([cmip6folder,method,'_raindist_',imodel,'_','historical','_',iensemble,'_19552014.mat'],'bincrates'); 
    histbin=bincrates;
    load([cmip6folder,method,'_raindist_',imodel,'_',experiment,'_',iensemble,'_20152025.mat'],'bincrates'); % ssp
        if length(histbin) > length(bincrates) % find longest bincrates among experiments
            bincrates=histbin;
        end
    
        if length(bincrates) > length(BINCRATES) % find longest bincrates among models
            BINCRATES=bincrates;
        end 
      case 'amip'
    files=dir([cmip6folder,'amip_',method,'_raindist_',imodel,'_',experiment,'_',iensemble,'*.mat']);  
    if ~isempty(files)
    thename=files(1).name;
    load([cmip6folder,thename],'bincrates');
    if length(bincrates) > length(BINCRATES) % find longest bincrates among models
            BINCRATES=bincrates;
    end 
    end
        end
    end
end

modelsampleraindist=cell(length(modelsnm),1); % rain dist of period1,2 for each model each ensemble

for im=1:length(modelsnm)  
    imodel=modelsnm{im};
    imodel_ensemble=ensemble{im,1};
    freqensem=nan(lens,length(imodel_ensemble),length(BINCRATES),ey-sy+1); % capacity of the sample
    amountensem=freqensem;
    for ien=1: length(imodel_ensemble)
        iensemble=imodel_ensemble{ien,1};
         switch experiment
     case {'historical','ssp370','ssp585','ssp126','ssp245'}
    load([cmip6folder,method,'_raindist_',imodel,'_','historical','_',iensemble,'_19552014.mat'],...
        'amountdist','freqdist');  
    histamount=amountdist;
    histfreq=freqdist;
    load([cmip6folder,method,'_raindist_',imodel,'_',experiment,'_',iensemble,'_20152025.mat'],...
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
           freqensem(ista,ien,:,:)=thefreqdist; %freq distribution for each member each year
           hist_theamount=histamount(irow,icol,1:length(BINCRATES),:);
           ssp_theamount=amountdist(irow,icol,1:length(BINCRATES),:);
           theamountdist=cat(4,hist_theamount,ssp_theamount);
           theamountdist(isnan(theamountdist))=0;
           amountensem(ista,ien,:,:)=theamountdist; %amount distribution for each member each year
       end
      case 'amip'
    files=dir([cmip6folder,'amip_',method,'_raindist_',imodel,'_',experiment,'_',iensemble,'*.mat']);  
    if ~isempty(files)
    thename=files(1).name;
    load([cmip6folder,thename],'freqdist','amountdist');
    amipey=str2double(thename(end-7:end-4)); % end year for this member
    amipsy=str2double(thename(end-11:end-8));% start year for this member      
    amipyrs=amipsy:amipey;
    years=sy:ey;
    jud=ismember(amipyrs,years);
    freqdist=freqdist(:,:,:,jud);
    amountdist=amountdist(:,:,:,jud);
           for ista=1:lens
           irow=indexofgrid(ista,1,im);
           icol=indexofgrid(ista,2,im);

           % cutoff to the longest bincrates
           thefreqdist=freqdist(irow,icol,1:length(BINCRATES),:);
           thefreqdist(isnan(thefreqdist))=0;
           freqensem(ista,ien,:,:)=thefreqdist; %freq distribution for each member each year
           theamountdist=amountdist(irow,icol,1:length(BINCRATES),:);
           theamountdist(isnan(theamountdist))=0;
           amountensem(ista,ien,:,:)=theamountdist; %amount distribution for each member each year
           end
    end

         end

    end
% mean across all co-located grids
freqstamean=(mean(freqensem,1));
amountstamean=(mean(amountensem,1));

% freq and amount dist for period1 and period2 for all models
years=sy:ey;
srow=find(years==period1(1));
erow=find(years==period1(end));
imraindist=zeros(length(imodel_ensemble),length(BINCRATES),4); % 3rd dimension: ppdf1,ppdf2,pamt1,pamt2
imraindist(:,:,1)=squeeze(mean(freqstamean(:,:,:,srow:erow),4)); % ppdf1
imraindist(:,:,3)=squeeze(mean(amountstamean(:,:,:,srow:erow),4)); % pamt1
srow=find(years==period2(1));
erow=find(years==period2(end));
imraindist(:,:,2)=squeeze(mean(freqstamean(:,:,:,srow:erow),4)); % ppdf2
imraindist(:,:,4)=squeeze(mean(amountstamean(:,:,:,srow:erow),4)); % pamt2

modelsampleraindist{im,1}=imraindist;
end


end