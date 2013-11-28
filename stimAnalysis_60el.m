% -------------------------------------------------------------------------------------
% Purpose: Analyse 60 electrode stim responses 

% Author: Sreedhar S Kumar
% Date: 22.11.2013
%% Version details 
% MATLAB Version 7.12.0.635 (R2011a)
% MATLAB License Number: 97144
% Operating System: Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
% Java VM Version: Java 1.6.0_17-b04 with Sun Microsystems Inc. Java HotSpot(TM) 64-Bit Server VM mixed mode
% -------------------------------------------------------------------------------------
% MATLAB                                                Version 7.12       (R2011a)
% Simulink                                              Version 7.7        (R2011a)
% Data Acquisition Toolbox                              Version 2.18       (R2011a)
% Fixed-Point Toolbox                                   Version 3.3        (R2011a)
% Image Processing Toolbox                              Version 7.2        (R2011a)
% MATLAB Compiler                                       Version 4.15       (R2011a)
% Neural Network Toolbox                                Version 7.0.1      (R2011a)
% Parallel Computing Toolbox                            Version 5.1        (R2011a)
% Signal Processing Toolbox                             Version 6.15       (R2011a)
% Statistics Toolbox                                    Version 7.5        (R2011a)
% Wavelet Toolbox                                       Version 4.7        (R2011a)
%--------------------------------------------------------------------------------------
%% Load data
if ~exist('datName','var')
    [datName,pathName] = chooseDatFile(3,'st');
end

datRoot = datName(1:strfind(datName,'.')-1);
spikes=loadspike([pathName,datName],2,25);
handles = zeros(1,7);

%% Stimulus locations and time
%Get stim info into analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site
% I do this before cleaning the spikes because I do not want to clean off
% the stim times in the analog channels.

inAnalog = cell(4,1);
for ii=60:63
    inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
end

nStimSites = 60;
stimSites = repmat(hw2cr(0:59),1,50); % in cr
stimTimes = cell(1,nStimSites);
for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
end



%% Cleaning the spikes; silencing artifacts 1ms post stimulus blank and getting them into cells
[spks, selIdx, rejIdx] = cleanspikes(spikes);
spks = trimAnalogChannels(spikes);
spks = blankArtifacts(spks,stimTimes,1);

spks.stimTimes = stimTimes;
spks.stimSites = stimSites;

inAChannel = cell(60,1);
for ii=0:59
    inAChannel{ii+1,1} = spks.time(spks.channel==ii);
end


%% Peristimulus spike trains for each stim site and each channel
% periStim has a cell in a cell in a cell structure.
% Layer 1 (outer cell) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x1 cell, each corresponding to a channel
% Layer 3 is a 50x1 cell, holding the periStim spike stamps corresponding to each of the 50 stimuli.
periStim = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        for kk = 1:60
            periStim{ii}{kk,1}{jj,1} = inAChannel{kk}(and(inAChannel{kk}>stimTimes{ii}(jj)-0.05, inAChannel{kk}<stimTimes{ii}(jj)+0.5));
        end
    end
end

%% Binning, averaging and plotting the PSTHs with 1s pre-stim silence
% listOfCounts = cell(1,nStimSites);
% for ii = 1:nStimSites
%     figure(2+ii)
%     for jj = 1:60
%         bins = -50: 10: 500;
%         count = 0;
%         frMat = zeros(2,length(bins));
%         for kk = 1:size(stimTimes{ii},2)
%             shiftedSp = periStim_selected{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
%             if ~isempty(shiftedSp)
%                 fr = zeros(size(bins));
%                 for mm = 1:length(bins)-1
%                     fr(mm) = length(shiftedSp(and(shiftedSp>=bins(mm)*1e-3,shiftedSp<(bins(mm+1)*1e-3))));
%                 end
%                 count = count + 1;
%                 frMat(count,:) = fr;     
%             end
%         end
%         listOfCounts{1,ii}{jj,1} = count; 
%         if count ==0, count=1; end
%         
%         %finding the right subplot position in a 6x10 array
%         ch6x10_ch8x8_60 = channelmap6x10_ch8x8_60;
%         [row, col] = find(ch6x10_ch8x8_60 == jj);
%         pos = 6*(row-1) + col;
%         subplot(10,6,pos)
%         shadedErrorBar(bins,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
%         axis([-100 500 -0.5 2.5])
%         line([0 0],[-0.5 max(2,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
%         text(375,1.7,num2str(jj),'FontAngle','italic');
%         if ~or(mod(pos,6)==1,pos>54)
%             set(gca,'YTickLabel',[]);
%             set(gca,'XTickLabel',[]);
%         elseif pos>55
%             set(gca,'YTickLabel',[]);
%         elseif pos~=55
%             set(gca,'XTickLabel',[]);
%         end
%         set(gcf,'WindowButtonDownFcn','popsubplot(gca)')
%      end
%         % Add a title to the whole plot
%         set(gcf,'NextPlot','add');
%         axes;
%         h = title(['Mean PSTHs following stimulation at ',num2str(stimSites(ii)+1),'(hw+1). [mean #spikes vs time(ms)]']);
%         set(gca,'Visible','off');
%         set(h,'Visible','on');
%         
% %         %print as a landscape eps figure
% %         h=gcf;
% %         set(h,'PaperPositionMode','auto'); 
% %         set(h,'PaperOrientation','landscape');
% %         set(h,'Position',[50 50 1200 800]);
% %         print(gcf, '-depsc', [fPath,datRoot,'_',num2str(stimSites(ii)+1),'.eps']); % hw+1
% end


%% Binning, averaging and plotting all the PSTHs
listOfCounts_all = cell(1,nStimSites);

for ii = 1:nStimSites
    psth_h = genvarname(['psth_',num2str(ii)]);
    eval([psth_h '= figure(', num2str(1+ii), ');']);
    handles(ii+1) = eval(psth_h);
    for jj = 1:60
        bins = -50: 5: 500;
        count = 0;
        frMat = zeros(2,length(bins));
        for kk = 1:size(stimTimes{ii},2)
            shiftedSp = periStim{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
            %if ~isempty(spks)
                fr = zeros(size(bins));
                for mm = 1:length(bins)-1
                    fr(mm) = length(shiftedSp(and(shiftedSp>=bins(mm)*1e-3,shiftedSp<(bins(mm+1)*1e-3))));
                end
                count = count + 1;
                frMat(count,:) = fr;     
            %end
        end
        listOfCounts_all{1,ii}{jj,1} = count; 
        if count ==0, count=1; end
        
        %finding the right subplot position in a 6x10 array
        ch6x10_ch8x8_60 = channelmap6x10_ch8x8_60;
        [row, col] = find(ch6x10_ch8x8_60 == jj);
        pos = 6*(row-1) + col;
        subplot(10,6,pos)
        shadedErrorBar(bins,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
        axis([-50 500 -0.5 1])
        
        line([0 0],[-0.5 max(2,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
        if jj == cr2hw(stimSites(ii))+1
            text(375,0.5,num2str(jj),'FontAngle','italic','Color',[1,0,0]);
        else
            text(375,0.5,num2str(jj),'FontAngle','italic');
        end
        
        if ~or(mod(pos,6)==1,pos>54)
            set(gca,'YTickLabel',[]);
            set(gca,'XTickLabel',[]);
        elseif pos>55
            set(gca,'YTickLabel',[]);
        elseif pos~=55
            set(gca,'XTickLabel',[]);
        end
        set(gcf,'WindowButtonDownFcn','popsubplot(gca)')
        set(gcf,'WindowStyle','docked');
    end
 [ax1,h1]=suplabel('time[ms]');
 set(h1,'FontSize',16);
 [ax2,h2]=suplabel('Mean #spikes','y');
 set(h2,'FontSize',16);
 [ax4,h3]=suplabel(['PSTH (stimulation at ',num2str(stimSites(ii)),'^{cr} / ',num2str(cr2hw(stimSites(ii))+1),'^{hw+1})'],'t');
 set(h3,'FontSize',16);
 %  set(h3,'FontSize',30)
%     % Add a title to the whole plot
%         set(gcf,'NextPlot','add');
%         axes;
%         h = title(['PSTHs following stimulation at ',num2str(stimSites(ii)),' / ',num2str(cr2hw(stimSites(ii))+1),' cr/(hw^{+1}). [mean #spikes vs time(ms)]']);
%         set(gca,'Visible','off');
%         set(h,'Visible','on');
end

%% saving the figures
%saveFigs('stimAnalysis', datRoot,handles, stimSites);

%% Debuggin routines
%59 il stim um  16 il responses um nokkam
% art_bin = cell(60,1);
% for jj = 1:60
%     for kk = 1: length(stimTimes{5})
%         shiftedSp = periStim{5}{jj}{kk,1}-stimTimes{5}(1,kk);
%         art_bin{jj,1}{kk,1} = shiftedSp(and(shiftedSp>=0,shiftedSp<10*1e-3));
%     end
% end
% figure(13)
% for ii = 1:50
%     realTime = art_bin{16}{ii} + stimTimes{5}(ii);
%     for jj = 1:length(realTime)
%         indxOfSpk = find(and(spks.time == realTime, spks.channel==15));
%         subplot(5,10,ii)
%         plot(spks.context(:,indxOfSpk));
%         hold on;
%         plot(ones(124,1)*(spks.thresh(indxOfSpk)+mean(spks.context(:,indxOfSpk))),'r');
%         axis tight;
%     end
% end
% 
% figure(14)
% 
% for ii = 1:50
%     realTime = art_bin{16}{ii} + stimTimes{5}(ii);
%     for jj = 1:length(realTime)
%         lots = find(and(spks.time ~= realTime, spks.channel==12));
%         indxOfSpk = lots(1+ round(length(lots)*rand(1,1)));
%         subplot(5,10,ii)
%         plot(spks.context(:,indxOfSpk));
%         hold on;
%         plot(ones(124,1)*(-spks.thresh(indxOfSpk)+mean(spks.context(:,indxOfSpk))),'r');
%         axis tight;
%     end
% end
