%% setting datName, pathName to run stimAnalysisv3 / spontaneousData
datName = '131011_4350_stimEfficacy1.spike';
pathName = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments3\StimRecSite\';
respTriplet = [6 36 45]; % hw+1
stimNo = 5;
%% post stim trajectory
%131010_4346_StimEfficacy2.spike (26, 58, 60)
%130625_4205_StimEfficacy.spike (13, 25, 17), st:3
%131011_4350_stimEfficacy1 (6, 36, 45), st: 5
%140203_4409_stimEfficacy (25, 32, 37), st:1

% priors to run this: stimAnalysis_v3.m
stimAnalysis_v3;
summed_effect = cell(5,1);
count = 1;

for kk =  20%[10 15 20 25]; %
    h2 = figure();
    binSize = kk;
    binned = -50:binSize:500;
    c = varycolor(50);
    colormap(c);
    for jj = 1:50
        coords = zeros(3,length(binned));
        resps = [periStim{stimNo}{respTriplet}];
        for ii = 1:3
            shifted_ms = (resps{jj,ii}- stimTimes{stimNo}(jj))*1e3;
            [counts,timeVec] = hist(shifted_ms,binned);
%              counts(find(counts)) = 1; % counts could be anything
            coords(ii,:) = counts;
        end
        trialsmooth_mod;
        summed_effect{count}(:,:,jj) = sy;
%         pause(1)
    end
    count = count + 1;
    colorbar;
    set(gca,'FontSize',14);
    title(['Trajectories with bin-size = ', num2str(kk),'ms'], 'FontSize',14);
%      saveas(h2,['C:\Users\duarte\Desktop\fig_traj\131011_4350\trajFWHM8_',num2str(kk),'ms.eps'], 'psc2');
%      close(h2);
end


%% PCA

for ii = 1:50
    X = summed_effect{1}(:,:,ii)';
    [coeff{ii}, score{ii}, latent{ii}, ~,explained{ii},mu{ii}] = pca(X);
end
score_mat = zeros(50,size(binned,2));
% figure;
% hold on;
% for ii = 1:50
%     plot(score{ii}(:,1),score{ii}(:,2),'LineWidth',2);
% end
% hold off;

h1d = figure;
hold on;
h2d = figure;
hold on;
colormap(c)
for ii = 1:50
    if numel(score{ii}) == 3*size(binned,2)
        score_mat(ii,:) = score{ii}(:,1);
        figure(h1d);
        plot(score{ii}(:,1),'LineWidth',2,'Color',c(ii,:));
        figure(h2d);
        plot(score{ii}(:,1),score{ii}(:,2),'LineWidth',2,'Color',c(ii,:));
    end
end
figure(h1d);
colorbar;
figure(h2d);
colorbar;

score_mat(isnan(score_mat)) = 0;
[max_val,max_ind] = max(score_mat,[],2);


figure;
plot(find(max_ind>1),max_ind(max_ind>1),'.','MarkerSize',7);
xlabel('Trial #');
ylabel('Peak of PCA1');

silence_b4 = silence_s{5}([6,36,45],:)'; %old 50x3 matrix
mean_sil_b4 = mean(silence_b4,2);
max_sil_b4 = max(silence_b4,[],2);
min_sil_b4 = min(silence_b4,[],2);

figure;
plot(mean_sil_b4(max_ind>1),max_ind(max_ind>1),'.','MarkerSize',15);
xlabel('Mean pre-stimulus inactivity [s]');
ylabel('Peak of PCA1');

