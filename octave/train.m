function [all_theta, accuracy] = train(lambda) 

X = load('../data/training_features_matrix');
y = load('../data/training_result_matrix');

num_types = max(y);

all_theta = oneVsAll(X, y, num_types, lambda);

accuracy = accuracy(all_theta,X,y)

end