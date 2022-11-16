%set the beginnings of the paths to your ASI folder (e.g. C:\BLRA_ASI) and name your project
project='E:\BLRA_ASI';
% We use a targeted set of 261 audio files to identify letters (only used 251 in end)
% These are located in the `training_segments` folder
%audiofolder='H:\BLRA_ASI\training_segments\'; 
% From Script 3 on, we use the full set of 6149 `model_building_segments`
% known or likely to contain BLRA vocalizations
audiofolder='E:\BLRA_ASI\model_building_segments\';

addpath('ASIfunctions');

if not(7==exist(project,'dir'))
    mkdir(project);
end

files=dir([audiofolder, filesep, '*.wav']);

% P1: audio file conversion and cross-correlation parameters
P1.fs=16000; % sampling rate to resample files to (default)
P1.freq_min=1; % minimum frequency (default)
P1.freq_max=8000; % maximum frequency (max is fs/2) (default)
P1.wlen=256; % frame length (n time points) for Fourier transform (default)
P1.wdif=80; % # time points between frames (160 default, which is every 10ms @ 16kHz); we use a frame every 5 ms 
P1.mode='wiener'; % Wiener filtering to reduce noise (default)
P1.logrange=3; % set negative exponent of 10 for noise floor (default)
P1.nof=2; % multiplier of noise floor to exclude (default)
P1.maxn=12000; % Max # frames for estimating noise (6000 default); we use 12000 to double frames for estimating noise level
P1.gaussian_blur=1; % sd of Guassian kernel to smooth spectrogram (default)
P1.freq_tolerance=250; % Frequency shift allowed (Hz) in cross-corr calc (200 Hz default); we use 250 to allow a bit more freq shift
P1.playsound=true; % Sound available for playback
P1.linefreq=[450 5000]; % Set reference lines on spectrogram; of no consequence to analysis

% P2: letter candidate search and acceptance parameters
P2.dfreq_min=500; % minimum bandwidth of letter candidate
P2.dfreq_max=3500; % maximum bandwidth of letter candidate
P2.freq_min=450; % minimum freq of letter candidate
P2.freq_max=4500; % maximum freq of letter candidate
P2.dx_min=20; % minimum # of frames (length = dx_min * frame length) for letter candidate; 100 ms here
P2.dx_max=200; % maximum # of frames for letter candidate; 1 s here
P2.correlation_threshold=0.9; % minimum cross correlation to be accepted as letter candidate; this is ignored when pulling candidate by file
P2.complexity_threshold=10; % minimum # pixels exceeding 80% maximum intensity to be letter candidate; ignored when pulling by file

% P3: letter candidate refinement parameters
P3.n_refine=20; %
P3.x_shift=40; % max number of frames letter candidate can be moved (200 ms here)
P3.freq_shift=300; %

% P4: model construction and fit parameters
P4.prior_letter=0.1; %
P4.prior_species=0.1; %
P4.thresholds=[0.1 0.5 0.9]; %
P4.n_autocorrelation=10; %

[P1,P2,P3] = initialize_parameters(P1,P2,P3);
save([project, filesep, 'project_parameters'],'audiofolder','files','P1','P2','P3','P4');
