dataset_dir = '../SRPBS_OPEN'; % made a hard link to the dataset here
hc_sample = read_array_text_file('../Dataset Analysis/hc_sample.txt');
mdd_sample = read_array_text_file('../Dataset Analysis/mdd_sample.txt');

for i = 1:length(hc_sample)
	prepro_subject(dataset_dir, hc_sample(i))
end

for i = 1:length(mdd_sample)
	prepro_subject(dataset_dir, mdd_sample(i))
end
