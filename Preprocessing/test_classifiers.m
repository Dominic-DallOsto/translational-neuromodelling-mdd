pairs = read_pairs_text_file('../Dataset Analysis/COI_perfectpair_pairs.txt');
Amat_dir = '../SRPBS_OPEN/data';

As = zeros(379*379,80);

for p=1:length(pairs)
	A = load(fullfile(Amat_dir, sprintf('A-%04d',pairs(p))));
	As(:,p) = A.A.A(:);
end

y = repmat([0;1],40,1);

x_train = As(:,1:60).';
x_test = As(:,61:end).';
y_train = y(1:60);
y_test = y(61:80);

%%

% model = fitclinear(x_train(1:40,:), y_train(1:40), 'regularization', 'lasso', 'verbose',1);
% model = fitclinear(x_train, y_train, 'verbose',1);
model = fitcsvm(x_train(1:40,:), y_train(1:40), 'verbose', 1, 'kernelfunction', 'linear', 'standardize', true);
% model = fitcsvm(x_train, y_train, 'verbose', 1, 'kernelfunction', 'linear', 'standardize', true);
fprintf('Prediction accuracy = %.2f%%\n', 100-100*loss(model, x_train(41:60,:), y_train(41:60)))