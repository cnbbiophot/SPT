function [msd_op] = msd_one_particle_n(track)
%Calculates the MSD for one particle with trajectory give by t,x,y.
%returns a vector with lag time and msd 

steps=size(track,1);
X=track(:,2:end);
t=track(:,1);
msd_op=zeros(steps-1,3);
[T1, T2] = meshgrid(t, t);
dT = round((abs(T1(:)-T2(:)))*1000)/1000;
all_delays = unique(dT);
delays = unique( vertcat(all_delays));
n_delays=numel(delays);
mean_msd    = zeros(n_delays, 1);
M2_msd2     = zeros(n_delays, 1);
n_msd       = zeros(n_delays, 1);
%j=3;
for j=1:steps-1
    lagtime=zeros(steps-j,1);
    sqrt_dist=zeros(steps-j,1);
    lagtime = round((t(j+1:end) - t(j))*1000)/1000; %
   
    dX = X(j+1:end,:) - repmat(X(j,:), [(steps-j) 1] );
    sqrt_dist = sum( dX .* dX, 2);
    
    [~, index_in_all_delays, ~] = intersect(delays, lagtime);

    % Store for mean computation 
    n_msd(index_in_all_delays)     = n_msd(index_in_all_delays) + 1;
    delta = sqrt_dist - mean_msd(index_in_all_delays);
    mean_msd(index_in_all_delays) = mean_msd(index_in_all_delays) + delta ./ n_msd(index_in_all_delays);
    M2_msd2(index_in_all_delays)  = M2_msd2(index_in_all_delays) + delta .* (sqrt_dist - mean_msd(index_in_all_delays));
end

n_msd(1) = steps;
std_msd = sqrt( M2_msd2 ./ n_msd ) ;
% std_msd = sqrt( M2_msd2) ;
    
    % We replace points for which N=0 by Nan, to later treat
    % then as missing data. Indeed, for each msd cell, all the
    % delays are present. But some tracks might not have all
    % delays
delay_not_present = n_msd == 0;
mean_msd( delay_not_present ) = NaN;
msd_op = [ delays mean_msd std_msd n_msd ];
%      for i=1:steps-j
%       lagtime(i,1)=(track(i+j,1)-track(i,1));
%       sqrt_dist(i,1)=(r(i+j-1)-r(i))^2;
%     end
%     if (range(lagtime)<10e-12)
%         msd_op(j,1)=lagtime(1,1);
%         msd_op(j,2)=(sum(sqrt_dist(:,1))/size(lagtime,1));
%         msd_op(j,3)=j;
%     else 
%         error('different lagtime');
%     end
%     
% end    

   
end

