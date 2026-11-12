%%  Fig. RX: Precipitation amount distribution with a 1 mm/d non-zero
%   precipitation threshold
%   Jingya Han, Cornell University, jh2423@cornell.edu
%
%   Smoothed (KDE) distributions of the early epoch, for stations and for the
%   CMIP6 multi-model mean at co-located grid points.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

period1  = 1955:1984;
period2  = 1994:2023;
missrate = 20;
path1   = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\';   % 1 mm/d threshold
path003 = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';   % original run, used only for the bin axis
outdir  = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\';

suffix = [num2str(missrate),'%miss_', ...
          num2str(period1(1)),num2str(period1(end)),'_', ...
          num2str(period2(1)),num2str(period2(end)),'.nc'];
fsta = ['way1_stations_',suffix];   % smoothed stations
fmmm = ['way1_MMM_',suffix];        % smoothed CMIP6 multi-model mean

%% ------------------------------------------------------------------ load
bincrates = ncread([path1,fsta],'bincrates');
kdepamt1  = ncread([path1,fsta],'kdepamt1');
BINCRATES = ncread([path1,fmmm],'BINCRATES');
KDEMMM    = ncread([path1,fmmm],'KDEMMMpamt1');

% The x-axis is the bin index, so both curves must sit on the same bin array.
ref    = bincrates;
KDEMMM = matchbins(BINCRATES, KDEMMM, ref, 'MMM');

%% ------------------------------------------------------------------ plot
f = figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 12 9]);
set(f,'Color','white');
axes('Position',[0.14 0.15 0.80 0.78]);

colsta = [0 0 0];             % black : stations
colmod = [220 20 60]/255;     % red   : CMIP6 models
x      = 1:length(ref);

% mark the 1 mm/d threshold, below which both curves are zero by design
xthr = interp1(ref,x,1);
plot([xthr xthr],[0 1],'-','Color',[.8 .8 .8],'LineWidth',.75); hold on; box on;

hsta = plot(x, kdepamt1,'-','Color',colsta,'LineWidth',1.5);
hmod = plot(x, KDEMMM,  '-','Color',colmod,'LineWidth',1.5);

% axes -------------------------------------------------------------------
xtickrates  = [0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
xticks      = interp1(ref,x,xtickrates);
xtickratesp = {0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] ...
               10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
xtickratesp(isnan(xticks)) = [];
xticks(isnan(xticks))      = [];

set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0, ...
    'fontsize',8,'FontName','Arial');
xlim([0 142]);
ylim([0 1.30*max([kdepamt1(:);KDEMMM(:)])]);   % headroom for the legend
xlabel('Precipitation rate (mm d^{-1})','FontName','Arial','fontsize',9);
ylabel('Precipitation amount (mm d^{-1})','FontName','Arial','fontsize',9);

% Legend in the upper right, clear of the curves. The distributions peak
% around 20 mm/d and fall away toward the right edge, so that corner is free;
% the extra headroom keeps the box off the station peak.
l = legend([hsta hmod], {'Station observations','CMIP6 models'}, ...
    'Location','northeast','FontName','Arial','fontsize',9);
l.Box = 'off';
l.Position(1) = l.Position(1) - 0.02;   % nudge in from the axes edge
l.Position(2) = l.Position(2) - 0.02;

%% ------------------------------------------------------------------ save
if ~exist(outdir,'dir'); mkdir(outdir); end
savefig([outdir,'FigR_1mm_thre_climatology.fig']);
exportgraphics(gcf,[outdir,'FigR_1mm_thre_climatology.png'],'Resolution',600);
exportgraphics(gcf,[outdir,'FigR_1mm_thre_climatology.pdf'], ...
    'ContentType','vector','BackgroundColor','white'); 
%% --------------------------------------------------------------- helpers
function y = matchbins(rates, y, ref, label)
% Return y on the reference bin array; interpolate only if the bins differ.
    if numel(rates) == numel(ref) && max(abs(rates(:)-ref(:))) < 1e-9
        return
    end
    warning('Bin array for %s differs from the reference; interpolating.',label);
    y = interp1(rates(:), y(:), ref(:), 'linear', NaN);
end