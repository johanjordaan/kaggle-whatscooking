function perc = accuracy(all_theta, X, y)

num_samples = length(X)

correct = 0;
for i = [1:num_samples]
  
  prediction  = predictOneVsAll(all_theta,X(i,:));
  correct += prediction == y(i);
  
endfor

correct
perc = correct/num_samples;

end