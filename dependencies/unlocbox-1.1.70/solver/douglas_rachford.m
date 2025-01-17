function [sol,iter,objectiv] = douglas_rachford(x_0,f1, f2, param)
%DOUGLAS_RACHFORD Douglas-rachford proximal splitting algorithm
%   Usage: sol = douglas_rachford(x_0,f1, f2, param);
%          sol = douglas_rachford(x_0,f1, f2);
%          [sol,iter,objectiv] = douglas_rachford(...);
%
%   Input parameters:
%         x_0   : Starting point of the algorithm
%         f1    : First function to minimize
%         f2    : Second function to minimize
%         param : Optional parameter
%   Output parameters:
%         sol   : Solution
%         iter  : Current iteration
%         objectiv: vector (evaluation of the objectiv function each iteration)
%
%   DOUGLAS_RACHFORD algorithm solves:
%
%      sol = argmin f1(x) + f2(x)      for x belong to R^N
%
%
%   where x is the variable.
%
%    x_0 is the starting point.
%
%    f1 is a structure representing a convex function. Inside the structure, there
%     have to be the prox of the function that can be called by f1.prox and 
%     the  norm of the function that can be called by f1.eval. If no function
%     f1 is defined, f1 is by default the squared L^1 norm.
%
%    f2 is a structure representing a convex function. Inside the structure, there
%     have to be the prox of the function that can be called by f1.prox and 
%     the  norm of the function that can be called by f1.eval. If no function
%     f2 is defined, f2 is by default the squared L^1 norm.
%
%    param is a Matlab structure containing the following fields:
%
%     General parameters:
%
%      param.gamma : is the gamma of the convergence parameter. By default, it's 1
%
%      param.tol : is stop criterion for the loop. The algorithm stops if
%
%           (  n(t) - n(t-1) )  / n(t) < tol,
%      
%
%       where  n(t) = f_1(x)+f_2(x) is the objective function at iteration t
%       by default, tol=10e-4.
%
%      param.method : is the method used to solve the problem. It can be 'FISTA' or
%       'ISTA'. By default, it's 'FISTA'.
%
%      param.lambda : is the weight of the update term. By default 1.
%
%      param.maxit : is the maximum number of iteration. By default, it is 200.
% 
%      param.verbose : 0 no log, 1 print main steps, 2 print all steps.
%     
%      param.abs_tol : If activated, this stopping critterion is the
%       objectiv function smaller than param.tol. By default 0.
%            
%   See also:  ppxa, forward_backward, sdmm
%
%   Demos:  demo_douglas_rachford             
%
%   References:
%     P. Combettes and J. Pesquet. A douglas-rachford splitting approach to
%     nonsmooth convex variational signal recovery. Selected Topics in Signal
%     Processing, IEEE Journal of, 1(4):564-574, 2007.
%
%   Url: http://unlocbox.sourceforge.net/doc/solver/douglas_rachford.php

% Copyright (C) 2012 LTS2-EPFL, by Nathanael Perraudin, Gilles Puy,
% David Shuman, Pierre Vandergheynst.
% This file is part of UnLocBoX version 1.1.70
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Author: Nathanael Perraudin, Gilles Puy
% Date: 22 oct 2012



% Optional input arguments
if nargin<4, param=struct; end

if ~isfield(param, 'tol'), param.tol=10e-4 ; end
if ~isfield(param, 'maxit'), param.maxit=200; end
if ~isfield(param, 'verbose'), param.verbose=1 ; end
if ~isfield(param, 'lambda'), param.lambda=1 ; end
if ~isfield(param, 'gamma'), param.gamma=1 ; end
if ~isfield(param, 'abs_tol'), param.abs_tol=0 ; end

if nargin<3 
    f2.prox=@(x) prox_L1(x, 1, param);
    f2.eval=@(x) norm(x(:),1);   
end

if nargin<2
    f1.prox=@(x) prox_L1(x, 1, param);
    f1.eval=@(x) norm(x(:),1);   
end

% test the evaluate function
[f1] = test_eval(f1);
[f2] = test_eval(f2);

% Initialization
curr_norm = 0;
[~,~,prev_norm,iter,objectiv,~] = convergence_test(curr_norm);

y_n = x_0;


% Main loop
while 1
    
    %
    if param.verbose >= 1
        fprintf('Iteration %i:\n', iter);
    end
    

    % Algorithm
    x_n=f2.prox(y_n,param.gamma);
    y_n=y_n+param.lambda*(f1.prox(2*x_n-y_n,param.gamma)-x_n);
    sol=x_n; % updates

    
    % Global stopping criterion
    curr_norm = f1.eval(sol)+f2.eval(sol);
    [stop,rel_norm,prev_norm,iter,objectiv,crit] = convergence_test(curr_norm,prev_norm,iter,objectiv,param);
    if stop
        break;
    end

    if param.verbose >= 1
        fprintf('  ||f|| = %e, rel_norm = %e\n', ...
            curr_norm, rel_norm);
    end

  
    
end

% Log
if param.verbose>=1
    % Print norm
    fprintf('\n Solution found:\n');
    if param.abs_tol
        fprintf(' Final norm: %e\n', curr_norm );
    else
        fprintf(' Final relative norm: %e\n', rel_norm );
    end
    
    
    % Stopping criterion
    fprintf(' %i iterations\n', iter);
    fprintf(' Stopping criterion: %s \n\n', crit);
    
end

end