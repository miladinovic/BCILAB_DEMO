% std_selcomp() - Helper function for std_erpplot(), std_specplot() 
%                       and std_erspplot() to select specific
%                       components prior to plotting. 
% Usage:
%  >> std_selcomp( STUDY, data, cluster, setinds, compinds, comps)
%
% Inputs:
%  STUDY -  EEGLAB STUDY structure.
%  data  -  [cell array] mean data for each subject group and/or data
%           condition. For example, to compute mean ERPs statistics from a  
%           STUDY for epochs of 800 frames in two conditions from three  
%           groups of 12 subjects,
%           >> data = { [800x12] [800x12] [800x12];... % 3 groups, cond 1
%                       [800x12] [800x12] [800x12] };  % 3 groups, cond 2
% cluster - [integer] cluster index
% setinds - [cell array] set indices for each of the last dimension of the
%           data cell array.
%           >> setinds = { [12] [12] [12];... % 3 groups, cond 1
%                          [12] [12] [12] };  % 3 groups, cond 2
% compinds - [cell array] component indices for each of the last dimension 
%           of the data cell array.
%           >> compinds = { [12] [12] [12];... % 3 groups, cond 1
%                           [12] [12] [12] };  % 3 groups, cond 2
% comps    - [integer] find and select specific component index in array
%
% Output:
%  data       - [cell array] data array with the subject or component selected
%  subject    - [string] subject name (for component selection)
%  comp_names - [cell array] component names (for component selection)
%
% Author: Arnaud Delorme, CERCO, CNRS, 2006-
% 
% See also: std_erpplot(), std_specplot() and std_erspplot()

function [data, subject, comp_names] = std_selcomp(STUDY, data, clust, setinds, compinds, compsel)

if nargin < 2
    help std_selcomp;
    return;
end;

optndims = ndims(data{1});
comp_names = {};
subject    = '';

% find and select group
% ---------------------
if isempty(compsel), return; end;
sets   = STUDY.cluster(clust).sets(:,compsel);
comps  = STUDY.cluster(clust).comps(compsel);
%grp    = STUDY.datasetinfo(sets(1)).group;
%grpind = strmatch( grp, STUDY.group );
%if isempty(grpind), grpind = 1; end;
%data = data(:,grpind);

% find component
% --------------
for c = 1:length(data(:))
    rminds = 1:size(data{c},optndims);
    
    for ind = length(compinds{c}):-1:1
        setindex = STUDY.design(STUDY.currentdesign).cell(setinds{c}(ind)).dataset;
        if compinds{c}(ind) == comps && any(setindex == sets)
            rminds(ind) = [];
        end;
    end;
        
    if optndims == 2
        data{c}(:,rminds) = []; %2-D
    elseif optndims == 3
        data{c}(:,:,rminds) = []; %3-D
    else
        data{c}(:,:,:,rminds) = []; %3-D
    end;
    comp_names{c,1} = comps;
end;
% for c = 1:size(data,1)
%     for ind = 1:length(compinds{1,grpind})
%         if compinds{1,grpind}(ind) == comps & any(setinds{1,grpind}(ind) == sets)
%             if optndims == 2
%                  data{c} = data{c}(:,ind);
%             else data{c} = data{c}(:,:,ind);
%             end;
%             comp_names{c,1} = comps;
%         end;
%     end;
% end;
subject = STUDY.datasetinfo(sets(1)).subject;
