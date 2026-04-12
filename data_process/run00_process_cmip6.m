%% calculate the amount distributions and modes of change for cmip6
% precip distribution for each native grid each year in each ensemble

% 23 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of files for your use.
% You will need to change the epoch length, start year, end year to get
% results for different endpoints and epoch length.


%% check nc info and print in a file
clear
mkdir('cmip6_pr_day_native'); % a folder that contains all cmip6 pr day data
folder='/share/cliprelabs/jh2423/modesofchange_system/cmip6_pr_day_native'; % output folder
experiment={'ssp370','ssp585','ssp126','ssp245'};
nameoffile='cmip6_info';
modelsnm = {'ACCESS-CM2';'ACCESS-ESM1-5';...
    'BCC-CSM2-MR';'CanESM5-1';'CanESM5';'CESM2';...
    'CMCC-CM2-SR5';'CMCC-ESM2';...
    'FGOALS-g3';'GFDL-ESM4';...
    'INM-CM4-8';'INM-CM5-0';...
    'IPSL-CM6A-LR';'MIROC6';...
    'MPI-ESM1-2-LR';'MRI-ESM2-0';'NorESM2-LM';...
    'TaiESM1'};
% notes:AWI-CM-1-1-MR  #no historical
%       CanESM5-1  #no historical
% ICON-ESM-LR  # vertices_latitude? pr dimension: i, time
% 'KACE-1-0-G' # time dimension is not equal to 1955 to 2014
% BCC-ESM1: no ssp
% CESM2-FV2: no ssp
% CMCC-CM2-HR4: no ssp
% E3SM-1-0, E3SM-2-0:no ssp
% 'IITM-ESM': no ssp
% 'KIOST-ESM'; no ssp
% 'NESM3'; no ssp
% 'EC-Earth3';'EC-Earth3-AerChem';'EC-Earth3-Veg': out of memory

% [~]=check_cmip6_info(experiment, ensemble, modelsnm, nameoffile);

%% cal freq distribution and amount distribution for each grid each year

% BINCRATES=nan(200,length(modelsnm),length(experiment),length(ensemble));% all bincrates, 200 is estimated max length of bins
for im=1:length(modelsnm)
    imodel=modelsnm{im};
    for ie=1:length(experiment)
        iex=experiment{ie};
        files=dir(['/share/cliprelabs/cmip6-ng/pr/day/native/pr_day_',...
            imodel,'_',iex,'*.nc']);
        ensemble=1:length(files); %{'r1i1p1f1'};
        switch iex
            case 'historical'
                startyear=1955;
                endyear=2014;
            otherwise
                startyear=2015;
                endyear=2025; % just recent years
        end

        for iensemble=1:length(ensemble)
            thename=files(iensemble).name;
            k = strfind(thename,'_');
            ien=thename(k(4)+1 : k(5)-1); % name of ensemble member
            %                 ien = 'r1i1p1f1';
            % judge if there is already the results
            ans = exist([folder,'/KDE_raindist_',imodel,'_',iex,'_',ien,'_',num2str(startyear),num2str(endyear),'.mat']);
            if ans == 0 % 0 means the variable did not exit
                years=startyear:endyear;
                [pr, lat, lon]=cmip_read_histssp_data(imodel, iex, ien, startyear, endyear); % pr data each model
                [bincrates, binl, dbin, binr]=cmip_bincrates(pr); % bincrates for specific model, specfic experiment, specific ensemble member
                %                 BINCRATES(1:length(bincrates), im, ie, iensemble)=bincrates;
                [rows,cols,~]=size(pr); % 3d data
                freqdist=nan(rows,cols,300,endyear-startyear+1); % 300 is estimated max length of bins
                amountdist=freqdist;
                for irow=1:rows
                    for icol=1:cols

                        for iy=1:(endyear-startyear+1)
                            iyear=years(iy);
                            pdata1=squeeze(pr(irow, icol, :)); % all daily pr in this grid
                            % seperate daily precip series each year
                        [prcp1, ~]=extract_data(pdata1,years,iyear,iyear);
                            % nbin: the smoother, controls the smoothness of distribution for *one* station
                            % mbin: the smoother, controls the smoothness of distribution for *multiple* stations
                            nbin=5;
                            mbin=3;
                            [ppdf1d, pamt1d, ~, ~, ~, ~, ~]=...
                                KDE_makeraindist_i_station(prcp1, prcp1, nbin, mbin);
                            freqdist(irow,icol,1:length(ppdf1d),iy)=ppdf1d;
                            amountdist(irow,icol,1:length(pamt1d),iy)=pamt1d;

                        end

                    end
                end
                save([folder,'/KDE_raindist_',imodel,'_',iex,'_',ien,'_',num2str(startyear),num2str(endyear),'.mat'],...
                    'freqdist','amountdist','bincrates', 'binl','-v7.3');

                imodel
                iex
                ien
            end
        end


    end
end



