function [ids] = read_pairs_text_file(filename)
	data = fileread(filename);
	pairs = strsplit(data(3:end-2), '], [');

	ids = zeros(1,2*length(pairs));
	for p = 1:length(pairs)
		pair = strsplit(pairs{p}, ',');
		ids(2*p-1) = str2double(pair(1));
		ids(2*p) = str2double(pair(2));
	end
end