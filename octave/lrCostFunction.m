function [J, grad] = lrCostFunction(theta, X, y, lambda)

m = length(y); % number of training examples
n = length(theta);

h = sigmoid(theta' * X');
reg = (lambda / (2*m)) * sum( theta(2:n) .^ 2 );
J = (1/m) * sum( (-y' * log(h)') - ( (1 - y)' * log(1 -h)' ) ) + reg;

grad_reg = (lambda / m) * [0;theta(2:n)];
grad = (1/m) * ( (h - y') * X )' + grad_reg;

grad = grad(:);

end
