function [T W] = lwregress(X,Y,D,h, pl)
%
%   FUNCTION:
%   Locally-weighted regression
%
%   USAGE:
%   [T W] = lwregress(X,Y,D,h, pl);
%
%   INPUTS:
%   X (Nx1 float):	input domain
%   Y (Nx1 float):	data points sampled at values in X
%   D (Mx1 float):	data points over which to regress function
%   pl (int):       verbosity:	0: work silently
%                               1: plot original & interpolated functions
%                               2: plot also regression weights
%
%	OUTPUTS
%	T: regression points corresponding to the input data points
%	W: regression weights corresponding to the input data points
%
%   EXAMPLE:
%   dat	= dlmread('regression.data');
%   X	= dat(:,1);
%   Y	= dat(:,2);
%   D	= linspace(min(X),max(X),200)';
%   [T W] = lwregress( X,Y,D,0.5, 2 );
%
%   AUTHOR:
%   Adam Lammert (2010)
%   modified by M.Proctor (2011) for use in <find_consonant_gests.m>
%

    % constants
    c = 0.0001;

    % initialize
% 	Xsize = size(X)
    X_aug	= [X ones(size(X,1),1)];	%augmented data
% 	Xaugsize = size(X_aug)
    D_aug	= [D ones(size(D,1),1)];	%augmented test points
    T       = zeros(size(D_aug,1),1);	%regression points
    W       = zeros(size(D_aug));       %regression coeffs
	
	size(D)
	size(D_aug)

    %Primary Loop
    for i = 1:size(D_aug,1)

        %Kernel Distances
        K = zeros(size(X_aug,1),1);
        for p = 1:size(X_aug,1)
            K(p) = gauss_kernel(D(i,:),X(p,:)',h);
        end
        K = diag(K);

        %Ridge Regression
        w = (X_aug'*K*X_aug + c*eye(size(X_aug,2)))\(X_aug'*K*Y);

        %Record Weights
        W(i,:) = w';

        %Evaluate Regression Line
        T(i,:) = W(i,1:end-1)*D(i,:)' + W(i,end);

    end

    % plot data, if flagged
    if (pl == 1)
        figure; hold on;
        plot([min(X) max(X)],[0 0],'k');
        scatter(X,Y);
        scatter(D,T,'r+');
    elseif (pl > 1)
        figure;
        subplot(211); hold on;
        plot([min(X) max(X)],[0 0],'k');
        scatter(X,Y);
        scatter(D,T,'r+');
        subplot(212); hold on;
        plot([min(X) max(X)],[0 0],'k');
        scatter(D,W(:,1),'gx');
    end


    %=========== Subfunctions ===========%
    function w = gauss_kernel(x1, x2, h)
    % x1: 1st data vector
    % x2: 2nd data vector
    % h:  kernel width (stddev of gaussian kernel)
    % w:  kernel weight
        if size(x1,2)>size(x1,1)
            x1 = x1';
        end
        if size(x2,2)>size(x2,1)
            x2 = x2';
        end
        h = 1./(2.*(h.^2));
        if length(h)>1
            H = diag(h);
        else
            H = h.*eye(length(x1));
        end
        w = exp(-1*(x1 - x2)'*H*(x1 - x2));
        if w < 0.0001
            w = 0.00001;
        end
    end
    
end
