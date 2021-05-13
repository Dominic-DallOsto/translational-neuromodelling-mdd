function data = get_protocol_data(data_directory, N)
	t = rows2vars(readtable(fullfile(data_directory,'MRI_protocols_rsMRI.tsv'),'FileType','text','Delimiter','\t','Format','%s%s%s%s%s%s%s%s%s%s%s%s%s%s','HeaderLines',1,'ReadVariableNames',false,'ReadRowNames',true));
	protocols = str2double(t.Protocol_);
	if any(protocols == N)
		data = t(protocols == N,:);
	else
		throw(MException('ProtocolReader:noSuchProtocol',sprintf('Tried to access protocol %d which does not exist.',N)))
	end