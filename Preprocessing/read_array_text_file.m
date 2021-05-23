function [data] = read_array_text_file(filename, type)
	if nargin < 2
		type = '%d';
	end

	f = fopen(filename);
	fread(f,1); % ignore the leading [
	data = textscan(f, type, 'delimiter', ',');
	data = data{1};
	fclose(f);
end