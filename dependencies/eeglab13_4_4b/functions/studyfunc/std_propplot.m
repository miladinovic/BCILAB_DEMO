% std_propplot() - Command line function to plot component cluster 
%                  properties for a STUDY set. 
%                  Displays mean cluster scalp map, ERP, ERSP; 
%                  dipole model, spectrum, and ITC in one figure 
%                  per cluster. Only meaasures computed during 
%                  pre-clustering (by pop_preclust() or std_preclust()) 
%                  are plotted. Called by pop_clustedit().
%                  Leaves the plotted grand mean cluster measures 
%                  in STUDY.cluster for quick replotting.
% Usage:    
%             >> [STUDY] = std_propplot(STUDY, ALLEEG, clusters);  
% Inputs:
%   STUDY      - STUDY set including some or all EEG datasets in ALLEEG.
%   ALLEEG     - vector of EEG dataset structures including the datasets 
%                in the STUDY. Yypically created using load_ALLEEG().  
%
% Optional inputs:
%   clusters   - [numeric vector | 'all'] -> cluster numbers to plot.
%                Else 'all' -> make plots for all clusters in the STUDY 
%                {default: 'all'}.
% Outputs:
%   STUDY      - the input STUDY set structure modified with the plotted 
%                cluster mean properties to allow quick replotting (unless 
%                cluster means already existed in the STUDY).  
% Example:
%              % Plot mean properties of Cluster 5 in one figure. 
%              >> [STUDY] = std_propplot(STUDY,ALLEEG, 5);
%
% See also:  pop_clustedit() 
%
% Authors:  Arnaud Delorme, Hilit Serby, Scott Makeig, SCCN/INC/UCSD, 2005

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, arno@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function STUDY = std_propplot(STUDY, ALLEEG,  varargin)

icadefs; % read EEGLAB defaults
warningon = 0;

if iscell(varargin{1}) % channel plotting
    chans = varargin{1};
    for k = 1: length(chans);
        figure
        orient tall
        set(gcf,'Color', BACKCOLOR);
        subplot(2,2,1),
        try,
            STUDY = std_erpplot(STUDY,ALLEEG, 'channels', chans(k), 'mode', 'together', 'plotmode', 'condensed' );
            erpAxisHangle = gca;            
        catch
            axis off; text(0.5, 0.5, 'No ERP information', 'horizontalalignment', 'center');
            warningon = 1;
        end
        subplot(2,2,2),
        try,
            [STUDY] = std_erspplot(STUDY,ALLEEG, 'channels', chans(k), 'mode', 'together', 'plotmode', 'condensed' );            
        catch, 
            axis off; text(0.5, 0.5, 'No ERSP information', 'horizontalalignment', 'center');
            warningon = 1;
        end
        subplot(2,2,3),
        try,
            STUDY = std_specplot(STUDY,ALLEEG, 'channels', chans(k), 'mode', 'together', 'plotmode', 'condensed');
        catch
            axis off; text(0.5, 0.5, 'No spectral information', 'horizontalalignment', 'center');
            warningon = 1;
        end
        subplot(2,2,4),
        try,
            [STUDY] = std_itcplot(STUDY,ALLEEG, 'channels', chans(k), 'mode', 'together', 'plotmode', 'condensed' );
        catch, 
            axis off; text(0.5, 0.5, 'No ITC information', 'horizontalalignment', 'center');
            warningon = 1;
        end

        %subplot('position', [0.77 0.16 0.15 0.28]),
        maintitle = ['Channel ''' chans{k} ''' average properties' ];
        a = textsc(maintitle, 'title'); 
        set(a, 'fontweight', 'bold');     

        if warningon
            disp('Some properties could not be plotted. To plot these properties, first');
            disp('include them in pre-clustering. There, specify 0 dimensions if you do');
            disp('now want a property (scalp map, ERSP, etc...) to be included');
            disp('in the clustering procedure. See the clustering tutorial.');
        end;

    end  % Finished all conditions
    return;
end;    

% Set default values
cls = 1:length(STUDY.cluster); % plot all clusters in STUDY

if length(varargin) > 0
    if length(varargin) == 1, varargin{2} = varargin{1}; end; % backward compatibility
    if isnumeric(varargin{2})
        cls = varargin{2};
    elseif isstr(varargin{2}) & strcmpi(varargin{2}, 'all')
        cls = 1:length(STUDY.cluster);
    else
        error('cluster input should be either a vector of cluster indices or the keyword ''all''.');
    end
end

len = length(cls);
% Plot clusters mean properties
for k = 1: len
    if k == 1
        try 
            % optional 'CreateCancelBtn', 'delete(gcbf); error(''USER ABORT'');', 
            h_wait = waitbar(0,['Computing cluster properties ...'], 'Color', BACKEEGLABCOLOR,'position', [300, 200, 300, 48]);
        catch % for Matlab 5.3
            h_wait = waitbar(0,['Computing cluster properties ...'],'position', [300, 200, 300, 48]);
        end
    end  
    warningon = 0;
    figure
    orient tall
    set(gcf,'Color', BACKCOLOR);
    subplot(2,3,1),
    try,
        STUDY = std_topoplot(STUDY,ALLEEG, 'clusters', cls(k), 'mode', 'together', 'figure', 'off');
    catch
        axis off; text(0.5, 0.5, 'No scalp map information', 'horizontalalignment', 'center');
        warningon = 1;
    end
    waitbar(k/(len*6),h_wait)
    subplot(2,3,2),
    try,
        STUDY = std_erpplot(STUDY,ALLEEG, 'clusters', cls(k), 'mode', 'together', 'plotmode', 'condensed' );
        erpAxisHangle = gca;
    catch
        axis off; text(0.5, 0.5, 'No ERP information', 'horizontalalignment', 'center');
        warningon = 1;
    end
    waitbar((k*2)/(len*6),h_wait)
    subplot(2,3,3),
    try,
        [STUDY] = std_erspplot(STUDY,ALLEEG, 'clusters', cls(k), 'mode', 'together', 'plotmode', 'condensed' );
    catch, 
        axis off; text(0.5, 0.5, 'No ERSP information', 'horizontalalignment', 'center');
        warningon = 1;
    end
    waitbar((k*3)/(len*6),h_wait)
    axes('unit', 'normalized', 'position', [0.1 0.16 0.2 0.28]); %subplot(2,3,4),
    try,
        STUDY = std_dipplot(STUDY,ALLEEG, 'clusters', cls(k), 'mode', 'apart', 'figure', 'off'); set(gcf,'Color', BACKCOLOR);
    catch
        axis off; text(0.5, 0.5, 'No dipole information', 'horizontalalignment', 'center');
        warningon = 1;
    end
    waitbar((k*4)/(len*6),h_wait)
    subplot(2,3,5),
    try,
        STUDY = std_specplot(STUDY,ALLEEG, 'clusters', cls(k), 'mode', 'together', 'plotmode', 'condensed');
    catch
        axis off; text(0.5, 0.5, 'No spectral information', 'horizontalalignment', 'center');
        warningon = 1;
    end
    waitbar((k*5)/(len*6),h_wait)
    subplot(2,3,6),
    try,
        [STUDY] = std_itcplot(STUDY,ALLEEG, 'clusters', cls(k), 'mode', 'together', 'plotmode', 'condensed' );
    catch, 
        axis off; text(0.5, 0.5, 'No ITC information', 'horizontalalignment', 'center');
        warningon = 1;
    end
    waitbar((k*6)/(len*6),h_wait);
    %subplot('position', [0.77 0.16 0.15 0.28]),
    maintitle = ['Cluster '''  STUDY.cluster(cls(k)).name ''' mean properties (' num2str(length(STUDY.cluster(cls(k)).comps)) ' comps).' ];
    a = textsc(maintitle, 'title'); 
    set(a, 'fontweight', 'bold');     
    set(gcf,'name',maintitle);
    if warningon
        disp('Some properties could not be plotted. To plot these properties, first');
        disp('include them in pre-clustering. There, specify 0 dimensions if you do');
        disp('not want a property (scalp map, ERSP, etc...) to be included');
        disp('in the clustering procedure. See the clustering tutorial.');
    end;
    
end  % Finished all conditions

if ishandle(erpAxisHangle) % make sure it is a valid graphics handle
    legend(erpAxisHangle,'off');
    
    
    set(erpAxisHangle,'YTickLabelMode','auto');
    set(erpAxisHangle,'YTickMode','auto');
end;
delete(h_wait)

