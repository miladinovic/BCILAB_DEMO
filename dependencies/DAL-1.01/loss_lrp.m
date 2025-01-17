% loss_lrp - logistic loss function
%
% Copyright(c) 2009 Ryota Tomioka
% This software is distributed under the MIT license. See license.txt
function [floss, gloss] = loss_lrp(zz, yy)
% this apparently returns not just the function value, but also the gradient

% this stuff should amount to the regular logistic loss... but the max() isn't very clear?
zy      = zz.*yy;
z2      = 0.5*[zy, -zy];
outmax  = max(z2,[],2);
sumexp  = sum(exp(z2-outmax(:,[1,1])),2);
logpout = z2-(outmax+log(sumexp))*ones(1,2);
pout    = exp(logpout);

floss   = -sum(logpout(:,1));

% also compute the gradient - how is this derived?
gloss   = -yy.*pout(:,2);
