% -------------------------------------------------------------------------------------
% Purpose: Analyse stim responses and choose appropriate stim & rec. site
% Here, I shall use the methodology described by Samora.
% Author: Sreedhar S Kumar
% Date: 27.06.2013
%--------------------------------------------------------------------------------------
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

datName = '130625_4205_stimEfficacy.spike';
spikes=loadspike(datName,2,25);

%% Global rate; (fig(1): global firing rate)
% sliding window; bin width = 1s
[counts,timeVec] = hist(spikes.time,[0:ceil(max(spikes.time))]);
figure(1); bar(timeVec,counts);
axis tight; xlabel('Time (s)'); ylabel('# spikes'); title('Global firing rate (bin= 1s)');

%% Stimulus locations and time
%Splitting spikes and stim info into channels and analog cells.
%stimTimes is 1x5 cell; each cell has 1x50 stimTimes for each site
for ii=0:63
    if ii<60
        inAChannel{ii+1,1} = spikes.time(spikes.channel==ii);
    else
        inAnalog{ii-59,1} = spikes.time(spikes.channel==ii);
    end
end
% the following info must be automatically gathered from the log file...
% working on that script stim_efficacy.m
nStimSites = 5;
stimSites = cr2hw([35, 21, 46, 41, 58]);
for ii = 1:nStimSites
    stimTimes{ii} = inAnalog{2}(ii:nStimSites:length(inAnalog{2}));
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

%% Measuring pre-stimulus inactivity/periods of silence
% silence_s has a matrix in a cell structure.
% Layer 1 (outer) is a 1x5 cell, each corresponding to each stim site.
% Layer 2 is a 60x50 matrix, each row corresponding to a channel and column
% corresponding to the 50 individual stimuli.

silence_s = cell(1,nStimSites);
for ii = 1:nStimSites
    for jj = 1: size(stimTimes{ii},2)
        for kk = 1:60
            previousTimeStamp = inAChannel{kk}(find(inAChannel{kk}<stimTimes{ii}(jj),1,'last'));
            if isempty(previousTimeStamp) previousTimeStamp = 0; end
            silence_s{ii}(kk,jj) = stimTimes{ii}(jj) - previousTimeStamp;
        end
    end
end

%% Isolating the periStims that follow a period of silence > t (s)
% periStim_selected has the same structure as periStim
periStim_selected = cell(size(periStim));
tSilence_s = 1;
for ii = 1:nStimSites
    [validRows, validCols] = find(silence_s{ii}>tSilence_s);
    for jj = 1: size(validRows,1)
        periStim_selected{ii}{validRows(jj),1}{validCols(jj),1} = periStim{ii}{validRows(jj)}{validCols(jj)};
    end
    
% fixed a bug in retrospective
% If by chance a channel did not have a valid response in the 50th trial,
% that cell array would remain of length 49. There could be a more elegant
% solution. But this patch works for the moment. buggLength is the index of
% such aberrant channels. diffLen is the deficit in length which is then
% appropriately corrected.
    
        buggyLengths = find(cellfun(@length,periStim_selected{ii})<50);
        if buggyLengths
            for kk = 1:length(buggyLengths)
                diffLen = length(stimTimes{ii}) - length(periStim_selected{ii}{buggyLengths(kk)});
                periStim_selected{ii}{buggyLengths(kk)}{end+diffLen} = [];
            end
        end
end


%% Figure 2: General raster
figure(2); 
for ii = 1:60
    plot(inAChannel{ii},ones(size(inAChannel{ii}))*ii,'.','linewidth',1)
    hold on
end
for ii = 1:nStimSites
    switch ii
        case 1
            clr = 'r';
        case 2
            clr = 'g';
        case 3
            clr = 'c';
        case 4
            clr = 'k';
        case 5
            clr = 'm';
    end
line([stimTimes{ii} ;stimTimes{ii}], repmat([0;60],size(stimTimes{ii})),'Color',clr,'LineWidth',1);
end
hold off;
xlabel('Time (s)');
ylabel('Channel #');
title(['Raster plot indicating stimulation at channels [',num2str(stimSites+1),'] (hw+1)']);

%% Binning, averaging and plotting the PSTHs

for ii = 1:nStimSites
    figure(2+ii)
      for jj = 1:60
        bins = -50: 10: 500;
                count = 0;
                for kk = 1:size(stimTimes{ii},2)
                    spikes = periStim_selected{ii}{jj}{kk,1}-stimTimes{ii}(1,kk);
                    if ~isempty(spikes)
                        fr = zeros(size(bins));
                        for mm = 1:length(bins)-1
                            fr(mm) = length(spikes(and(spikes>=bins(mm)*1e-3,spikes<(bins(mm+1)*1e-3))));
                        end
                        count = count + 1;
                        frMat(count,:) = fr;     
                    end
                end
                if count ==0, count=1; end
                subplot(6,10,jj)
                shadedErrorBar(bins,mean(frMat,1),std(frMat),{'k','linewidth',1.5},0);
                axis([-100 500 -0.5 2.5])
                line([0 0],[-0.5 max(2,max(mean(frMat,1)))+max(std(frMat))],'Color','r');
                if ~or(mod(jj,10)==1,jj>50)
                    set(gca,'YTickLabel',[]);
                    set(gca,'XTickLabel',[]);
                elseif jj>51
                    set(gca,'YTickLabel',[]);
                elseif jj~=51
                    set(gca,'XTickLabel',[]);
                end
     end
        set(gcf,'WindowButtonDownFcn','popsubplot')
        set(gcf,'NextPlot','add');
        axes;
        h = title(['Mean PSTHs following stimulation at ',num2str(stimSites(ii)),'(hw). [mean #spikes vs time(ms)]']);
        set(gca,'Visible','off');
        set(h,'Visible','on');
end


%% Move this later: here I will make a choice and try to sort trials based on pre-stimulus inactivity

