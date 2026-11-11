%% Fig. SX: the fitted change split into the increase and shift modes
% Oct. 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% Same epochs and data as Fig. 2A,B, without the uncertainty ranges.
%   A: stations   B: CMIP6 multi-model mean
% Each panel shows the actual change in the precipitation amount
% distribution (black), the change from each mode alone, and the change
% fitted by the two modes together. Mode colors as in Pendergrass and
% Hartmann (2014), Fig. 3: increase purple, shift green, shift + increase magenta.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
fn='Arial'; fs=8; fsp=9;
period1=1955:1984; period2=1994:2023; missrate=20;
path='\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
figdir='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\';
ep=[num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'];

%% stations
fsta=[path,'way1_stations_',ep];
bincrates   =ncread(fsta,'bincrates');
dpamt1      =ncread(fsta,'dpamt1');
kdepamt1    =ncread(fsta,'kdepamt1');
pamtshiftinc=ncread(fsta,'pamtshiftinc');
pamtinc     =ncread(fsta,'pamtinc');
pamtshift   =ncread(fsta,'pamtshift');
inc_w1      =ncread(fsta,'inc_w1');
shift_w1    =ncread(fsta,'shift_w1');

%% CMIP6 multi-model mean
fmmm=[path,'way1_MMM_',ep];
KDEMMMpamt1     =ncread(fmmm,'KDEMMMpamt1');
mmm_dpamt1      =ncread(fmmm,'mmm_dpamt1');
mmm_pamtshiftinc=ncread(fmmm,'mmm_pamtshiftinc');
mmm_pamtinc     =ncread(fmmm,'mmm_pamtinc');
mmm_pamtshift   =ncread(fmmm,'mmm_pamtshift');
mmminc_w1       =ncread(fmmm,'mmminc_w1');
mmmshift_w1     =ncread(fmmm,'mmmshift_w1');

%% fitted changes, as in Fig. 2: (fitted distribution - initial distribution)/bin width
db=(bincrates(3)-bincrates(2))./bincrates(2);   % bin width
S.d    =dpamt1(:);
S.both =(pamtshiftinc(:)-kdepamt1(:))/db;
S.inc  =(pamtinc(:)     -kdepamt1(:))/db;
S.shift=(pamtshift(:)   -kdepamt1(:))/db;
M.d    =mmm_dpamt1(:);
M.both =(mmm_pamtshiftinc(:)-KDEMMMpamt1(:))/db;
M.inc  =(mmm_pamtinc(:)     -KDEMMMpamt1(:))/db;
M.shift=(mmm_pamtshift(:)   -KDEMMMpamt1(:))/db;

%% axes setup, as in Fig. 2
x01=interp1(bincrates,1:length(bincrates),0.1);  % start at the GHCNd resolution, 0.1 mm/d
xhi=130;                                         % drop the last few bins
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000];
xticks=interp1(bincrates,1:length(bincrates),xtickrates);
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000};
xtickratesp(isnan(xticks))=[]; xticks(isnan(xticks))=[];
ylm=[-0.03 0.15];                                     % same y range in both panels

% colors
obscolor  =[0 0 0];               % actual change, stations and models
inccolor  =[114 100 171]/255;     % increase: purple
shiftcolor=[0 147 103]/255;       % shift: green
bothcolor =[225 0 121]/255;       % shift + increase: magenta

%% figure
f=figure; clf
set(f,'units','centimeters','paperpositionmode','auto','position',[1 1 18.4 8],...
    'Color','white','Renderer','painters');
poss=[0.07 0.15 0.42 0.75;
      0.57 0.15 0.42 0.75];

% A: stations
s=subplot(1,2,1); s.Position=poss(1,:);
h=modesplot(S,obscolor,inccolor,shiftcolor,bothcolor,xticks,xtickratesp,x01,xhi,ylm,fn,fs);
lg=legend(h,{'Station observations',...
    sprintf('Increase (%.2f%% K^{-1})',inc_w1),...
    sprintf('Shift (%.2f%% K^{-1})',shift_w1),...
    'Shift + Increase'},...
    'Location','northwest','FontName',fn,'FontSize',fs,'Box','off');
lg.Position(1)=lg.Position(1)+0.03;   % leave room for the panel letter
ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);
text(0.03,0.95,'A','Units','normalized','FontName',fn,'FontSize',fsp,'FontWeight','bold');

% B: CMIP6 multi-model mean
s=subplot(1,2,2); s.Position=poss(2,:);
h=modesplot(M,obscolor,inccolor,shiftcolor,bothcolor,xticks,xtickratesp,x01,xhi,ylm,fn,fs);
lg=legend(h,{'Climate models',...
    sprintf('Increase (%.2f%% K^{-1})',mmminc_w1),...
    sprintf('Shift (%.2f%% K^{-1})',mmmshift_w1),...
    'Shift + Increase'},...
    'Location','northwest','FontName',fn,'FontSize',fs,'Box','off');
lg.Position(1)=lg.Position(1)+0.03;
ylabel('\DeltaP (mm d ^-^1 K ^-^1)','FontName',fn,'FontSize',fs);
text(0.03,0.95,'B','Units','normalized','FontName',fn,'FontSize',fsp,'FontWeight','bold');

savefig(f,[figdir,'figS4.fig']);
exportgraphics(f,[figdir,'figS4.pdf'],'ContentType','vector','BackgroundColor','white');
exportgraphics(f,[figdir,'figS4.png'],'Resolution',600);

%% helper
function p=modesplot(D,cdat,cinc,cshift,cboth,xticks,xtickratesp,x01,xhi,ylm,fn,fs)
    % zero line first, then the fitted changes, then the actual change on top
    line([0 xhi],[0 0],'Color',[.5 .5 .5]); hold on
    hi=plot(1:numel(D.inc),D.inc,'-','Color',cinc,'LineWidth',1.2);
    hs=plot(1:numel(D.shift),D.shift,'-','Color',cshift,'LineWidth',1.2);
    hb=plot(1:numel(D.both),D.both,'-','Color',cboth,'LineWidth',1.2);
    hd=plot(1:numel(D.d),D.d,'-','Color',cdat,'LineWidth',1.2);
    p=[hd hi hs hb];   % legend order, as in the screenshot
    box on
    set(gca,'FontName',fn,'FontSize',fs);
    xlim([x01 xhi]); ylim(ylm);
    set(gca,'xtick',xticks,'xticklabel',xtickratesp,'XTickLabelRotation',0);
    xlabel('Precipitation rate (mm d ^-^1)','FontName',fn,'FontSize',fs);
end