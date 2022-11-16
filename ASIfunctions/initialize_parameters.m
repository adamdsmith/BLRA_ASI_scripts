function [P1,P2,P3] = initialize_parameters(P1,P2,P3)
% add fields to existing structs related to converting frequencies to indices

fbinwidth = P1.fs/P1.wlen;

P1.low = max(round(P1.freq_min/P1.fs*P1.wlen),1);
P1.high = 1+min(round(P1.freq_max/P1.fs*P1.wlen),round(P1.wlen/2));
P1.tolerance = round(P1.freq_tolerance/fbinwidth);

P2.dy_min = round(P2.dfreq_min/fbinwidth);
P2.dy_max = round(P2.dfreq_max/fbinwidth);
P2.y_min = max(round((P2.freq_min-P1.freq_min)/fbinwidth), 1);
P2.y_max = max(round((P2.freq_max-P1.freq_min)/fbinwidth), 1);

P3.y_shift = max(round(P3.freq_shift/fbinwidth), 1);

