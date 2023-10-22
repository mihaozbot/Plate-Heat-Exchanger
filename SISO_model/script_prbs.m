
% prbs {{0},{1}}
seed = zeros(1,n_prbs);
seed(1) = 1;
[prbsn,seed] = prbs(n_prbs, 2^n_prbs,seed); % prbs {{0},{1}}

% Centered prbs {{-1},{1}}
cprbs = 2*(prbsn-0.5);

% Amplitude modulated centered prbs [-1,1]
acprbs(1) = cprbs(1);
for i = 2:1:length(cprbs)
    if (cprbs(i)-cprbs(i-1))~=0
        acprbs(i) = (randi([0,10])/10)*cprbs(i);
    else
        acprbs(i) = acprbs(i-1);
    end
end

%Amplitude modulated prbs [-1,1]
aprbs(1) = cprbs(1);
for i = 2:1:length(cprbs)
    if (cprbs(i) - cprbs(i-1)) == 2
        aprbs(i) = aprbs(i-1) + rand()*(1-aprbs(i-1));
    elseif (cprbs(i)-cprbs(i-1)) == -2
        aprbs(i) = aprbs(i-1) + rand()*(-1-aprbs(i-1));
    else
        aprbs(i) = aprbs(i-1);
    end
end

%Ramp amplitude modulated prbs [0,1]
raprbs(1) = aprbs(1);
nchages = sum(xor(cprbs(1:end-1)+1,cprbs(2:end)+1));
ramp = 0;
for i = 2:1:length(cprbs)
    if (cprbs(i) - cprbs(i-1)) ~= 0  %sprememba
        ramp = ramp + 1/100;
        raprbs(i) = aprbs(i) + ramp;
    else
        raprbs(i) = raprbs(i-1);
    end
end
raprbs = (raprbs-min(raprbs))/(max(raprbs)-min(raprbs));
