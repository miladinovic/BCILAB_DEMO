%%************************************************************************
%% HSDNTcorr: corrector step for the NT direction. 
%%
%% SDPT3: version 3.1
%% Copyright (c) 1997 by
%% K.C. Toh, M.J. Todd, R.H. Tutuncu
%% Last Modified: 16 Sep 2004
%%************************************************************************

  function [par,dX,dy,dZ,resnrm] = HSDNTcorr(blk,At,par,rp,Rd,sigmu,hRd,...
            dX,dZ,coeff,L,X,Z); 

    global printlevel 
    global matfct_options solve_ok 
%%
    [rhs,EinvRc] = HSDNTrhsfun(blk,At,par,X,Z,rp,Rd,sigmu,hRd,dX,dZ);
    m = length(rp); ncolU = size(coeff.mat12,2); 
    rhs = [rhs; zeros(m+ncolU-length(rhs),1)]; 
%%
    solve_ok = 1; resnrm = norm(rhs);
    [xx,resnrm,solve_ok] = HSDbicgstab(coeff,rhs,L,[],[],printlevel);
    if (solve_ok<=0) & (printlevel)
       fprintf('\n  warning: iterative solver fails: %3.1f.',solve_ok); 
    end
    if (par.printlevel>=3); fprintf(' %2.0f',length(resnrm)-1); end
%%   
    [par,dX,dy,dZ] = HSDNTdirfun(blk,At,par,Rd,EinvRc,xx); 
%%************************************************************************


