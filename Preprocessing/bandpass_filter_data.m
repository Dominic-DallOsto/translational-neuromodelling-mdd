function [filtered_data] = bandpass_filter_data(data,f_start,f_stop,TR)
% bandpass filter the data using a first order Butterworth as described in the paper.
	[b,a] = butter(1, [f_start,f_stop]*2*TR);
	filtered_data = filter(b, a, data);
end

