%% Fig. 2C vs fig. S2B: interval widths and the overlap test
%  Standalone. Set the path and epoch below and run.
%
%  Reports, for the full network and for the network with Russian stations
%  excluded, the point estimate and the 84% and 95% ranges of each mode, on
%  both sides of the comparison, and decides the overlap test numerically
%  rather than by eye. Non-overlap of the 84% intervals is the criterion used
%  in the figures: it corresponds to a difference at 95% confidence.
%
%  The full-network results are stored as netCDF and the no-Russia results as
%  .mat, so both extensions are tried for every file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc

path     = '\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\dataforplot\';
missrate = 20;
period1  = 1955:1984;
period2  = 1994:2023;

esfx = [num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)), ...
        '_',num2str(period2(1)),num2str(period2(end))];

% prefix, label; the no-Russia run writes the same file names with xRU_
pre = {'',      'full network'; ...
       'xRU_',  'Russia excluded'};

modes = {'inc','shift'};   % stem of UR_inc / UR_shift
smod  = {'inc_w1','shift_w1'};          % point estimate, stations
mmod  = {'mmminc_w1','mmmshift_w1'};    % point estimate, models
lbl   = {'increase','shift'};

R = cell(2,1);
for ic = 1:2
    p = pre{ic,1};  nm = pre{ic,2};
    f_ur_s = [path,p,'stations_uncertainty_range_',esfx];
    f_ur_m = [path,p,'cmip6_uncertainty_range_',esfx];
    f_w_s  = [path,p,'way1_stations_',esfx];
    f_w_m  = [path,p,'way1_MMM_',esfx];

    miss = {};
    for f = {f_ur_s,f_ur_m,f_w_s,f_w_m}
        if isempty(whichfile(f{1})); miss{end+1} = f{1}; end %#ok<SAGROW>
    end
    if ~isempty(miss)
        fprintf('\n=== %s: skipped, no .nc or .mat found for ===\n', nm);
        fprintf('  %s\n', miss{:});
        continue
    end

    fprintf('\n=== %s ===\n', nm);
    fprintf('  %s\n  %s\n', whichfile(f_ur_s), whichfile(f_ur_m));

    S = struct();
    for k = 1:2
        s  = readvar(f_ur_s, ['UR_',modes{k}]);  s = s(~isnan(s(:)));
        m  = readvar(f_ur_m, ['UR_',modes{k}]);  m = m(~isnan(m(:)));
        ps = readvar(f_w_s,  smod{k});  ps = ps(1);
        pm = readvar(f_w_m,  mmod{k});  pm = pm(1);

        q_s84 = prctile(s,[8 92]);   q_s95 = prctile(s,[2.5 97.5]);
        q_m84 = prctile(m,[8 92]);   q_m95 = prctile(m,[2.5 97.5]);

        % The intervals fail to overlap when one lies entirely above the
        % other; both directions are checked so the test does not assume
        % which side is larger.
        ov84 = ~(q_s84(1) > q_m84(2) || q_m84(1) > q_s84(2));
        ov95 = ~(q_s95(1) > q_m95(2) || q_m95(1) > q_s95(2));
        gap84 = q_s84(1) - q_m84(2);   % positive when separated

        fprintf('\n  %s mode\n', lbl{k});
        fprintf('    %-9s n=%5d  est %6.2f  84%% [%6.2f %6.2f] w=%5.2f  95%% [%6.2f %6.2f] w=%5.2f\n', ...
            'stations', numel(s), ps, q_s84, diff(q_s84), q_s95, diff(q_s95));
        fprintf('    %-9s n=%5d  est %6.2f  84%% [%6.2f %6.2f] w=%5.2f  95%% [%6.2f %6.2f] w=%5.2f\n', ...
            'models',   numel(m), pm, q_m84, diff(q_m84), q_m95, diff(q_m95));
        fprintf('    ratio (station/model) = %.2f\n', ps/pm);
        fprintf('    84%% intervals %s (station lower %.2f vs model upper %.2f, gap %+.2f)\n', ...
            ternary(ov84,'OVERLAP','do NOT overlap'), q_s84(1), q_m84(2), gap84);
        fprintf('    95%% intervals %s\n', ternary(ov95,'OVERLAP','do NOT overlap'));

        S.(modes{k}) = struct('est_s',ps,'est_m',pm,'s84',q_s84,'m84',q_m84, ...
            'ov84',ov84,'ov95',ov95,'ns',numel(s),'nm',numel(m),'gap',gap84);
    end
    R{ic} = S;
end

%% side-by-side summary
if ~isempty(R{1}) && ~isempty(R{2})
    fprintf('\n\n=== full network vs Russia excluded ===\n');
    fprintf('%-9s %-17s %8s %8s %7s %10s %10s %9s\n', ...
        'mode','case','station','model','ratio','84% w sta','84% w mod','overlap');
    for k = 1:2
        for ic = 1:2
            r = R{ic}.(modes{k});
            fprintf('%-9s %-17s %8.2f %8.2f %7.2f %10.2f %10.2f %9s\n', ...
                lbl{k}, pre{ic,2}, r.est_s, r.est_m, r.est_s/r.est_m, ...
                diff(r.s84), diff(r.m84), ternary(r.ov84,'yes','no'));
        end
    end
    fprintf(['\nIf the station interval does not widen when Russia is excluded, ' ...
             'any change in the overlap comes from the estimates moving rather ' ...
             'than from a loss of precision.\n']);
end

%% ------------------------------------------------------------- helpers
function f = whichfile(base)
% Return the existing file for a path given without extension, or ''.
    f = '';
    for e = {'.nc','.mat'}
        if isfile([base,e{1}]); f = [base,e{1}]; return; end
    end
end

function v = readvar(base, name)
% Read one variable from whichever of the two formats is present.
    f = whichfile(base);
    assert(~isempty(f),'no .nc or .mat for %s',base);
    if endsWith(f,'.nc')
        v = double(ncread(f,name));
    else
        S = load(f,name);
        assert(isfield(S,name),'%s does not contain %s',f,name);
        v = double(S.(name));
    end
end

function out = ternary(c,a,b)
    if c; out = a; else; out = b; end
end