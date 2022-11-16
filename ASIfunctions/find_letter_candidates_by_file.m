function [letter_candidates]=find_letter_candidates_by_file(audiofolder,files,P1,P2,best_match_from_same_file)

nr=size(files,1);
letter_candidates={};
for i=1:nr
    recording=i;
    filename=files(i).name;
    full_filename=strcat(audiofolder,filesep,filename);
    [audio,fs]=audioread(full_filename);
    data=audio_to_image(audio,fs,P1);
    if best_match_from_same_file
        reference_recording=recording;
        reference_filename=filename;
        reference_data=data;
    else
        reference_recording=randsample(nr,1);
        reference_filename=files(reference_recording).name;
        full_reference_filename=strcat(audiofolder,filesep,reference_filename);
        [reference_audio,reference_fs]=audioread(full_reference_filename);
        reference_data=audio_to_image(reference_audio,reference_fs,P1);
    end
    if sum(isnan(data(:)))+sum(isnan(reference_data(:)))==0
        dy=P2.dy_min+unidrnd(P2.dy_max-P2.dy_min)-1;
        y1=P2.y_min+unidrnd(max(1,P2.y_max-P2.y_min-dy-1))-1;
        y2=y1+dy-1;
        x_min=1;
        x_max=size(data,2);
        % modified `dx` definition to accomomodate audio files shorter
        % than P2.dx_max
        dx=min(P2.dx_min+unidrnd(P2.dx_max-P2.dx_min)-1, x_max);
        x1=x_min+unidrnd(max(1,x_max-x_min-dx-1))-1;
        x2=x1+dx-1;
        letter_candidates{i}.name=['letter_candidate_' num2str(i,'%04.f')];
        letter_candidates{i}.audiofile=filename;
        letter_candidates{i}.audiofolder=audiofolder;
        letter_candidates{i}.box=[x1 x2 y1 y2];
        letter_candidates{i}.reference_audiofile=reference_filename;
        letter_candidates{i}.reference_audiofolder=audiofolder;
    end
end

