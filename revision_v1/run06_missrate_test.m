%% Sensitivity of the station network to the completeness criterion
% Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
%
% The analysis retains a station only if at most missrate% of the years in
% each epoch are classified as missing, where a year is missing when more
% than missrate% of its days are absent.
%
% This script compares missrate = 10%, 20%, and 30%, and diagnoses where
% the additional stations are located when the criterion is relaxed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc
addpath('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\')

prfolder  = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\data_process\ghcnd_pr\';
outfolder = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\';
if ~exist(outfolder,'dir'); mkdir(outfolder); end

thelength = 30;
startyear = 1955;
endyear   = 2023;

period1 = startyear:(startyear+thelength-1);
period2 = (endyear-thelength+1):endyear;

rates = [10 20 30];

% Science Advances figure standards
fn = 'Arial';
fs = 8;
fsp = 9;

%% Load raw station data
load([prfolder,'reo_ghcnddailydata_',num2str(startyear),num2str(endyear),'.mat'], ...
    'ghcndprcp','ghcnids','ghcnlats','ghcnlons','years');

fprintf('%d stations before the completeness criterion\n\n',numel(ghcnids));

% Normalize longitude to -180 to 180 if necessary
ghcnlons = double(ghcnlons);
ghcnlons(ghcnlons>180) = ghcnlons(ghcnlons>180)-360;

%% 1. Apply the three completeness thresholds
N = numel(rates);

lat = cell(N,1);
lon = cell(N,1);
ids = cell(N,1);

for k = 1:N

    mr = rates(k);

    [~,ids{k},lat{k},lon{k}] = strict_qc_station( ...
        mr,period1,period2,years,ghcndprcp, ...
        ghcnids,ghcnlats,ghcnlons);

    lat{k} = double(lat{k}(:));
    lon{k} = double(lon{k}(:));

    lon{k}(lon{k}>180) = lon{k}(lon{k}>180)-360;

    fprintf('missrate %2d%%: %4d stations retained\n', ...
        mr,numel(ids{k}));
end

%% 2. Check whether networks are nested
fprintf('\nnesting check (each network contained in the next):\n');

for k = 1:N-1

    inside = all(ismember(string(ids{k}),string(ids{k+1})));

    fprintf('  %d%% within %d%%: %s\n', ...
        rates(k),rates(k+1),string(inside));
end

%% 3. Identify stations added at each threshold step
% Stations present at 20% but not 10%
add_10to20 = ~ismember(string(ids{2}),string(ids{1}));

lat_10to20 = lat{2}(add_10to20);
lon_10to20 = lon{2}(add_10to20);
ids_10to20 = ids{2}(add_10to20);

% Stations present at 30% but not 20%
add_20to30 = ~ismember(string(ids{3}),string(ids{2}));

lat_20to30 = lat{3}(add_20to30);
lon_20to30 = lon{3}(add_20to30);
ids_20to30 = ids{3}(add_20to30);

fprintf('\nStations added when threshold is relaxed:\n');
fprintf('  10%% -> 20%%: %d stations\n',numel(lat_10to20));
fprintf('  20%% -> 30%%: %d stations\n',numel(lat_20to30));

%% 4. Plot complete networks for 10%, 20%, and 30%
f1 = figure; clf

set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 9.5 13.5]);
set(f1,'Color','white','Renderer','painters');

mw = 0.86;
mh = 0.28;

poss = [0.07 0.685 mw mh;
        0.07 0.365 mw mh;
        0.07 0.045 mw mh];

lbl = {'A','B','C'};

load coastlines

for k = 1:N

    s = subplot(3,1,k);
    s.Position = poss(k,:);

    axesm('MapProjection','robinson', ...
        'MapLatLimit',[-60 85], ...
        'Frame','on', ...
        'Grid','off', ...
        'MeridianLabel','off', ...
        'ParallelLabel','off');

    setm(gca,'FLineWidth',1);
    axis off

    scatterm(ghcnlats,ghcnlons,2,[.82 .82 .82],'filled');
    hold on

    scatterm(lat{k},lon{k},4,[147 112 219]/255,'filled');

    plotm(coastlat,coastlon,'color',[.7 .7 .7]);

    title(sprintf('%d%%: %d stations', ...
        rates(k),numel(ids{k})), ...
        'FontName',fn, ...
        'FontSize',fs, ...
        'FontWeight','normal');

    annotation('textbox', ...
        [max(poss(k,1)-0.06,0) ...
        poss(k,2)+poss(k,4)-0.02 ...
        0.05 0.04], ...
        'String',lbl{k}, ...
        'LineStyle','none', ...
        'FontName',fn, ...
        'FontSize',fsp, ...
        'FontWeight','bold');
end

%% 5. Plot ONLY stations added from 20% to 30%
f2 = figure; clf

set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 13.5 7]);
set(f2,'Color','white','Renderer','painters');

axesm('MapProjection','robinson', ...
    'MapLatLimit',[-60 85], ...
    'Frame','on', ...
    'Grid','off', ...
    'MeridianLabel','off', ...
    'ParallelLabel','off');

setm(gca,'FLineWidth',1);
axis off
hold on

% Stations already included at 20%
scatterm(lat{2},lon{2},3,[.78 .78 .78],'filled');

% New stations admitted when moving to 30%
scatterm(lat_20to30,lon_20to30,12,[147 112 219]/255,'filled');

plotm(coastlat,coastlon,'Color',[.6 .6 .6]);

title(sprintf('Stations added when miss-rate threshold increases from 20%% to 30%% (n = %d)', ...
    numel(lat_20to30)), ...
    'FontName',fn,'FontSize',fsp,'FontWeight','normal');

legend({'20% network','Added at 30%'}, ...
    'Location','southoutside', ...
    'Orientation','horizontal', ...
    'Box','off', ...
    'FontName',fn,'FontSize',fs);

%% 6. Counts by latitude band
edges = -90:20:90;

fprintf('\nStations by latitude band\n');
fprintf('%-12s','band');

for k = 1:N
    fprintf('%8s',sprintf('%d%%',rates(k)));
end

fprintf('%10s\n','20->30');

for b = 1:numel(edges)-1

    fprintf('%3d to %3d  ',edges(b),edges(b+1));

    for k = 1:N

        n = sum(lat{k}>=edges(b) & ...
                lat{k}< edges(b+1));

        fprintf('%8d',n);
    end

    nadd = sum(lat_20to30>=edges(b) & ...
               lat_20to30< edges(b+1));

    fprintf('%10d\n',nadd);
end

%% 7. Broad geographic regions for 20% -> 30% additions
% These are deliberately broad diagnostic regions rather than political
% boundaries. Each station is assigned to only one region.

la = lat_20to30;
lo = lon_20to30;

region = strings(size(la));
region(:) = "Other";

% North America
m = la>=15 & la<=85 & lo>=-170 & lo<-50;
region(m) = "North America";

% South America
m = la>=-60 & la<15 & lo>=-90 & lo<-30;
region(m) = "South America";

% Europe
m = la>=35 & la<=75 & lo>=-25 & lo<45;
region(m) = "Europe";

% Africa
m = la>=-40 & la<35 & lo>=-20 & lo<45;
region(m) = "Africa";

% Australia and Oceania
m = la>=-50 & la<0 & lo>=110 & lo<=180;
region(m) = "Australia/Oceania";

% Asia
m = la>=0 & la<=80 & lo>=45 & lo<=180;
region(m) = "Asia";

% A small part of the Middle East falls between Europe/Africa/Asia boxes.
% Label these separately rather than forcing them into Africa.
m = la>=10 & la<40 & lo>=35 & lo<60 & region=="Other";
region(m) = "Middle East";

ureg = ["North America","South America","Europe","Africa", ...
        "Asia","Australia/Oceania","Middle East","Other"];

fprintf('\n=============================================\n');
fprintf('20%% -> 30%% additions by broad region\n');
fprintf('=============================================\n');

nadd_total = numel(la);

region_count = zeros(numel(ureg),1);

for r = 1:numel(ureg)

    region_count(r) = sum(region==ureg(r));

    fprintf('%-20s %4d  (%5.1f%%)\n', ...
        ureg(r), ...
        region_count(r), ...
        100*region_count(r)/nadd_total);
end

%% 8. Print regions ranked by number of added stations
[nsort,ord] = sort(region_count,'descend');

fprintf('\nRegions ranked by number of stations added:\n');

for r = 1:numel(ord)

    if nsort(r)==0
        continue
    end

    fprintf('%2d. %-20s %4d stations (%5.1f%%)\n', ...
        r,ureg(ord(r)),nsort(r), ...
        100*nsort(r)/nadd_total);
end

%% 9. Automatically identify geographic hotspots
% Count new stations in 20-degree latitude x 30-degree longitude boxes.
% This avoids relying only on subjective regional definitions.

latedges = -90:20:90;
lonedges = -180:30:180;

Nbox = zeros(numel(latedges)-1,numel(lonedges)-1);

for i = 1:numel(latedges)-1
    for j = 1:numel(lonedges)-1

        Nbox(i,j) = sum( ...
            la>=latedges(i) & ...
            la< latedges(i+1) & ...
            lo>=lonedges(j) & ...
            lo< lonedges(j+1));
    end
end

[countsort,idxsort] = sort(Nbox(:),'descend');

fprintf('\n=============================================\n');
fprintf('Top geographic hotspots of 20%% -> 30%% additions\n');
fprintf('(20 deg latitude x 30 deg longitude boxes)\n');
fprintf('=============================================\n');

ntop = min(10,sum(countsort>0));

for k = 1:ntop

    [ii,jj] = ind2sub(size(Nbox),idxsort(k));

    fprintf('%2d. lat %4d to %4d, lon %4d to %4d: %4d stations (%4.1f%%)\n', ...
        k, ...
        latedges(ii),latedges(ii+1), ...
        lonedges(jj),lonedges(jj+1), ...
        countsort(k), ...
        100*countsort(k)/nadd_total);
end

%% 10. Optional bar chart of broad-region additions
f3 = figure; clf

keep = region_count>0;

bar(categorical(ureg(keep)),region_count(keep));

ylabel('Stations added');
title('Stations added from 20% to 30% completeness threshold');

set(gca,'FontName',fn,'FontSize',fs);
xtickangle(35);
box off

%% 11. Save
esfx = [num2str(period1(1)),num2str(period1(end)),'_', ...
        num2str(period2(1)),num2str(period2(end))];

savefig(f1,[outfolder,'FigR_missrate_network_',esfx,'.fig']);
exportgraphics(f1,[outfolder,'FigR_missrate_network_',esfx,'.png'], ...
    'Resolution',300);

% exportgraphics(f2,[outfolder,'FigR_missrate_added20to30_',esfx,'.png'], ...
%     'Resolution',300);
% 
% exportgraphics(f3,[outfolder,'FigR_missrate_regions20to30_',esfx,'.png'], ...
%     'Resolution',300);

save([outfolder,'missrate_networks_',esfx,'.mat'], ...
    'rates','ids','lat','lon', ...
    'lat_10to20','lon_10to20','ids_10to20', ...
    'lat_20to30','lon_20to30','ids_20to30', ...
    'region','region_count','ureg', ...
    'period1','period2');