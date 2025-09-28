function [hm_rho] = RadHm(ps,s2)

[~,~, BandNum] = size(s2);

% ps_hm = ps;
hm_rho = zeros(BandNum,2);

for i = 1:BandNum
    psb = ps(:,:,i);
    s2b = s2(:,:,i);
    b = regress(s2b(:),[ones(length(psb(:)),1) psb(:)]);
    hm_rho(i,:) = b;

    % psb = psb.*b(2)+b(1);
    % ps_hm(:,:,i) = psb;
end

end