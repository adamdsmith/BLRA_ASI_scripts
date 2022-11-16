function [data] = audio_to_image(original_audio,original_fs,P1)
% if stereo or multi-channel data, use channel with largest energy
if size(original_audio,2) > 1
   [m,i]=max(sum(original_audio.^2));
   y=resample(original_audio(:,i),P1.fs,original_fs);
else
   y=resample(original_audio,P1.fs,original_fs);
end

data=abs(spectrogram(y,hann(P1.wlen),P1.wlen-P1.wdif));
data = data(P1.low:P1.high,:);

if strcmp(P1.mode,'abs')
   % do nothing

elseif strcmp(P1.mode,'logrange')
   % set scale 0..1
   data=(log10(data/max(data(:))+10^(-P1.logrange)) + P1.logrange)/P1.logrange;

elseif strcmp(P1.mode,'wiener')
   % use energy
   data=data.^2;
   % use at most P1.maxn points to estimate noise level (mean of smallest 10% of samples)
   n=min([size(data,2), P1.maxn]);
   [y i]=sort(sum(data(:,1:n)),'ascend');
   itop=i(1:round(n/10));
   m=mean(data(:,itop),2);

   n=size(data,2);
   data=data-repmat(P1.nof*m,1,n);
   data(data<0)=0;
   data=(log10(data/max(data(:))+10^(-2*P1.logrange)) + 2*P1.logrange)/(2*P1.logrange);
else
   error(sprintf('unrecognized mode "%s" for computing spectrogram.',P1.mode)); 
end
data=imgaussfilt(data,P1.gaussian_blur);
