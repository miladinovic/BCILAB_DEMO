function [outermost, inside] = find_outermost_boundary(bnd)

% FIND_OUTERMOST_BOUNDARY locates outermost compartment of a BEM model
% by looking at the containment of the triangular meshes describing 
% the surface boundaries
%
% [outermost] = find_innermost_boundary(bnd)
%
% with the boundaries described by a struct array bnd with
%   bnd(i).pnt  vertices of boundary i (matrix of size Nx3)
%   bnd(i).tri  triangles of boundary i (matrix of size Mx3)

% Copyright (C) 2003, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: find_outermost_boundary.m 7123 2012-12-06 21:21:38Z roboos $

ncmp = length(bnd);

% try to locate the outermost compartment
for i=1:ncmp
for j=1:ncmp
  % determine for a single vertex on each surface if it is inside or outside the other surfaces
  curpos = bnd(i).pnt(1,:); % any point on the boundary is ok
  curpnt = bnd(j).pnt;
  curtri = bnd(j).tri;
  if i==j
    inside(i,j) = 0;
  else
    inside(i,j) = bounding_mesh(curpos, curpnt, curtri);
  end
end
end
% assume that the sources are in the innermost compartment
tmp = sum(inside, 2);
[i, outermost] = min(tmp);

