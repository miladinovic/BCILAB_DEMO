%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REAL-TIME BCILAB/SIFT INTERFACE DEMO SCRIPT
%
% This script demonstrates a beta interface between BCILAB 
% (Christian Kothe: www.sccn.ucsd.edu/wiki/BCILAB) and SIFT (Tim Mullen:  
% www.sccn.ucsd.edu/wiki/SIFT) to perform real-time data extraction,
% cleaning, connectivity modeling and visualization.
% 
% This script was prepared for the following whitepaper/demonstration:
% [1] Tim Mullen, Christian Kothe, Yu Chi, Tzyy-Ping Jung,
%     and Scott Makeig. "Real-Time Estimation and 3D Visualization of Sparse 
%     Multivariate Effective Connectivity Using Wearable EEG." July 15th,
%     IEEE EMB/CAS/SMC Workshop on Brain-Machine-Body Interfaces. 34th 
%     Annual International IEEE EMBS Conference of the IEEE Engineering in 
%     Medicine and Biology Society (IEEE EMBS).
%
% Please refer to [1] when using any functionality from this demo.
% 
% Copyright Tim Mullen, Christian Kothe, July 2012, SCCN/INC/UCSD
%C
% Author: Tim Mullen,       July 2012, SCCN/INC/UCSD
%         Christian Kothe,  July 2012, SCCN/INC/UCSD
%
% This function is part of the Source Information Flow Toolbox (SIFT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tip: to create an evaluable list of good channels (for flt_selchans) try this:
% hlp_tostring(setdiff_bc({signal.chanlocs.labels},badchannels))

%% SET UP CONFIGURATION OPTIONS
CALIB_EPOCH      = [0 10]; %[0 10]; %[0 10]; % time range (sec) to extract from calibration dataset for training
TRAIN_ONLY       = false;  % if set, run pipeline on TrainingDataFile only. Result dataset will be stored in cleaned_data
RUN_LSL          = false;           % If RUN_LSL = true, then stream 'online' from device; If RUN_LSL=false then playback TestingDataFile (below)

PAUSE_DELAY     =  0.1;   % delay between loops

% Source reconstruction options (leave disabled)
COLOR_SOURCE_ROI = true;          % this will use special meshes for coloring ROIs
%HEAD_MODEL_NAME  = 'resources:/headmodels/standard-Colin27-385ch.mat'; % THIS ONE USED FOR EMBC (348 electrode)
% %'data:/mobilab/Cognionics_64_HeadModelObj_3751.mat'; %'data:/mobilab/Cognionics_64_HeadModelObj_11997.mat';  %'resources:/headmodels/standard-Colin27-385ch.mat';             % path to head model object for source reconstruction (relative to 'datapath'). Leave empty if you aren't doing source reconstruction

% old cognionics 64-channel montage (March, 2013)
% HEAD_MODEL_NAME = 'data:/mobilab/Cognionics_64_HeadModelObj_3751.mat';  %

% New Cognionics montage (May, 2013)
HEAD_MODEL_NAME = 'data:/mobilab/Cognionics64_Channel_new_montage_noseX_HeadModelObj_3751.mat';

%HEAD_MODEL_NAME = 'data:/mobilab/385_Channel_noseY_HeadModelObj_3751.mat'; %'resources:/headmodels/nose_y_old_standard-Colin27-385ch.mat';

% NFT head model (doesn't work)
%HEAD_MODEL_NAME = 'data:/mobilab/385_Channel_noseX_HeadModelObj_3751_NFT.mat';

% Establish file paths
% NOTE: all paths are relative to 'datapath' which is a
% platform-independent path which itself can be relative to bcilab root
% folder (i.e. data:/ is the userdata folder in the bcilab root dir)
datapath         = 'data:/';       % this is relative to the BCILAB root dir
TrainingDataFile = 'sim_orica_64_ch_blinks.set'; %'sim_orica_8_ch_varsig_2it_blinks_2min.set';%'sim_orica_8_ch_varsig_fast.set';%'sim_orica_8_ch_varsig.set';%'sim_orica_8_ch_training.set';%'Cognionics_64_Flanker_85_265.set'; %'sim_orica_64_ch_training.set'; %'ssVEP_18_ch.set'; % 'sim_orica_64_ch_fwd.set'; %'Cognionics_64_Flanker.set'; %'sim_orica_8_ch_allsub.set'; %'sim_orica_8_ch_training.set'; %'calibration_new.set'; %'Cognionics_64_training.set'; %'calibration.xdf'; %'Cognionics_64_training.set'; %'Cognionics_64_Flanker.set'; %'Cognionics_64_Flanker_85_265.set'; 'Cognionics_64_SIMULATION_one_source.set'; %'Cognionics_64_Flanker_85_265.set';  %'Cognionics_64_Flanker.set';  %'Cognionics_64_Flanker_0_10.set'; %'Cognionics_64_Flanker.set'; %'Cognionics_64_training.set'; %'Cognionics_64_Flanker_85_265.set'; %'Cognionics_64_training.set'; %'calibration_mindo.xdf'; % %'calibration.xdf'; %'Cognionics_Pyramind_demo.set'; %'clean_reversed.xdf'; %'noisy.xdf'; %'Cognionics_Pyramind_demo.set';             % this is the relative path to the calibration dataset
TestingDataFile  = 'sim_orica_64_ch_blinks.set'; %sim_orica_8_ch_varsig_2it_blinks_2min.set';%'sim_orica_8_ch_varsig_4it.set'; %'sim_orica_8_ch_varsig_fast.set';%'Cognionics_64_Flanker_85_265.set'; %'sim_orica_64_ch_training.set'; %'ssVEP_18_ch.set'; % 'sim_orica_64_ch_testing.set'; %'Cognionics_64_Flanker.set'; %'sim_orica_8_ch_allsub.set'; %'Cognionics_64_Flanker_85_265.set'; %'calibration_new.set'; %'calibration_new.set'; %'testing_mike_prebbc.xdf';%'Cognionics_64_testing.set'; %'Cognionics_64_Flanker.set';  %'calibration_old1.xdf'; %'Cognionics_64_testing.set'; %'Cognionics_64_SIMULATION_manysources_nocsdsaved.set'; %'Cognionics_64_Flanker.set'; %'Cognionics_64_SIMULATION.set'; %'Cognionics_64_Flanker.set'; %'Cognionics_64_Flanker_85_265.set'; %'Cognionics_64_Flanker.set'; %'Cognionics_64_testing.set'; %'testing.xdf'; %'Cognionics_Pyramind_demo.set'; %'clean_reversed.xdf'; %'noisy.xdf'; %'Cognionics_Pyramind_demo.set';             % this is an optional path to a dataset to playback (if RUN_LSL = false)
GUI_CONFIG_NAME  = 'METACP_CFG_ORICA_SIM_ONLINE.mat'; %'Cognionics_64_Pipeline_Demo_METACP_CFG.mat'; %'BMCFG_RECORD_STABILITY_TEST_VBLORETA.mat'; %'Cognionics_64_Pipeline_Demo_METACP_CFG.mat'; %'EMBC_PAPER_METACP_OPTS_NOSOURCES.mat'; %'DEMO_SOURCELOC_METACP_CFG_CombineROIs_nodelay_manyROIs_autochansel.mat'; %'SIMULATION_TEST_LORETA.mat'; %'DEMO_SOURCELOC_METACP_CFG_AllVertices.mat'; %'DEMO_SOURCELOC_METACP_CFG_CombineROIs.mat'; %'DARPA_DEMO_METACP_CFG_FEWCHANS.mat';             % relative path to a default pipeline configuration
GUI_BRAINMOVIE_CONFIG_NAME = 'BMCFG_JAG.mat'; %'DARPA_DEMO_BM_CFG.mat'; %'DEMO_SOURCELOC_BM_CFG.mat'; %'DARPA_DEMO_BM_CFG.mat';   % relative path to BrainMovie configuration

% Set up the name of the stream we will write to in the workspace
streamname              = 'EEGDATA';
LSL_SelectionProperty   = 'type';  % can also be 'name'
LSL_SelectionValue      = 'EEG';

% this is the name of the stream that carries SIFT models
outstream_name = 'SIFT-Models';

% ORICA-specific testing options (validation)
TRUE_MIXING_MATRIX   = 'calibData.icawinv_true';     % can also be a matrix or []
TRUE_SPHERING_MATRIX = 'calibData.icasphere_true';   % can also be a matrix or []
RUN_PCA = false;
NUM_PCS = 8;

%% load head model object
if ~isempty(HEAD_MODEL_NAME)
    hmObj = headModel.loadFromFile(env_translatepath(HEAD_MODEL_NAME));
    % load meshes for visualization
    surfData    = load(hmObj.surfaces);
    surfData    = surfData.surfData;
    scalpMesh   = surfData(1);
    csfMesh     = surfData(2);
    cortexMesh  = surfData(3);
end

%% load calibration recording
if ~isempty(CALIB_EPOCH)
    calibData = pop_select(exp_eval(io_loadset([datapath TrainingDataFile],'markerchannel',{'remove_eventchns',false})),'time',CALIB_EPOCH);
else
    calibData = exp_eval(io_loadset([datapath TrainingDataFile],'markerchannel',{'remove_eventchns',false}));
end
calibData.data = double(calibData.data);
flt_pipeline('update');

testData = exp_eval(io_loadset([datapath TestingDataFile],'markerchannel',{'remove_eventchns',false}));

if RUN_PCA
    fprintf('Sphering Training data with PCA\n');
%     [calibData.data calibData.icasphere_true] = runpca(calibData.data,NUM_PCS,1);
    rowmeans = mean(calibData.data,2); 
    calibData.data = bsxfun(@minus,calibData.data,rowmeans);

    [E,D] = eig ( calibData.data * calibData.data' / calibData.pnts );
    calibData.icasphere_true = E * real((sqrtm(D))\eye(calibData.nbchan)) * E'; % FIXME: this line is time-consuming
    % Decorrelate data
    calibData.data = calibData.icasphere_true * calibData.data;
    
    
    fprintf('Sphering Test data with PCA\n');
%     [calibData.data calibData.icasphere_true] = runpca(calibData.data,NUM_PCS,1);
    rowmeans = mean(testData.data,2); 
    testData.data = bsxfun(@minus,testData.data,rowmeans);

    [E,D] = eig ( testData.data * testData.data' / testData.pnts );
    testData.icasphere_true = E * real((sqrtm(D))\eye(testData.nbchan)) * E'; % FIXME: this line is time-consuming
    % Decorrelate data
    testData.data = testData.icasphere_true * testData.data;
end

calibData.icawinv = [];
% calibData.icaact = [];
calibData.icaweights = [];

testData.icawinv = [];
% testData.icaact = [];
testData.icaweights = [];

%% start LSL streaming
if RUN_LSL == true
    run_readlsl('MatlabStream',streamname,'SelectionProperty',LSL_SelectionProperty,'SelectionValue',LSL_SelectionValue);
end
%% ... OR read from datafile
if RUN_LSL == false
    run_readdataset('MatlabStream',streamname,'Dataset',testData);
end

%% initialize some variables
[benchmarking.preproc     ...
 benchmarking.modeling    ...
 benchmarking.brainmovie  ...
 benchmarking.viscsd      ...
 benchmarking.lsl] = deal(NaN);
 
% % Store time for benchmark
% recordingTime = 60;
% benchmarktime = zeros(1,recordingTime * testData.srate);

newPipeline     = true;
newBrainmovie   = true;
specOpts        = [];
gobj            = [];

% create a minimal moving average pipeline...
% noflats = exp_eval_optimized(flt_movavg(flt_selchans(calibData,{'FC3', 'FC4', 'FC2', 'FC1', 'C3', 'C4', 'C2', 'C1', 'CP3', 'CP4', 'CP2', 'CP1', 'P3', 'P4', 'P2', 'P1'})));
% noflats = flt_seltypes(calibData,'EEG');
noflats = exp_eval_optimized(flt_movavg(flt_seltypes(calibData,'EEG')));
highpassed   = exp_eval_optimized(flt_fir(noflats,[0.5 1],'highpass'));
goodchannels = exp_eval_optimized(flt_clean_channels('signal',highpassed,'min_corr',0.35,'ignored_quantile',0.3));


%% initialize options
if ~isempty(GUI_CONFIG_NAME) && exist(env_translatepath([datapath GUI_CONFIG_NAME]),'file')
    % try to load a configuration file
    io_load([datapath GUI_CONFIG_NAME]);
else
    % manually set some defaults
    opts.miscOptCfg.dispBenchmark  = true;
    opts.miscOptCfg.doSIFT         = [];
    opts.holdPipeline              = false;
    opts.exitPipeline              = false;

    opts.siftPipCfg.preproc.verb = 0;

    % set some defaults
    opts.fltPipCfg = ...
        struct('DataCleaning', ...
                struct('RetainPhases',true, ...
                       'HaveBursts', true, ...
                       'HaveChannelDropouts', false, ...
                       'DataSetting', 'drycap'), ...
                'Rereferencing', {{}}); 

    opts.siftPipCfg = ...
        struct('preproc', ...
                    struct('normalize', ...
                        struct('verb', 0, ...
                               'method', {{'time'}})));
                           
end

% additional options regarding brainmovie node/edge adaptation
opts.adaptation.adaptationHL    = 10;  % HL of exp. win. MA in frames
opts.adaptation.updateInterval  = 1;
opts.adaptation.bufferTime      = 1;

% set the arg_direct flag to true
opts = arg_setdirect(opts,true);

%% initialize the Meta Control Panel
opts.fltPipCfg.psourceLocalize.hmObj = HEAD_MODEL_NAME;
opts.miscOptCfg.dispCSD.hmObj        = HEAD_MODEL_NAME;
if ~isempty(HEAD_MODEL_NAME)
    calibData.srcpot = 1; % allow sources
end
figHandles.MetaControlPanel = gui_metaControlPanel(calibData,opts);
waitfor(figHandles.MetaControlPanel,'UserData','initialized');

% disable holdPipeline
opts.holdPipeline = false;

% insert true mixing matrix
% if ~isempty(TRUE_MIXING_MATRIX)
%     if ischar(TRUE_MIXING_MATRIX)
%         TRUE_MIXING_MATRIX = eval(TRUE_MIXING_MATRIX);
%     end
% end
% if ~isempty(TRUE_SPHERING_MATRIX)
%     if ischar(TRUE_SPHERING_MATRIX)
%         TRUE_SPHERING_MATRIX = eval(TRUE_SPHERING_MATRIX);
%     end
% end
opts.fltPipCfg.porica.perfmetrics.convergence.A = 'signal.icawinv_true'; %TRUE_MIXING_MATRIX;
opts.fltPipCfg.porica.perfmetrics.convergence.spheremat = 'signal.icasphere_true'; %TRUE_SPHERING_MATRIX;

%% initialize the output stream
if opts.miscOptCfg.streamLSL
    samplingrate = 1;
    stream_outlet = onl_lslsend_init(outstream_name,samplingrate);
end

%% Initialize figures
figHandles.specDisplay      = [];
figHandles.BMDisplay        = [];
figHandles.BMControlPanel   = [];

%% try to load a BrainMovie configuration
try 
    io_load([datapath GUI_BRAINMOVIE_CONFIG_NAME]);
    BMCFG.BMopts.bmopts_suppl = {'title',{'Multivariate ','Granger Causality  '}};
    BMCFG.BMopts.caption = true;
catch
    BMCFG = struct([]);
end

BMRenderMode = 'init_and_render';

% Only run a pass through calibration data
if TRAIN_ONLY
    cleaned_data = exp_eval(flt_pipeline('signal',calibData,opts.fltPipCfg));
    return;
end

localizeSources = opts.fltPipCfg.psourceLocalize.arg_selection;


% profile on
%% Main loop
% -------------------------------------------------------------------------
while ~opts.exitPipeline
    
  
    
        if newPipeline
            
            % create a new pipeline on training data
            fprintf('Pipeline changed\n');
            
%             opts.fltPipCfg.porica.perfmetrics.convergence.A = TRUE_MIXING_MATRIX;
%             opts.fltPipCfg.porica.perfmetrics.convergence.spheremat = TRUE_SPHERING_MATRIX;
            
            cleaned_data = exp_eval(flt_pipeline('signal',calibData,opts.fltPipCfg));
                        
            pipeline     = onl_newpipeline(cleaned_data,streamname);
            newPipeline  = false;

            if opts.miscOptCfg.streamLSL
                % send the options structure
                onl_lslsend(opts,stream_outlet);
            end
            
            localizeSources = opts.fltPipCfg.psourceLocalize.arg_selection;
            bpfig = [];
        end

        if opts.holdPipeline
            % pause the pipeline
            pause(1);
            continue;
        end

        % grab a chunk of data from the stream and preprocess it
        % ---------------------------------------------------------------------
        prepbench = tic;
        timeSeriesFields = {};
        if isfield(opts.fltPipCfg,'psourceLocalize') && localizeSources
            timeSeriesFields =  [timeSeriesFields {'srcpot'}];
        end
        if isfield(opts.fltPipCfg,'psourceLocalize') ...
                && localizeSources ...
                && opts.fltPipCfg.psourceLocalize.keepFullCsd
            timeSeriesFields =  [timeSeriesFields {'srcpot_all'}];
        end
        [eeg_chunk,pipeline] = onl_filtered(pipeline, ...
                                            round(opts.miscOptCfg.winLenSec*cleaned_data.srate), ...
                                            opts.miscOptCfg.suppress_console_output, ...
                                            timeSeriesFields);
        benchmarking.preproc = toc(prepbench); 
        
        % visualize the current source density
        if localizeSources && opts.miscOptCfg.dispCSD.arg_selection
            viscsdbench = tic;
            if size(eeg_chunk.data,2) ~= size(eeg_chunk.srcpot_all,2)
                keyboard;
            end
            if ~isobject(gobj)
                gobj = [];
            end
            gobj = vis_csd(opts.miscOptCfg.dispCSD,'hmObj',eeg_chunk.hmObj,'signal',eeg_chunk,'gobj',gobj,'cortexMesh',eeg_chunk.dipfit.reducedMesh);
            benchmarking.viscsd = toc(viscsdbench);
        else
            if isobject(gobj)
                gobj = []; end
            benchmarking.viscsd = NaN;
        end
        
        % model the chunk via sift
        % ---------------------------------------------------------------------
        if opts.miscOptCfg.doSIFT.arg_selection
            try
                % force the modeling window length to agree with chunk length
                opts.siftPipCfg.modeling.winlen = opts.miscOptCfg.winLenSec;
                
                % import ROI Names
                if strcmpi(opts.siftPipCfg.preproc.sigtype.arg_selection,'sources')
                    opts.siftPipCfg.preproc.varnames = eeg_chunk.roiLabels;
                end
                
                % select a subset of channels
                if ~isempty(opts.miscOptCfg.doSIFT.channelSubset)
                    [dummy eeg_chunk] = evalc('hlp_scope({''disable_expressions'',1},@flt_selchans,''signal'',eeg_chunk,''channels'',opts.miscOptCfg.doSIFT.channelSubset,''orderPreservation'',''dataset-order'',''arg_direct'',true)');
                end
                
                % run the SIFT modeling pipeline
                siftbench = tic;
                [eeg_chunk cfg] = hlp_scope({'is_online',1},@onl_siftpipeline,'EEG',eeg_chunk,opts.siftPipCfg);
                benchmarking.modeling = toc(siftbench);
                
                if eeg_chunk.pnts == 0
                    fprintf('No data!\n');
                    pause(0.01);
                    continue;
                end
                
%                 fprintf('serialization (CONN+CSD): %0.6g\n',toc);
        
            catch err
                hlp_handleerror(err);
                pause(0.1);
                continue;
            end
            
            % visualize the brainmovie
            % -------------------------------------------------------------
            if opts.miscOptCfg.doSIFT.dispBrainMovie.arg_selection

                if newBrainmovie ...
                    | isempty(ishandle(figHandles.BMDisplay)) ...
                    | ~ishandle(figHandles.BMDisplay)

                    % initialize brainmovie
                    if ~isempty(BMCFG)
                        BMCFG.showNodeLabels.nodelabels = eeg_chunk.CAT.curComponentNames;
                        figHandles.BMControlPanel = gui_causalBrainMovie3D_online(eeg_chunk,eeg_chunk.CAT.Conn,struct('arg_direct',0),BMCFG,'timeRange',[]);
                    else
                        figHandles.BMControlPanel = gui_causalBrainMovie3D_online(eeg_chunk,eeg_chunk.CAT.Conn,struct('arg_direct',0),'showNodeLabels',{'nodelabels',eeg_chunk.CAT.curComponentNames});
                    end
                    waitfor(figHandles.BMControlPanel,'UserData','newBrainmovie');

                    % set the closing behavior
                    set(figHandles.BMControlPanel,'CloseRequestFcn','evalin(''base'',''figHandles.BMControlPanel = [];''); delete(gcbf);');

                    BM_CFG_CHANGED       = true;
                    newBrainmovie        = false;
                    figHandles.BMDisplay = [];
                    BMStateVars          = [];
                end

                if BM_CFG_CHANGED
                    BMRenderMode    = 'init_and_render';
                    BMStateVars     = [];
                    
                    % determine whether to adapt limits
                    adapt_nodeSizeDataRange  = isempty(BMCFG.BMopts.graphColorAndScaling.nodeSizeDataRange)  && opts.miscOptCfg.doSIFT.dispBrainMovie.adaptBrainMovieLimits;
                    adapt_edgeSizeDataRange  = isempty(BMCFG.BMopts.graphColorAndScaling.edgeSizeDataRange)  && opts.miscOptCfg.doSIFT.dispBrainMovie.adaptBrainMovieLimits;
                    adapt_nodeColorDataRange = isempty(BMCFG.BMopts.graphColorAndScaling.nodeColorDataRange) && opts.miscOptCfg.doSIFT.dispBrainMovie.adaptBrainMovieLimits;
                    adapt_edgeColorDataRange = isempty(BMCFG.BMopts.graphColorAndScaling.edgeColorDataRange) && opts.miscOptCfg.doSIFT.dispBrainMovie.adaptBrainMovieLimits;
                    
                    % clear state
                    nodeSizeState   = [];
                    nodeColorState  = [];
                    edgeSizeState   = [];
                    edgeColorState  = [];
                    
                    
                    % reset flag
                    BM_CFG_CHANGED = false;
                end
    
                % Handle special rendering of source meshes and colors
                % ---------------------------------------------------------
                if COLOR_SOURCE_ROI 
                    BG_COLOR = [0.1 0.1 0.1];
                    
                    if BMCFG.BMopts.Layers.custom.arg_selection
                        BMCFG.BMopts.Layers.custom.volumefile = eeg_chunk.dipfit.surfmesh;
                        BMCFG.BMopts.Layers.custom.meshcolor  = hlp_getROIVertexColorTable( ...
                                size(eeg_chunk.dipfit.surfmesh.vertices,1), ...
                                eeg_chunk.roiVertices,BG_COLOR,@(x)distinguishable_colors(x,BG_COLOR));
                    end
                    
                    % if the cortex mesh is a custom mesh with 'constant'
                    % coloring...
                    if strcmpi(BMCFG.BMopts.Layers.cortex.cortexres,'custommesh') ...
                       && strcmp(BMCFG.BMopts.Layers.cortex.cortexcolor.arg_selection,'Constant')
                            % ... replace the colors with ROI coloring
                            BMCFG.BMopts.Layers.cortex.cortexcolor.colormapping = ...
                                hlp_getROIVertexColorTable( ...
                                    size(eeg_chunk.dipfit.surfmesh.vertices,1), ...
                                    eeg_chunk.roiVertices,BG_COLOR,@(x)distinguishable_colors(x,BG_COLOR));
%                         {hmObj.atlas.label, hlp_getROIColorTable(hmObj.atlas.label,eeg_chunk.roiLabels,[0.5 0.5 0.5],[1 0 0])};
                    end
                end
                
                % Render the Brain Movie
                % ---------------------------------------------------------
                bmbench = tic;
                [BMcfg_tmp BMhandles BMout] = ...
                    vis_causalBrainMovie3D(eeg_chunk,eeg_chunk.CAT.Conn,BMCFG, ...
                        'timeRange',[], ...
                        'BMopts',hlp_mergeVarargin(BMCFG.BMopts, ...
                                    'figurehandle',figHandles.BMDisplay, ...
                                    'RenderMode',BMRenderMode, ...
                                    'speedy',true, ...
                                    'InternalStateVariables',BMStateVars));
                benchmarking.brainmovie = toc(bmbench);

                if isempty(BMStateVars)
                    set(figHandles.BMDisplay, 'MenuBar','figure', ...
                                'CloseRequestFcn','evalin(''base'',''figHandles.BMDisplay = [];''); delete(gcbf);', ...
                                'ToolBar','none', 'Name','BrainMovie3D');
                end
                    
                % save figure handle and state
                figHandles.BMDisplay = BMhandles.figurehandle;
                BMStateVars          = BMcfg_tmp.BMopts.vars;
                BMRenderMode         = 'render';

                % adapt the node and edge color/size limits
                % ---------------------------------------------------------
                if opts.miscOptCfg.doSIFT.dispBrainMovie.arg_selection ...
                   && opts.miscOptCfg.doSIFT.dispBrainMovie.adaptBrainMovieLimits
               
                    % adapt BrainMovie node/edge limits
                    if adapt_nodeSizeDataRange
                        [BMCFG.BMopts.graphColorAndScaling.nodeSizeDataRange, nodeSizeState] ...
                            = hlp_adaptMinMaxLimits('values',   BMout.NodeSize,     ...
                                                    'state',    nodeSizeState,      ...
                                                    'adaptOpts',opts.adaptation);
                    end
                    if adapt_nodeColorDataRange
                        [BMCFG.BMopts.graphColorAndScaling.nodeColorDataRange, nodeColorState] ...
                            = hlp_adaptMinMaxLimits('values',   BMout.NodeColor,     ...
                                                    'state',    nodeColorState,      ...
                                                    'adaptOpts',opts.adaptation);
                    end
                    if adapt_edgeSizeDataRange
                        [BMCFG.BMopts.graphColorAndScaling.edgeSizeDataRange, edgeSizeState] ...
                            = hlp_adaptMinMaxLimits('values',   BMout.EdgeSize,     ...
                                                    'state',    edgeSizeState,      ...
                                                    'adaptOpts',opts.adaptation);
                    end
                    if adapt_edgeColorDataRange
                        [BMCFG.BMopts.graphColorAndScaling.edgeColorDataRange, edgeColorState] ...
                            = hlp_adaptMinMaxLimits('values',   BMout.EdgeColor,     ...
                                                    'state',    edgeColorState,      ...
                                                    'adaptOpts',opts.adaptation);
                    end
                    
                end % adaptBrainMovieLimits
                
            else % dispBrainMovie == false
                % close the brainmovie figure if control panel is closed
                try
                    if isempty(figHandles.BMControlPanel) ...
                            || ~ishandle(figHandles.BMControlPanel) ...
                            && ishandle(figHandles.BMDisplay)
                        close(figHandles.BMDisplay);
                    end
                catch
                end
                benchmarking.brainmovie = NaN;
            end
                
            % display the VAR spectrum
            % -------------------------------------------------------------
            if opts.miscOptCfg.doSIFT.dispSpectrum
                try
                    if ishandle(figHandles.specDisplay)
                        % update the SpecViewer
                        vis_autospectrum(specOpts,'FigureHandle',figHandles.specDisplay,'stream',eeg_chunk);
                    else
                        % generate a GUI and initialize SpecViewer
                        [figHandles.specDisplay specOpts] = arg_guidialog(@vis_autospectrum,'Parameters',{'stream',eeg_chunk});

                        set(figHandles.specDisplay,'CloseRequestFcn','evalin(''base'',''opts.miscOptCfg.dispSpectrum=false; figHandles.specDisplay = [];''); delete(gcbf);');
                        specOpts.arg_direct = 0;
                    end
                catch e
                    disp(e.message);
                    opts.miscOptCfg.doSIFT.dispSpectrum = false;
                end
            else
                if ishandle(figHandles.specDisplay)
                    close(figHandles.specDisplay);
                end
            end

        else
            benchmarking.modeling = NaN;
        end
      
        if opts.miscOptCfg.dispBenchmark
            % TODO: implement this as a figure
            vis_benchmark(benchmarking);
            
            % plot ORICA convergence
            if opts.fltPipCfg.porica.arg_selection && isfield(eeg_chunk,'convergence')
                if ~exist('bpfig','var') || isempty(bpfig) || ~ishandle(bpfig)
                    CONVERGE_BUF = 60*eeg_chunk.srate; % size of convergence buffer
                    bpfig = figure;
                    bpaxes= axes('parent',bpfig);
                    convergence = nan(1,CONVERGE_BUF);
                    convergence(end-length(eeg_chunk.convergence)+1:end) = 10*log(eeg_chunk.convergence);
                    h=plot(linspace(0,CONVERGE_BUF/eeg_chunk.srate,CONVERGE_BUF),convergence);
                    set(bpfig,'userdata',h);
                    ylabel('10*ln(Convergence)');
                    xlabel('Time');
                else
                    blkpnts = length(eeg_chunk.convergence); %options.blockSize*(skipCount);
                    convergence(:,1:end-blkpnts) = convergence(:,blkpnts+1:end);
                    % insert new samples ...
                    convergence(:,end-blkpnts+1:end) = 10*log(eeg_chunk.convergence);
                    set(h,'ydata',convergence);
                end
            end
        end
    
    
    % Stream result over LSL
    % ---------------------------------------------------------------------
    if localizeSources && opts.miscOptCfg.streamLSL
        tmr_streaming = tic;
        onl_lslsend(hlp_compressTimeSeries(eeg_chunk,{'data','srcpot','srcpot_all'},'single',{'buffer','leadFieldMatrix','srcweights','srcweights_all'}),stream_outlet);
        benchmarking.lsl = toc(tmr_streaming);
    else
        benchmarking.lsl = NaN;
    end
    
    pause(PAUSE_DELAY);
    
%     icaweights = cat(3,icaweights,eeg_chunk.icaweights_all);
%     icasphere  = cat(3,icasphere,eeg_chunk.icasphere);
end

%% all done, close all open figures
fnames = fieldnames(figHandles);
for f=1:length(fnames)
    if ishandle(figHandles.(fnames{f}))
        close(figHandles.(fnames{f}));
    end
end

if opts.miscOptCfg.streamLSL
    stream_outlet.delete;
end

