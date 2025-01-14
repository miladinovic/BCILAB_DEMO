function v = cvxtuple( varargin )

if nargin == 1,
    v = varargin{1};
    switch class( v ),
        case 'struct',
            if numel( v ) ~= 1,
                error( 'struct arrays not permitted in cvx tuple objects.' );
            end
        case 'cell',
            v = reshape( v, 1, numel( v ) );
        otherwise,
            return
    end
else
    v = varargin;
end

v = class( struct( 'value_', { v } ), 'cvxtuple', cvxobj );

% Copyright 2010 Michael C. Grant and Stephen P. Boyd.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
