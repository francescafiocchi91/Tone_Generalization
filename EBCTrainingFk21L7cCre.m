%% Training_Fk2.1l7cCre Wrapper
%analyze eyeblink traces from Training sessions.
%1_acq and 1_acq+probe CSonly trials are given and analyzed.

close all; 
clc;
clear vars; 

% ========================================== Main select iblink data
[iblink_file, iblink_path, ~] = uigetfile('*.csv', 'Select iblink .csv file','C:\Users\F.R. Fiocchi\Dropbox(BayesLab)\Francesca\PhD\MATLAB'); 
%open a window in the current path and choose the .csv file with data to process

%define path of the folder with variables you want to use
folder_path = uigetdir(cd);

%enter the folder
cd(folder_path);

%import data from iblink file
EBCCSUSonlyCSUSpaired = importdata([iblink_path iblink_file]);
alltd = EBCCSUSonlyCSUSpaired;
%all CS-US paired trials
%no CS-only or US-only trials.

disp('Loading CSonly, USonly and CS-US paired .csv file.')
    
%load alltd; %load .mat file

% -------------------------------------------- Iblink
%Information all Iblink data
[Info] = ExtractInfoalltd(alltd); %struct with all the Variable information per trial

% ------------------------------------------- Parameters Iblink 
%Parameters all Iblink
[Param] = DefaultParam(alltd, Info.snr, Info.mid); %extract Parameters from the alltdDisGen file
%Parameters Iblink in a separate Variable

edit DefaultParam;

% ----------------------------------------- Set condition here  --------------------------------------
OneFlagToRuleThemAll = 6; % takes a values from 1-8 

%define whether working on 
%all video trialdata(1), or CSonly(2) or USonly(3)
%or all trialdata CSUSpaired(4), OR 
%all trialdata per mouse (5) 
%or trialdata CSonly per mouse (6) 
%or all USonly trialdata per mouse (7) 
%or all CSUSpaired per mouse (8).

% ---------------------------------------- GENERAL FLAGS
flag.ExtractRaw = 0; %when is 1 you can reload the Raw video data matrix, otherwise directly load normalized and organized data
flag.LoadAllData = 1; %load all normalized and organized data according to OneFlagToRuleThemAll
flag.ExtractTrainingOnly = 1; %isolate Training per mouse per session from the other data
flag.Save = 0; %save variable with Training all mice 
flag.LoadTrainingOnly = 0; %load only Traininig or TrainingCSonly

% ---------------------------------------- LOCAL FLAGS
flag.PlotItLikeItsHot = 1; %define type of plots in the input of the function and output will be traces
flag.WaterfallPlot = 0; %waterfall plot per group: each trace is average per session all mice

flag.CheckTrialByTrial = 0; %check trial-by-trial

flag.ComputeConditionedResponse = 1; %enter the analysis of CRs.
flag.GetStartle = 0; %compute starle responses
flag.GetCRs = 0; %compute CRs in a new matrix
flag.ComputeSlope = 0; %compute slope or load slope already computed
flag.SaveCRs = 0; %save CRs 
flag.SaveOutcomeMeasures = 0; %save in separate variables for all trials per mouse per session
flag.CRPercentage = 0;  %compute and plot how many CRs per session per mouse
flag.CRPlot = 0; %plot CR percentage per group using miceincluded vector
flag.CRpercCheck = 0; %check whether and why there are CRpercentages on day1 > 50
flag.SaveCRPercentage = 0; %save CRpercentage per session
flag.SaveMiceIncluded = 0; %save miceincluded vector

% ---------------------------------------- Threshold for CR detection
ThresholdISI = 0.10; %threshold for ISI

flag.DefineOutcomeMeasures = 0; %compute outcome measures for all CR trials per mouse per session
flag.ComputeOutcomeMeasure = 0; %based on flag compute outcome measure either for CS, US or pairedCSUS trials.
flag.SaveOutcomeMeasures = 0; %save in separate variables per mouse per Session
flag.PlotOutcomeMeasures = 0; %plot outcome measures
flag.CheckOutcomeMeasures = 0; %check outcome measures trial by trial for each mouse

flag.Acceleration = 0; %compute accelaration per session for all mice
flag.Velocity = 0; %compute velocity per session for all mice

flag.PlotGender = 0; %check if here are gender differences

% ---------------------------------------- Video 
%extract Raw data:
if flag.ExtractRaw == 1
    [video] = ExtractRawData(alltd);
    
    savefilename = 'video.mat';
    save(savefilename, 'video');
    
else  
    
    warning('Extract Raw data FLAG suppressed: LOCAL FLAGS must be switched on')
    pause, 
     
% -------------- LOAD 
if flag.LoadAllData == 1 
%load all normalized, aligned to baseline data.
    
    switch OneFlagToRuleThemAll
            
        case 5
            disp('Load Mice video trials Normalized')
            load 'NMRbbvideo.mat';
            load 'MV.mat';
            
        case 6
            disp('Load Mice video CSonly trials Normalized')
            load 'NMRRbbvideoCSonly.mat';
            load 'MVCSonly.mat';
%NB. mouse 535 (umid(14) kept repeating trial12 of block 20 on session
%nr.8, therefore change those 2 trials in NaNs from session nr. 8 for this mouse. 
NMRRbbvideoCSonly(14).Mice(1).Struc(8, 12:13, Param.Time) = NaN;        
        
        case 7
            disp('Load Mice video USonly trials Normalized')
            load 'NMRbbvideoUSonly.mat';
            load 'MVUSonly.mat';

        case 8
            disp('Load Mice video CSUSpaired trials Normalized')
            load 'NMRbbvideoCSUSpaired.mat';     
            load 'MVCSUSpaired.mat';
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------------------------- EXTRACT TRAINING ONLY
%from the structure with all trials divded per session and per mouse, it is
%necessary to extract structures for all mice, not considering the group.

if flag.ExtractTrainingOnly == 1
% ----------------- EXTRACT
%extract training for all mice. Groups are not considered
switch OneFlagToRuleThemAll
                
            case 5
            Training = ProtocolTypePerMouse(NMRRbbvideo, MV, Param.umid, Param.Time, 'Data' , 'Training');
                
            case 6                
            TrainingCSonly = ProtocolTypePerMouse(NMRRbbvideoCSonly, MVCSonly, Param.umid, Param.Time,'Data', 'Training');
            %all training CS-only trials per mouse per session
  
            case 7
            TrainingUSonly = ProtocolTypePerMouse(NMRbbvideoUSonly, MVUSonly, Param.umid, Param.Time, 'Data', 'Training');
            %all training CS-only trials per mouse per session
                  
            case 8
            TrainingCSUSpaired = ProtocolTypePerMouse(NMRbbvideoCSUSpaired, MVCSUSpaired, Param.umid, Param.Time, 'Data', 'Training');
            %all training CSUSpaired trials per mouse per session   

end
     
% ----------------- SAVE
if flag.Save == 1 
    switch OneFlagToRuleThemAll 
        
        case 5
      savefilename = 'Training.mat';
    save(savefilename, 'Training')
              
        case 6
      savefilename = 'TrainingCSonly.mat';
     save(savefilename, 'TrainingCSonly')
    
        case 7
         savefilename = 'TrainingUSonly.mat';
      save(savefilename, 'TrainingUSonly')
     
        case 8
        savefilename = 'TrainingCSUSpaired.mat';
      save(savefilename, 'TrainingCSUSpaired')
    
        
    end    
else    

% ----------------- LOAD
      switch OneFlagToRuleThemAll 
        
       case 5
          load Training;
          load Training_MV;
            
       case 6 
           load TrainingCSonly;
%            load TrainingCSonly_MV;
              
       case 7
          load TrainingUSonly;
%           load TrainingUSonly_MV;
              
      case 8 
         load TrainingCSUSpaired;
%          load TrainingCSUSpaired_MV;
              
      end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% -------------------- CHECK TRIAL-BY-TRIAL --------------------------
if flag.CheckTrialByTrial == 1   
    
switch OneFlagToRuleThemAll
      
     case 4 
     CheckTrialByTrial(TrainingCSUSpaired, Param.umid, Param.Time)
     title('Training: CSUSpaired')
     %all Training trials
            
     case 5
     CheckTrialByTrial(Training, Param.umid, Param.Time)
     title('Training: All Mice')
     %all Training trials
            
     case 6
     CheckTrialByTrial(TrainingCSonly, Param.umid, Param.Time)
     title('Training: Mice CSonly')
     %all CSonly trials
            
     case 7
     CheckTrialByTrial(TrainingUSonly, Param.umid, Param.Time)
     title('Training: Mice USonly')
     %all USonly trials
     
     case 8
     CheckTrialByTrial(TrainingCSUSpaired, Param.umid, Param.Time)
     title('Training: Mice CSUSpaired')
     %all CSUSpaired trials
        
            
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------- COMPUTE CONDITIONED RESPONSES
%define CR detection and plot trial-by-trial the CSonly 
%which can be considered CRs. Data analyzed with same functions and
%different parameters.

if flag.ComputeConditionedResponse == 1   
    disp('Compute CR according to flag.')

    % ----------------- SLOPE
    if flag.ComputeSlope == 1    
    switch OneFlagToRuleThemAll

         case 5
    TrainingSlope = Sloope(Training, Param.umid, [], Param.SlopeWindow, Param.Time, 'Training');
    %CSonly and USonly trials in structure

        case 6          
    TrainingCSonlySlope = Sloope(TrainingCSonly, Param.umid, [], Param.SlopeWindow, Param.Time, 'Training');
    %compute slope and create a struct with 0 and 1 depending on
    %whether the slope is positive or negative.

        case 7
   disp('case not consistent with function of the flag.')
                     
        case 8
    TrainingCSUSpairedSlope = Sloope(TrainingCSUSpaired, Param.umid, [], Param.SlopeWindowPaired, Param.Time, 'Training');
    %compute slope and create a struct with 0 and 1 depending on
    %whether the slope is positive or negative.

    end
    end

    % ----------------- STARTLE
    if flag.GetStartle == 1   
    switch OneFlagToRuleThemAll
        
    case 5
    TrainingStartle = skyfullofStartles(Training, Param.umid, Param.startle_rangeISIamp, Param.startle_rangeAfterOnset, ... 
        Param.StartleThreshold, Param.Time, 'Training');  
    
    case 6
    TrainingCSonlyStartle = skyfullofStartles(TrainingCSonly, Param.umid, Param.startle_rangeISIamp, Param.startle_rangeAfterOnset, ...
        Param.StartleThreshold, Param.StartleThresholdDer, Param.Time, 'Training');
    %define startle vector display 1 if the trial shows a startle and zero
    %otherwise
    
     case 7
     disp('case not consistent with function of the flag.')

     case 8
     TrainingCSUSpairedStartle = skyfullofStartles(TrainingCSUSpaired, Param.umid, Param.startle_rangeISIamp, Param.startle_rangeAfterOnset, ...
         Param.StartleThreshold, Param.StartleThresholdDer, Param.Time, 'Training');

    end
    end

% ----------------- CRS 
if flag.GetCRs == 1  
switch OneFlagToRuleThemAll
        
   case {5, 7}
   disp('case not consistent with function of the flag.')
      
    case 6          
[TrainingCSonlyCRs, TrainingAmpTimeX, TrainingFECamp, TrainingFECtime] = CRDetection(TrainingCSonly, ...
    Param.CSonset, Param.umid, Param.Time, Param.range_FEC, Param.TimeX, TrainingCSonlySlope, Param.SlopeWindow, ...
    ThresholdISI, 'Training');                                       
%Extract CRs and Outcome Measures for all the Trials
%FECamp, FECtime, Amplitude at TimeX (750-ms)

    case 8        
[TrainingCSUSpairedCRs, TrainingCSUSAmpTimeX, TrainingCSUSFECamp, TrainingCSUSFECtime] = CRDetection(TrainingCSUSpaired, Param.CSonset, ...
    Param.umid, Param.Time, Param.range_FEC(1):Param.TimeX(end)-1, Param.TimeX, TrainingCSUSpairedSlope, Param.ThresholdISI, ... 
    Param.StartleThreshold, 'Training');                                       
%Extract CRs and Outcome Measures for all the Trials
%FECamp, FECtime, Amplitude at TimeX (750-ms)
        
end

% ---------------- SAVE
if flag.Save == 1
switch OneFlagToRuleThemAll
    
    case 5
savefilename = 'TrainingSlope.mat';
     save(savefilename, 'TrainingSlope');
                
    case 6              
savefilename = 'TrainingCSonlyCRs.mat';
    save(savefilename, 'TrainingCSonlyCRs')
    
savefilename = 'TrainingCSonlySlope.mat';
    save(savefilename, 'TrainingCSonlySlope')
    
 savefilename = 'TrainingCSonlyStartle.mat';
    save(savefilename, 'TrainingCSonlyStartle');
    
savefilename = 'TrainingFECamp.mat';
    save(savefilename, 'TrainingFECamp')
    
savefilename = 'TrainingFECtime.mat';
     save(savefilename, 'TrainingFECtime')
    
savefilename = 'TrainingAmpTimeX.mat';
     save(savefilename, 'TrainingAmpTimeX')
        
    case 8
savefilename = 'TrainingCSUSFECamp.mat';
     save(savefilename, 'TrainingCSUSFECamp')
    
savefilename = 'TrainingCSUSFECtime.mat';
     save(savefilename, 'TrainingCSUSFECtime')
    
savefilename = 'TrainingCSUSAmpTimeX.mat';
      save(savefilename, 'TrainingCSUSAmpTimeX')               
end
end
else

% ------------------- LOAD 
switch OneFlagToRuleThemAll
               
    case 6      
    load TrainingCSonlyCRs;
    load TrainingCSonlySlope;
    load TrainingCSonlyStartle;  
    load TrainingFECamp;
    load TrainingFECtime;
    load TrainingAmpTimeX;
    
    case 7
    load TrainingUSonly;    
            
    case 8   
    load TrainingCSUSFECamp; 
    load TrainingCSUSFECtime;
    load TrainingCSUSAmpTimeX;
end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------------------- GROUPS
Group = GroupFk21L7cCre; %define groups according to genotype 

% ------------------------ SELECT
%select based on group division. Extract CSonly, CRs, Slope and Startle in
%separate structures, always divided per mouse.  

switch OneFlagToRuleThemAll 
    
   case 5 
    disp('why would you need CS-only, US-only and CSUS-paired trials all together?')

    case 6
    TrainingCSonly_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSonly, Param.Time, 'Training');
    %extract group specific information only per mice that belong to that
    %group: CS-only.        
    TrainingCSonly_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSonly, Param.Time, 'Training');
    
    case 7
    TrainingUSonly_het = ExtractPerGroup(Param.umid, Group.het, TrainingUSonly, Param.Time, 'Training');
    %extract group specific information only per mice that belong to that
    %group: CU-only.        
    TrainingUSonly_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingUSonly, Param.Time, 'Training');
        
    case 8
    TrainingCSUSpaired_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSUSpaired, Param.Time, 'Training');
    %extract group specific information only per mice that belong to that
    %group: CS-only.        
    TrainingCSUSpaired_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSUSpaired, Param.Time, 'Training');
       
        
end

% ------------------------ SELECT CRs
switch OneFlagToRuleThemAll 
    
    case 5 
    disp('why would you need CS-only, US-only and CSUS-paired trials all together?')

    case 6
    TrainingCSonlyCRs_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSonlyCRs, Param.Time, 'Training');
    %extract group specific information only per mice that belong to that
    %group: CS-only.        
    TrainingCSonlyCRs_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSonlyCRs, Param.Time, 'Training');
    
    case 7
    disp('case not consistent with function of the flag.')        
            
    case 8
    TrainingCSUSpairedCRs_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSUSpairedCRs, Param.Time, 'Training');
    %extract group specific information only per mice that belong to that
    %group: CS-only.        
    TrainingCSUSpairedCRs_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSUSpairedCRs, Param.Time, 'Training');
       
end

% ------------------------ SELECT STARTLES
switch OneFlagToRuleThemAll 
    
   case 5 
    disp('why would you need CS-only, US-only and CSUS-paired trials all together?')

    case 6
    TrainingCSonlyStartle_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSonlyStartle, [], 'Training');
    %extract group specific information only per mice that belong to that
    %group: CS-only.        
    TrainingCSonlyStartle_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSonlyStartle, [], 'Training');

    case 7
    disp('case not consistent with function of the flag.')        
    
    case 8
    TrainingCSUSpairedStartle_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSUSpairedStartle, Param.Time, 'Training');
    %extract group specific information only per mice that belong to that
    %group: CS-only.        
    TrainingCSUSpairedStartle_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSUSpairedStartle, Param.Time, 'Training');
       
end

% ------------------------ CR PERCENTAGE
if flag.CRPercentage == 1
    
   switch OneFlagToRuleThemAll 
       case 5       
 disp('why would you need CS-only, US-only and CSUS-paired trials all together?')

       case 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
       %compute CRpercentage per mouse per session of all animals
       %considered together.
       [TrainingCRperc, ~] = CRpercentage(Param.umid, TrainingCSonly, TrainingCSonlyCRs, 'Training');    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           

       %compute CRpercentage per mouse per session
       [TrainingCRperc_het, ~] = CRpercentage(Group.het, TrainingCSonly_het, TrainingCSonlyCRs_het, 'Training'); 
       
       [TrainingCRperc_wt, ~] = CRpercentage(Group.wt, TrainingCSonly_wt, TrainingCSonlyCRs_wt, 'Training'); 
       
      case 7
      disp('case not consistent with function of the flag.')        

       
       case 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
       %compute CRpercentage per mouse per session of all animals
       %considered together.
       [TrainingCRpercCSUS, ~] = CRpercentage(Param.umid, TrainingCSUSpaired, TrainingCSUSpairedCRs, 'Training');    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           

       %compute CRpercentage per mouse per session
       [TrainingCRpercCSUS_het, ~] = CRpercentage(Group.het, TrainingCSUSpaired_het, TrainingCSUSpairedCRs_het, 'Training'); 
       
       [TrainingCRpercCSUS_wt, ~] = CRpercentage(Group.wt, TrainingCSUSpaired_wt, TrainingCSUSpairedCRs_wt, 'Training'); 
         
   end
   
% ------------------------ MICE INCLUDED
switch OneFlagToRuleThemAll
       case {5, 6, 7, 8}       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
        %define which mice from alla subjects are included in further
        %analysis.
        MiceIncluded = CRcutoff([], Param.umid, Param.TrainingHalf, 'yes', []);        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           

        [MiceIncluded_het] = CRcutoff([], Group.het, Param.TrainingHalf, 'yes', []);

        [MiceIncluded_wt] = CRcutoff([], Group.wt, Param.TrainingHalf, 'yes',[]);

end

% ------------------------ CR PLOT
   switch OneFlagToRuleThemAll 
       case 5    
disp('why would you need CS-only, US-only and CSUS-paired trials all together?')

       case 6
       CRpercentagePlot(Group.het, TrainingCRperc_het, MiceIncluded_het, [], [], [], rgb('red'), [], 'Training')
       %plot CRpercentage per mouse and average all mice
        
       CRpercentagePlot(Group.wt, TrainingCRperc_wt, MiceIncluded_wt, [], [], [], rgb('black'), [], 'Training')

       case 7
       disp('case not consistent with function of the flag.')        
       
       case 8
       CRpercentagePlot(Group.het, TrainingCRpercCSUS_het, MiceIncluded_het, [], [], [], rgb('red'), [], 'Training')
       %plot CRpercentage per mouse and average all mice
        
       CRpercentagePlot(Group.wt, TrainingCRpercCSUS_wt, MiceIncluded_wt, [], [], [], rgb('black'), [], 'Training')   
   end

 
   
% ------------------------ CR GROUPS
switch OneFlagToRuleThemAll 
       case 5    
        disp('why would you need CS-only, US-only and CSUS-paired trials all together?')

        case 6
        SayCheese2('CR percentage', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'SEM', TrainingCRperc_het, ... 
        TrainingCRperc_wt)  
        %plot groups in the same figure. This function allows as well to define
        %which type of deviation you want to visualize: CI, SEM or ST.DEV.
        
       case 7
       disp('case not consistent with function of the flag.')        
       
       case 8 
       SayCheese2('CR percentage', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'SEM', TrainingCRpercCSUS_het, ... 
       TrainingCRpercCSUS_wt)  
   
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                  
% ---------------------------------------------------------------------- PLOT -------------------------------------------------------------------
%for each case one different figure per mouse in which are plotted the
%averaged traces per session. 
%according to the case CSonly, USonly or all trials are plotted in
%different figures per mouse.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% --------------------------- PLOT IT like is hot --------------------
if flag.PlotItLikeItsHot == 1
%switch the string in the input of the function to plot either averages: case Mean or
%raw tracesL case Raw, per mouse and all mice in the same figure.    

   switch OneFlagToRuleThemAll
       
       case 5
       disp('why would you need CS-only, US-only and CSUS-paired trials all together?')          
           
       case 6
       PlotItLikeItsHot(TrainingCSonly_het, TrainingCSonly_wt, Param.umid, [], 'Mean', rgb('red'), Param.Time);
       
       PlotItLikeItsHot(TrainingCSonly_wt, Group.wt, [], 'Mean',  rgb('black'), Param.Time);      
           
       case 7
       PlotItLikeItsHot(TrainingUSonly_het, Group.het, [], 'Mean',  rgb('red'), Param.Time);
       
       PlotItLikeItsHot(TrainingUSonly_wt, Group.wt, [], 'Mean',  rgb('black'), Param.Time);      
                      
       case 8
       PlotItLikeItsHot(TrainingCSUSpaired_het, Group.het, [], 'Mean',  rgb('red'), Param.Time);
       
       PlotItLikeItsHot(TrainingCSUSpaired_wt, Group.wt, [], 'Mean',  rgb('black'), Param.Time);      
            
      
   end
end
           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------------- PLOT WATERFALL AVERAGE TRACES per SESSION -----------------
if flag.WaterfallPlot == 1
%one figure per mouse with all the average of trials indicated by the flag,
%for each session and also one figure with all mice averaged  trials for
%eac  
   switch OneFlagToRuleThemAll
       
       case 5
       disp('why would you need CS-only, US-only and CSUS-paired trials all together?')          
           
       case 6
     EveryTracedropIsAWaterfall(TrainingCSonly_het, Group.het, [], Param.CSonset, Param.USonset, rgb('red'), [], Param.TimeEnd, ...
          'no shade', 'Training',  OneFlagToRuleThemAll );
      %waterfall plots per mouse and all mice across training.
      
     EveryTracedropIsAWaterfall(TrainingCSonly_wt, Group.wt, [], Param.CSonset, Param.USonset, rgb('black'), [], Param.TimeEnd, ...
          'no shade', 'Training',  OneFlagToRuleThemAll );
           
       case 7
      EveryTracedropIsAWaterfall(TrainingUSonly_het, Group.het, [], Param.CSonset, Param.USonset, rgb('red'), [], Param.TimeEnd, ...
          'no shade', 'Training',  OneFlagToRuleThemAll );
      %waterfall plots per mouse and all mice across training.
      
     EveryTracedropIsAWaterfall(TrainingUSonly_wt, Group.wt, [], Param.CSonset, Param.USonset, rgb('black'), [], Param.TimeEnd, ...
          'no shade', 'Training',  OneFlagToRuleThemAll );
          
       case 8
      EveryTracedropIsAWaterfall(TrainingCSUSpaired_het, Group.het,[], Param.CSonset, Param.USonset, rgb('red'), [], Param.TimeEnd, ...
          'no shade', 'Training',  OneFlagToRuleThemAll );
      %waterfall plots per mouse and all mice across training.
      
     EveryTracedropIsAWaterfall(TrainingCSUSpaired_wt, Group.wt, [], Param.CSonset, Param.USonset, rgb('black'), [], Param.TimeEnd, ...
          'no shade', 'Training',  OneFlagToRuleThemAll );
           
          
   end
end

% x = MiceMeanAll(1:10, 901:Param.TimeEnd) - MiceMeanAll900ToEnd(1:10, :);
% y = MiceMeanAll900ToEnd(1:10, :) - MiceMeanAll(1:10, 901:Param.TimeEnd);
% 
% xy = horzcat(MiceMeanAll(1:10, 1:900), y);
% 
% figure, plot(Param.Time, xy)
% 
% MiceMeanAllAvg = nanmean(MiceMeanAll);
% xy2 = horzcat(MiceMeanAll(1:10, 1:900), MiceMeanAllAvg(1, 901:Param.TimeEnd)-MiceMeanAll(1:10, 901:Param.TimeEnd)); 
% 
% 
% newx = MiceMeanAll(1:10, 801:Param.TimeEnd) - (MiceMeanAll(1:10, 801:Param.TimeEnd)*15/100);
% newxx = horzcat(MiceMeanAll(1:10, 1:800), newx);
% figure, plot(Param.Time, newxx)
% 
% figure, plot(Param.Time, newxx, 'Linewidth', 2, 'Color', rgb('Black'))
% hold on
% plot(Param.Time, MiceMeanAll)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------- OUTCOME MEASURES ---------------------------------------------------------------------
switch OneFlagToRuleThemAll
    
    case 5
    disp('Case not consistent with main purpose of switch function')     
          
    case 6       
    % ------------------------ COMPUTE         
    if flag.DefineOutcomeMeasures == 1
    %define outcome measure you want to extract with a fx
    %CRonset, CRpeaktime, CRamplitude.

    [TrainingCRamp, TrainingCRpeaktime, TrainingCRonset] = GetOutcomeMeasure(Param.umid, TrainingCSonlyCRs, [], Param.Time, ... 
         Param.range_FEC, Param.range_CRonset, Param.diffThreshold, Param.TimeEnd, MiceIncluded, 'Training');

    % ------------------------ SAVE
    if flag.SaveOutcomeMeasures == 1  
             savefilename = 'TrainingCRamp.mat';
            save(savefilename, 'TrainingCRamp')

             savefilename = 'TrainingCRpeaktime.mat';
            save(savefilename, 'TrainingCRpeaktime')    

             savefilename = 'TrainingCRonset.mat';
            save(savefilename, 'TrainingCRonset')      
    else
    % ------------------------ LOAD
    load TrainingCRamp;
    load TrainingCRpeaktime;
    load TrainingCRonset;

    end
    end

    % --------------------------- EXTRACT
    if flag.PlotOutcomeMeasures == 1
    %for each outcome measure different plots:

        % -------------------------------------------------- Define flag for outcome measures
        OutcomeMeasure = 'CR  amplitude';
        %flag for outcomes define which measure you want to compute
        Startle = 'both';
        %define if consider all trials with startle, without startle, or
        %both startle and no startle
        
        switch OutcomeMeasure 
        % ---------------- COMPUTE 
        %compute MEAN/MEDIAN, ST.DEV., SEM and CI
        %for each session and each mouse, use these values to make plots. 
        %using this fx the outcome would be a matrix per mouse per tone/session
        %with averaged values or median, or st, deviation or st. error of mean or
        %confidence interval.
        
        case 'FEC amplitude'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingFECampMean, ~] = OneForAll(TrainingFECamp, MiceIncluded, Param.umid, 'Training', 'FEC amplitude', [], []);
  
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingFECampMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingFECampMean, [], 'Training');

        TrainingFECampMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingFECampMean, [], 'Training');
        
        case 'CR amplitude'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingCRampMean, ~] = OneForAll(TrainingCRamp, MiceIncluded, Param.umid, 'Training', 'CR amplitude', [], []);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingCRampMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingCRampMean, [], 'Training');

        TrainingCRampMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCRampMean, [], 'Training');
        
        case 'Amplitude Time X'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingAmpTimeXMean, ~] = OneForAll(TrainingCRamp, MiceIncluded, Param.umid, 'Training', 'Amplitude Time X', [], []);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingAmpTimeXMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingAmpTimeXMean, [], 'Training');

        TrainingAmpTimeXMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingAmpTimeXMean, [], 'Training');

        otherwise
        disp('Case not consistent with outcome measures.')

        end        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % ---------------- LINE PLOT
        %use averages to plot mice performance across sessions for each
        %group separately
        switch  OutcomeMeasure
            
        case 'FEC amplitude'
        LinePlotWithSEMCI(TrainingFECampMean_het, [], 'FEC amplitude', Group.het, [], [], [], rgb('red'), 'Training', flag)

        LinePlotWithSEMCI(TrainingFECampMean_wt, [], 'FEC amplitude', Group.wt, [], [], [], rgb('black'), 'Training', flag)

        case 'CR amplitude'
        LinePlotWithSEMCI(TrainingCRampMean_het, [], 'CR amplitude', Group.het, [], [], [], rgb('red'), 'Training', flag)

        LinePlotWithSEMCI(TrainingCRampMean_wt, [], 'CR amplitude', Group.wt, [], [], [], rgb('black'), 'Training', flag)
        
        case 'Amplitude Time X'
        LinePlotWithSEMCI(TrainingAmpTimeXMean_het, [], 'Amplitude Time X', Group.het, [], [], [], rgb('red'), 'Training', flag)

        LinePlotWithSEMCI(TrainingAmpTimeXMean_wt, [], 'Amplitude Time X', Group.wt, [], [], [], rgb('black'), 'Training', flag)
        
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ---------------- LINE PLOT PER GROUP
        %use averages to plot mic single performance and averages

        switch OutcomeMeasure
            
        case 'CR percentage'
        SayCheese2('CR percentage', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'SEM', TrainingCRperc_het, TrainingCRperc_wt)

        case 'FEC amplitude'
        SayCheese2('FEC amplitude', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'SEM', TrainingFECampMean_het, TrainingFECampMean_wt)

        case 'CR amplitude'
        SayCheese2('CR amplitude', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'SEM', TrainingCRampMean_het, TrainingCRampMean_wt)

        case 'Amplitude Time X'
        SayCheese2('Amplitude Time X', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'SEM', TrainingAmpTimeXMean_het, TrainingAmpTimeXMean_wt)
       
        end 
    end
    
    case 7 
    % ------------------------ COMPUTE         
    if flag.DefineOutcomeMeasures == 1
    %define outcome measure you want to extract with a fx
    %CRonset, CRpeaktime, CRamplitude.

    [TrainingURamp, TrainingURpeaktime, TrainingURonset] = GetOutcomeMeasure(Param.umid, TrainingUSonly, [], Param.Time, ... 
         Param.range_FEC, Param.range_URonset, Param.diffThreshold, Param.TimeEnd, MiceIncluded, 'Training');

    % ------------------------ SAVE
    if flag.SaveOutcomeMeasures == 1  
             savefilename = 'TrainingURamp.mat';
            save(savefilename, 'TrainingURamp')

             savefilename = 'TrainingURpeaktime.mat';
            save(savefilename, 'TrainingURpeaktime')    

             savefilename = 'TrainingURonset.mat';
            save(savefilename, 'TrainingURonset')      
    else
    % ------------------------ LOAD
    load TrainingURamp;
    load TrainingURpeaktime;
    load TrainingURonset

    end
    end           

        % ------------------------ EXTRACT
        OutcomeMeasure = 'UR amplitude';
        %flag for outcomes define which measure you want to compute
        Startle = 'no';
        
        switch OutcomeMeasure 
        % ---------------- COMPUTE 
        %compute MEAN/MEDIAN, ST.DEV., SEM and CI
        %for each session and each mouse, use these values to make plots. 
        %using this fx the outcome would be a matrix per mouse per tone/session
        %with averaged values or median, or st, deviation or st. error of mean or
        %confidence interval.  
        
         case 'UR amplitude'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingURampMean, ~] = OneForAll(TrainingURamp, MiceIncluded, Param.umid, 'Training', 'UR amplitude', [], []);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingURampMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingURampMean, [], 'Training');

        TrainingURampMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingURampMean, [], 'Training');
    
        case 'UR onset'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingURonMean, ~] = OneForAll(TrainingURonset, MiceIncluded, Param.umid, 'Training', 'UR onset', [], []);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingURonMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingURonMean, [], 'Training');

        TrainingURonMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingURonMean, [], 'Training');
 
         case 'UR peaktime'
         % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingURptMean, ~] = OneForAll(TrainingURpeaktime, MiceIncluded, Param.umid, 'Training', 'UR peaktime', [],[]);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingURptMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingURptMean, [], 'Training');

        TrainingURptMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingURptMean, [], 'Training');
        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ---------------- BOX PLOT PER GROUP
        %use averages to plot mic single performance and averages
        switch OutcomeMeasure

        case 'UR amplitude'
        EverythingIownInaBox('UR amplitude', [rgb('red'); rgb('black')], 'zoom out', {'het', 'wt'}, TrainingURampMean_het, TrainingURampMean_wt);
     
        case 'UR onset'
        EverythingIownInaBox('UR onset', [rgb('red'); rgb('black')], 'zoom in', {'het', 'wt'}, TrainingURonMean_het, TrainingURonMean_wt);
 
        case 'UR peaktime'
        EverythingIownInaBox('UR peaktime', [rgb('red'); rgb('black')], 'zoom out', {'het', 'wt'}, TrainingURptMean_het, TrainingURptMean_wt);
        end

    case 8 
    
    % ------------------------ COMPUTE         
    if flag.DefineOutcomeMeasures == 1
    %define outcome measure you want to extract with a fx
    %CRonset, CRpeaktime, CRamplitude.

    [TrainingCSUSCRamp, TrainingCSUSCRpeaktime, TrainingCSUSCRonset] = GetOutcomeMeasure(Param.umid, TrainingCSUSpairedCRs, TrainingCSUSpairedStartle, Param.Time, ... 
         Param.range_FEC(1):Param.TimeX(end)-1, Param.range_CRonset, Param.diffThreshold, Param.TimeEnd, MiceIncluded, 'Training');

    % ------------------------ SAVE
    if flag.SaveOutcomeMeasures == 1  
             savefilename = 'TrainingCSUSCRamp.mat';
            save(savefilename, 'TrainingCSUSCRamp')

             savefilename = 'TrainingCSUSCRpeaktime.mat';
            save(savefilename, 'TrainingCSUSCRpeaktime')    

             savefilename = 'TrainingCSUSCRonset.mat';
            save(savefilename, 'TrainingCSUSCRonset')      
    else
    % ------------------------ LOAD
    load TrainingCSUSCRamp;
    load TrainingCSUSCRpeaktime;
    load TrainingCSUSCRonset;

    end
    end    
    

    % --------------------------- EXTRACT
    if flag.PlotOutcomeMeasures == 1
    %for each outcome measure different plots:

        % -------------------------------------------------- Define flag for outcome measures
        OutcomeMeasure = 'CR  amplitude';
        %flag for outcomes define which measure you want to compute
        Startle = 'both';
        %define if consider all trials with startle, without startle, or
        %both startle and no startle
        
        switch OutcomeMeasure 
        % ---------------- COMPUTE 
        %compute MEAN/MEDIAN, ST.DEV., SEM and CI
        %for each session and each mouse, use these values to make plots. 
        %using this fx the outcome would be a matrix per mouse per tone/session
        %with averaged values or median, or st, deviation or st. error of mean or
        %confidence interval.
             
        case 'FEC amplitude'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingCSUSFECampMean, ~] = OneForAll(TrainingCSUSFECamp, MiceIncluded, Param.umid, 'Training', 'FEC amplitude', Startle, TrainingCSUSpairedStartle);
  
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingCSUSFECampMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSUSFECampMean, [], 'Training');

        TrainingCSUSFECampMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSUSFECampMean, [], 'Training');
        
        case 'CR amplitude'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingCSUSCRampMean, ~] = OneForAll(TrainingCSUSCRamp, MiceIncluded, Param.umid, 'Training', 'CR amplitude', Startle, TrainingCSUSpairedStartle);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingCSUSCRampMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSUSCRampMean, [], 'Training');

        TrainingCSUSCRampMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSUSCRampMean, [], 'Training');
        
        case 'Amplitude Time X'
        % -------------------------------- Define
        %define average mousexsession, considering only mice included and
        %remember to specify if ypu want to consider startle responses in
        %trial selection or not.
        [TrainingCSUSAmpTimeXMean, ~] = OneForAll(TrainingCSUSAmpTimeX, MiceIncluded, Param.umid, 'Training', 'Amplitude Time X', Startle, TrainingCSUSpairedStartle);
         
        % -------------------------------- Select
        %select based on group division. Extract CSonly, CRs, Slope and Startle in
        %separate structures, always divided per mouse.         
        TrainingCSUSAmpTimeXMean_het = ExtractPerGroup(Param.umid, Group.het, TrainingCSUSAmpTimeXMean, [], 'Training');

        TrainingCSUSAmpTimeXMean_wt = ExtractPerGroup(Param.umid, Group.wt, TrainingCSUSAmpTimeXMean, [], 'Training');

        otherwise
        disp('Case not consistent with outcome measures.')

        end        
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % ---------------- LINE PLOT
        %use averages to plot mice performance across sessions for each
        %group separately
        switch  OutcomeMeasure
            
        case 'FEC amplitude'
        LinePlotWithSEMCI(TrainingCSUSFECampMean_het, [], 'FEC amplitude', Group.het, [], [], [], rgb('red'), 'Training', flag)

        LinePlotWithSEMCI(TrainingCSUSFECampMean_wt, [], 'FEC amplitude', Group.wt, [], [], [], rgb('black'), 'Training', flag)

        case 'CR amplitude'
        LinePlotWithSEMCI(TrainingCSUSCRampMean_het, [], 'CR amplitude', Group.het, [], [], [], rgb('red'), 'Training', flag)

        LinePlotWithSEMCI(TrainingCSUSCRampMean_wt, [], 'CR amplitude', Group.wt, [], [], [], rgb('black'), 'Training', flag)
        
        case 'Amplitude Time X'
        LinePlotWithSEMCI(TrainingCSUSAmpTimeXMean_het, [], 'Amplitude Time X', Group.het, [], [], [], rgb('red'), 'Training', flag)

        LinePlotWithSEMCI(TrainingCSUSAmpTimeXMean_wt, [], 'Amplitude Time X', Group.wt, [], [], [], rgb('black'), 'Training', flag)
        
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ---------------- LINE PLOT PER GROUP
        %use averages to plot mic single performance and averages

        switch OutcomeMeasure

        case 'CR percentage'
        SayCheese2('CR percentage', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'C.I.', TrainingCSUSCRperc_het, TrainingCSUSCRperc_wt)

        case 'FEC amplitude'
        SayCheese2('FEC amplitude', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'C.I.', TrainingCSUSFECampMean_het, TrainingCSUSFECampMean_wt)

        case 'CR amplitude'
        SayCheese2('CR amplitude', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'C.I.', TrainingCSUSCRampMean_het, TrainingCSUSCRampMean_wt)

        case 'Amplitude Time X'
        SayCheese2('Amplitude Time X', 'only averages', [rgb('red'); rgb('black')], 'Training', [], [], 'C.I.', TrainingCSUSAmpTimeXMean_het, TrainingCSUSAmpTimeXMean_wt)
       
        end 
end
end




    
    
    
    
    


