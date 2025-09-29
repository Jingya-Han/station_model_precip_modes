% 28 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% calculate uncertainty range of shift mode, inc mode,
% a_o and b_o for cmip6
function [UR_inc,UR_shift,UR_err,UR_a_o,UR_b_o,UR_pamt1,UR_ppdf1,UR_dpamt1,UR_pamtshiftinc,UR_dppdf1,UR_ppdfshiftinc,...
    UR_dfreq,UR_dfreqshiftinc]=cmip_UR (modelsampleraindist,BINCRATES,selectedmodels,...
    ensemble,meanT)
total_elements = sum(cellfun(@numel, ensemble)); % total number of all ensemble members in all models
UR_inc=nan(total_elements,1);
UR_shift=nan(total_elements,1);
UR_err=nan(total_elements,1);
UR_a_o=nan(total_elements,1);
UR_b_o=nan(total_elements,1);
UR_pamt1=zeros(300,total_elements); % for rain distributions
UR_ppdf1=zeros(300,total_elements);
UR_dpamt1=zeros(300,total_elements);
UR_pamtshiftinc=zeros(300,total_elements);
UR_dppdf1=zeros(300,total_elements);
UR_ppdfshiftinc=zeros(300,total_elements);
UR_dfreq=zeros(300,total_elements);
UR_dfreqshiftinc=zeros(300,total_elements);

count=0;
  for im=1:length(selectedmodels)
      imodel_ensemble=ensemble{im,1};

    for ien=1:length(imodel_ensemble)
        count=count+1;
        ppdf1=modelsampleraindist{im,1}(ien,:,1);
        ppdf2=modelsampleraindist{im,1}(ien,:,2);
        pamt1=modelsampleraindist{im,1}(ien,:,3);
        pamt2=modelsampleraindist{im,1}(ien,:,4);
        meandt=nanmean(meanT{im,1}(:,2)-meanT{im,1}(:,1));
        dt=meanT{im,1}(ien,2)-meanT{im,1}(ien,1);
        if isnan(dt)
           dt=meandt;
        end
        % shift, inc
         [shift,inc,err,dpamt1,~,~,pamtshiftinc,dppdf1,...
        ~,~,ppdfshiftinc,dfreq,~,~,dfreqshiftinc]=...
        makeshiftinc_stations(ppdf1(:), pamt1(:), ppdf2(:), pamt2(:),dt,BINCRATES);
        n=length(dpamt1);
        UR_dpamt1(1:n,count)=dpamt1;
        UR_pamtshiftinc(1:n,count)=pamtshiftinc;
        UR_dppdf1(1:n,count)=dppdf1;
        UR_ppdfshiftinc(1:n,count)=ppdfshiftinc;
        m=length(dfreq);
        UR_dfreq(1:m,count)=dfreq(:);
        UR_dfreqshiftinc(1:m,count)=dfreqshiftinc(:);
        UR_pamt1(1:n,count)=pamt1(:);
        UR_ppdf1(1:n,count)=ppdf1(:);

        UR_inc(count,1)=inc;
        UR_shift(count,1)=shift;
        UR_err(count,1)=err;

        % a_o, b_o
        a_o=(nansum(pamt2)/nansum(pamt1)-1)*100./dt; % unit: %/K
        r_05=nan(2,1);
        allprcp{1,1}=pamt1;
        allprcp{2,1}=pamt2;
        for ip=1:2
            pr=allprcp{ip,1};
            pr = pr(:);
            prorder=sortrows(pr,1,'ascend'); % Missing elements are placed last for ascending order
            prorder=prorder(~isnan(prorder));
            percentcumpr=cumsum(prorder)./sum(prorder,'omitnan');
            percentcumpr=percentcumpr(~isnan(percentcumpr));
            if ~isempty(percentcumpr) % git rid of nonmeaningful denominator (0)
                [unipcum,index,~] = unique(percentcumpr,'first'); % remove duplicated values去除重复值
                prorder=prorder(index);
                r_05(ip,1)=interp1(unipcum, prorder, 0.5);  % r_05 should be calculated from the original daily pre.    
            end

        end
        b_o=100*(r_05(2,:)./r_05(1,:)-1)./dt; % unit:%/K 
        UR_a_o(count,1)=a_o;
        UR_b_o(count,1)=b_o;

    end

  end

end