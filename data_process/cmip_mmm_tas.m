function [meanT, mmmT]=cmip_mmm_tas(selectedmodels,experiment, ensemble,period1,period2)
%%%%%%%%%%%%%%%%%%%% input %%%%%%%%%%%%%%
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% path: path of cmip6 tas ann data
% selectedmodels: name of selected models
% experiment: historical simulation extended with ssps (e.g. {'historical';'ssp370'})
% ensemble: ensemble member
% period1
% period2

%%%%%%%%%%%%%%%%%%% output %%%%%%%%%%%%%%
% meanT: mean tas for period1 and period2 in each model each ensemble member
% mmmT:mmm of meanT during period 1 and 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


meanT=cell(length(selectedmodels), 1);
mmmT=nan(length(selectedmodels), 2); % mmm of meanT during period 1 and 2

switch experiment

     case {'historical', 'ssp370','ssp585','ssp126','ssp245'}

path='/share/cliprelabs/cmip6-ng/tas/ann/native/';

   for im=1:length(selectedmodels)
    imodel=selectedmodels{im};
    imodel_ensemble=ensemble{im,1};
    meanT_ensemble=nan(length(imodel_ensemble),2); % mean T in period1 and period2 for each member 

    for ien=1: length(imodel_ensemble)
        iensemble=imodel_ensemble{ien,1};
        %judge if the member in historcial exist or not
        answ = exist([path,'tas_ann_',imodel,'_','historical','_',iensemble,'_native.nc']);
        %judge if the member in ssp exist or not
        answ2 = exist([path,'tas_ann_',imodel,'_',experiment,'_',iensemble,'_native.nc']);       
        if answ~=0 && answ2~=0 % meaning both exist      
        histtas=ncread([path,'tas_ann_',imodel,'_','historical','_',iensemble,'_native.nc'],'tas'); % unit: K, tas for historical simu
        ssptas=ncread([path,'tas_ann_',imodel,'_',experiment,'_',iensemble,'_native.nc'],'tas'); % unit: K, tas for ssp
        tas=cat(3,histtas,ssptas); % merge historical simu and ssp
        time=(1850:2100)';

        judtas=ismember(time,period1(:)); % judge the years for period1
        subtas=tas(:,:,judtas);
        taseries1=nan(length(period1), 1);
        for iy=1:length(period1)
            iytas=subtas(:,:,iy);
            taseries1(iy,1)=nanmean(iytas(:));
        end
            meanT1=nanmean(taseries1);

        judtas=ismember(time,period2(:)); % judge the years for period2
        subtas=tas(:,:,judtas);
        taseries2=nan(length(period2), 1);
        for iy=1:length(period2)
            iytas=subtas(:,:,iy);
            taseries2(iy,1)=nanmean(iytas(:));    
        end
            meanT2=nanmean(taseries2);

      meanT_ensemble(ien,1)=meanT1;
      meanT_ensemble(ien,2)=meanT2;

        end
    end
    meanT{im,1}=meanT_ensemble;
    mmmT(im,:)=nanmean(meanT_ensemble,1);
   end

    case 'amip'

   path='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/';
   for im=1:length(selectedmodels)
    imodel=selectedmodels{im};
    imodel_ensemble=ensemble{im,1};
    meanT_ensemble=nan(length(imodel_ensemble),2); % mean T in period1 and period2 for each member 

    for ien=1: length(imodel_ensemble)
        iensemble=imodel_ensemble{ien,1}; 
        file=dir([path,'tas_ann_',imodel,'_',experiment,'_',iensemble,'*.mat']);
        if ~isempty(file)
            thename=file(1).name;
            load([path,thename],...
            'annMeanTemp','startyear','endyear'); % unit: K, tas for historical simu        
            time=(startyear:endyear)';

            judtas=ismember(time,period1(:)); % judge the years for period1
            subtas=annMeanTemp(judtas,:);
            meanT1=nanmean(subtas);

            judtas=ismember(time,period2(:)); % judge the years for period2
            subtas=annMeanTemp(judtas,:);
            meanT2=nanmean(subtas);

        meanT_ensemble(ien,1)=meanT1;
        meanT_ensemble(ien,2)=meanT2;

        end
    end
    meanT{im,1}=meanT_ensemble;
    mmmT(im,:)=nanmean(meanT_ensemble,1);
   end   




end
end