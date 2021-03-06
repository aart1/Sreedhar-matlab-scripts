%A function that removes artifacts from data structure ls.
% For a given (set of) channels, for a given time around a trigger, remove
% all detected spikes. Mainly to clean up stimulaion artifacts
% The removal is making such that I take bins around stimulation (the
% extend from, Pre to Post trigger) and bins after the Post trigger to the
% next trigger. Then I make a histogram of the actual spiking data and
% check which spikes fall into the bins with the pre and Post trigger time.
%Consequentially those 'spikes' are  removed.
% 
% 
% INPUT
% ls:              The structure with the spike information that is
%                  corrupted by some artifacts
%  
% CHANNELS         The channels for which the artifact cleaning should be
%                  applied. Use eg hw2cr([0:59]) as input to define the
%                  whole array
% 
% Trigger_times    Timepoints of triggers around which an artifact should
%                  be cleaned
%
% Pre_trigger,     Time before and after each trigger where all spikes on the defined  
%Post_trigger      channels should be deleted. BOTH IN MSEC!
% 
%
%
%OUTPUT:           ls_new, the artifac cleaned data
% 
% %Make sure that EITHER I don't include the analog channels in removing
%    %"spikes" or that I choose the actual times to be larger than the
%   %triggers, and not equal. Becuase otherwise I might risk deleting
%    %stimulus triggers by setting the prewindow to 0 
%
%
%
% 
%function ls_new = Remove_artifact(ls,CHANNELS,Trigger_times,Pre_trigger, Post_trigger) 



function ls_new = Remove_artifact(ls,CHANNELS,Trigger_times,Pre_trigger, Post_trigger)

nr_channels = length(CHANNELS);

%If I work on all channels, this makes the removing easier
if nr_channels>=60
    all_channels_bool = true;
else
    all_channels_bool = false;
end

nr_triggers   = length(Trigger_times);
nr_spikes_old = size(ls.time,2); 

HW_channels = cr2hw(CHANNELS);

%I define bins with the time around the stimulation (very small bins, to
%remove artifacts) and the time inbetween two stimulations (larger windows)
%the odd bin numbers (1,3,5,...) are those bins where artifacts should be
%removed
for ii=1:nr_triggers
    stim_artifact_vector((ii-1)*2+1)  = Trigger_times(ii)-Pre_trigger/1000;
    stim_artifact_vector((ii-1)*2+2)  = Trigger_times(ii)+ Post_trigger/1000;
end


%make a binning of all the electrode spikes with the stim_artifact_vector
%histc makes a binning with the edges of the bin vector.
if (all_channels_bool)
    all_el_data_ind  = find(ls.channel<60);
    all_el_data      = ls.time(all_el_data_ind);
    [n ind_vec]=histc(all_el_data,stim_artifact_vector);  %n gives the no in each bin, ind_vec is a length(all_el_data) vector with 0 if the current entry in all_el_data does not belong to any bin, or
                                                       % the no of the bin otherwise
else
    all_el_data_ind = [];
    for ii=1:nr_channels
        all_el_data_ind = [all_el_data_ind find(ls.channel==HW_channels(ii))];
    end
        all_el_data     = ls.time(all_el_data_ind);
        [n ind_vec]=histc(all_el_data,stim_artifact_vector); 
end

                                                       
all_rem_ind =[];
for ii=1:nr_triggers
    if find(n((ii-1)*2+1))
%i.e. if one of the odd bins (those where a stimualtion artifact can be)
%has actually spikes
        all_rem_ind = [all_rem_ind find(ind_vec==(ii-1)*2+1)];
    end
end
        
       


%remove the unwanted spikes
ls.time(all_el_data_ind(all_rem_ind))   = [];
ls.channel(all_el_data_ind(all_rem_ind))= [];


ls_new        = ls;
nr_spikes_new = size(ls_new.time,2);

spikes_removed = nr_spikes_old - nr_spikes_new











%%Obsolete
% for ii=1:nr_triggers
%     
%     %show the current loop process in steps of 100 trials
%       if ~rem(ii,100)
%          ii
%       end
% 
%     remove_spikes_ind = find(ls.time>Trigger_times(ii)-Pre_trigger/1000 & ls.time<Trigger_times(ii)+Post_trigger/1000);
%     
%     %if I work on all channels, just remove all the found spikes
%     if all_channels_bool
%         ls.time(remove_spikes_ind)    = [];
%         ls.channel(remove_spikes_ind) = [];
%     else
%        [channel_val ch_ind artifact_ind]=intersect(HW_channels,ls.channel(remove_spikes_ind));
%        %the index artifact_in can be used to delete the desired spiketimes
%        ls.channel(remove_spikes_ind(artifact_ind)) = [];
%        ls.time(remove_spikes_ind(artifact_ind))    = [];
%     end
% end
%     


