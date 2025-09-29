
function [latlongrid,indexofgrid,modelsnm,finalids]=cmip_station_match_grid...
    (finalids,finallat,finallon,modelsnm)
%%%%%%%%%%%%%%%%%%%%% match each station with native grid for models
% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% input-------------------------------
% finalids: IDs of stations
% finallat: latitude
% finallon: longtitude
% modelsnm: models' name
% output-------------------------------
% latlongrid: mask of co-located grids for each model
% indexofgrid: the corresponding row, col, latitude, longtitude of grids
% relative to stations
% modelsnm: models' name
% finalids: IDs of stations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lens=length(finalids);
% convert longitude of stations from -180 ~180 to 0~360
jud=finallon<0;
convertlons=finallon(jud)+360;
lons0_360=finallon; lons0_360(jud)=convertlons;

indexofgrid=nan(lens,4,length(modelsnm)); % !mark of corresponding grids each model for each station 
                                          % stations *[row col lat lon] * models
latlongrid=cell(length(modelsnm),1);
path = '/share/cliprelabs/cmip6-ng/pr/day/native';
for im=1:length(modelsnm) 
    imodel=modelsnm{im};
    %%%%%%%%%%%%%%%%%%%%%%% longitude of grid %%%%%%%%%%%%%%%%%%%%%%%%%%%
    olons=ncread([path,'/','pr_day_',imodel,'_historical_r1i1p1f1_native.nc'],'lon');
    lenlon=length(olons);
    reslon=max(diff(olons)); % resolution of longtitude

    if olons(1)==0
       % original longitude records left side of grid
       lons=olons+reslon/2; % conver from left side to the center

    elseif olons(end)==360
          % original longitude records right side of grid
          lons=olons-reslon/2; % conver from right side to the center

    else  % original longitude records the center of grid
         lons=olons;

    end   

    %%%%%%%%%%%%%%%%%%%%% latitude of grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    olats=ncread([path,'/','pr_day_',imodel,'_historical_r1i1p1f1_native.nc'],'lat');
    lenlat=length(olats);  
    reslat=max(diff(olats)); % resolution of latitude
 
    if olats(1)==-90
       % original latitude records the bottom of grid
       lats=olats+reslat/2; % conver from the bottom to the center

    elseif olats(end)==90
          % original latitude records the top of grid
          lats=olats-reslat/2; % conver from the top to the center

    else  % original latitude records the center of grid
         lats=olats;

    end  
    
    [gridlons,gridlats]=meshgrid(lons,lats);
    gridmodel=nan(lenlat, lenlon); % !mark efficient grids for each model(latitude*longitude)

    %%%%%%%%%%%%%%%%%%%% jud according to stations %%%%%%%%%%%%%%%%%%%%%%%%
    for ilens=1:lens % loop by stations
        ilenslat=finallat(ilens,1);
        ilenslon=lons0_360(ilens,1);
        
     for irow=1:lenlat % jud grids of each model
        for icol=1:lenlon
            ilat=gridlats(irow,icol); %latitude of the center of grid
            ilon=gridlons(irow,icol); %longitude of the center of grid
            if abs(ilenslat-ilat)<=reslat/2 && abs(ilenslon-ilon)<=reslon/2 % judge if the station lies in the range of the certain grid
               indexofgrid(ilens,1,im)=irow;
               indexofgrid(ilens,2,im)=icol;
               indexofgrid(ilens,3,im)=ilat;
               indexofgrid(ilens,4,im)=ilon;
               gridmodel(irow,icol)=0;
            break;

            end
        end
     end
       
    end

    latlongrid{im,1}=gridmodel;

% %%%%%%%%%%%%%%%%%%%%%%% match grid mask with grid data %%%%%%%%%%%%%%%%%%%%%%

% figure;
% ax = worldmap('World');
% setm(ax, 'Origin',[0 180 0]);
% load coastlines
% plotm(coastlat,coastlon,'k');
% geoshow(ax, gridlats,gridlons,gridmodel,'DisplayType','texturemap');
% hold on;
% geoshow(ax, finallat, lons0_360,'DisplayType','point','Marker','.',...
%     'MarkerEdgeColor','w'); % looks resonable
% 
end

end