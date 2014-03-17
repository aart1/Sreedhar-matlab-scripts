%% Analyzing raw data dents in MEABench

data = loadraw('140311_4513_raw.raw',2);
ch = 25; % hw+1
% slicing by window width
window1e3 = data(ch,1:10*25e3) - 683;
window500 = data(ch,15*25e3:25*25e3) - 683;
window200 = data(ch,30*25e3:40*25e3) - 683;
figure();
figha(1) = subplot(311);
title('1000 ms window'); hold on;
plot(linspace(1,10,length(window1e3)),window1e3);
box off;
figha(2) = subplot(312);
title('500 ms window'); hold on;
plot(linspace(1,10,length(window500)),window500);
box off;
figha(3) = subplot(313);
title('250 ms window'); hold on;
plot(linspace(1,10,length(window200)),window200);
box off;
linkaxes(figha,'x');
zoom xon;
pan xon;
suplabel('time [s]')
suplabel('Voltage [\mu V]','y');

%% More raw data


[~, name] = system('hostname');
if strcmpi(strtrim(name),'sree-pc')
    srcPath = 'D:\Codes\mat_work\MB_data';
elseif strcmpi(strtrim(name),'petunia')
    srcPath = 'C:\Sreedhar\Mat_work\Closed_loop\Meabench_data\Experiments5\misc\';
end
[datName,pathName]=uigetfile('*.raw','Select MEABench Data file',srcPath);
data = cell(4,1);

for ii = 1:4
    datRoot = datName(1:strfind(datName,'.')-1);
    data{ii} = loadraw([pathName,datRoot(1:end-1),num2str(ii),'.raw'],2);
end
    ch = input('Enter a channel no (0-59): ');

windowNone = data{1}(ch,5*25e3:15*25e3)- 683;
window1e3 = data{2}(ch,5*25e3:15*25e3) - 683;
window500 = data{3}(ch,5*25e3:15*25e3) - 683;
window250 = data{4}(ch,5*25e3:15*25e3) - 683;

figure();
figha(1) = subplot(411);
title('No scope','FontSize',16); hold on;
plot(linspace(0,10,length(windowNone)),windowNone);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

figha(2) = subplot(412);
title('1000 ms window','FontSize',16); hold on;
plot(linspace(0,10,length(window1e3)),window1e3);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

figha(3) = subplot(413);
title('500 ms window','FontSize',16); hold on;
plot(linspace(0,10,length(window500)),window500);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

figha(4) = subplot(414);
title('250 ms window','FontSize',16); hold on;
plot(linspace(0,10,length(window250)),window250);
ylim([-25 15]);
set(gca,'TickDir','Out');
set(gca,'FontSize',14);
box off;

linkaxes(figha,'x');
zoom xon;
pan xon;
[~,h4] = suplabel('time [s]');
[~,h5] = suplabel('Voltage [\muV]','y');
set(h4,'FontSize',16);
set(h5,'FontSize',16);


% saving the figure in landscape
h=gcf;
set(h,'PaperPositionMode','auto'); 
set(h,'PaperOrientation','landscape');
set(h,'Position',[50 50 1200 800]);
print(gcf, '-depsc', ['C:\Users\duarte\Desktop\jf_140318\rawData','_ch',num2str(ch),'.eps']);