function [ensemble]=cmip_existensembles(selectedmodels,iex)
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% detect available ensemble members for both historical simulations and one
% ssp over all models
% input--------------------------------------------------------------------
% selectedmodels: name of models used in study
% iex: name of experiments:'ssp370','ssp585','ssp126','ssp245'
% output-------------------------------------------------------------------
% available ensemble members for each model

ensemble = cell(length(selectedmodels),1);
 
switch iex

    case {'ssp370','ssp585','ssp126','ssp245'}
folder='/share/cliprelabs/jh2423/modesofchange_system/cmip6_pr_day_native/';
for im=1:length(selectedmodels)
    imodel=selectedmodels{im};
    files=dir(['/share/cliprelabs/cmip6-ng/pr/day/native/pr_day_',...
            imodel,'_','historical','*.nc']); % all members for historical for imodel
    members=1:length(files);
    nameofmem=cell(1,1);
    count=0;
    for iensemble=1:length(members)
        thename=files(iensemble).name;
        k = strfind(thename,'_');
        ien=thename(k(4)+1 : k(5)-1); % name of ensemble member
        %judge if the member in historcial exist or not
        answ = exist([folder,'KDE_raindist_',imodel,'_','historical','_',ien,'_','19552014','.mat']);
        %judge if the member in ssp exist or not
        answ2 = exist([folder,'KDE_raindist_',imodel,'_',iex,'_',ien,'_','20152025','.mat']);       
        if answ~=0 && answ2~=0 % meaning both exist
            count=count+1;
           nameofmem{count,1}=ien;
            
        end
     end
     ensemble{im,1} = nameofmem;     
               
end

    case 'amip'
prfolder='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/';  
tasfolder='/share/cliprelabs/jh2423/modesofchange_system/amip_pr_day/';
for im=1:length(selectedmodels)
    imodel=selectedmodels{im};
    files=dir([prfolder,'pr_day_',...
            imodel,'_','amip','*.mat']); % all members for historical for imodel
    members=1:length(files);
    nameofmem=[];
    count=0;
    for iensemble=1:length(members)
        thename=files(iensemble).name;
        k = strfind(thename,'_');
        ien=thename(k(end-2)+1 : k(end-1)-1); % name of ensemble member
        %judge of the member for amip ann temp exist or not
        answ = dir([tasfolder,'tas_Amon_',imodel,'_amip_',ien,'*.mat']);
        if ~isempty(answ)
           count=count+1;
           nameofmem{count,1}=ien;
        else
            nameofmem=[];
        end
             
    end
        ensemble{im,1} = nameofmem;


            

end



end
end