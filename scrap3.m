channelList = NB_slices{1}.channel;
dummy = zeros(10,6);
h=imagesc(dummy);
colormap(gray); colorbar;
set(gca, 'clim', [0 length(channelList)], 'tickdir', 'out');
axis square;
for  ii = 1: length(channelList)
    dummy(find(ch6x10_ch8x8_60 == channelList(ii)+1)) = ii;
    set(h, 'cdata', dummy);
    drawnow; pause(0.5);
end

%%
foc_idx = find((spks.time>151.7 & spks.time< 151.8)&spks.channel == 29);

foc.time = spks.time(foc_idx);
foc.channel = spks.channel(foc_idx);
foc.height = spks.height(foc_idx);
foc.width = spks.width(foc_idx);
foc.context = spks.context(:,foc_idx);
foc.thresh = spks.thresh(foc_idx);
seeContexts(foc_idx,spks);
% cleanspikes(foc);