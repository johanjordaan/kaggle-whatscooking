function submission = guess(all_theta)

X = load('../data/test_features_matrix');

num_samples = length(X)

submission = zeros(num_samples, 1);

for i = [1:num_samples]
  
  submission(i)  = predictOneVsAll(all_theta,X(i,:));
  
endfor

end
