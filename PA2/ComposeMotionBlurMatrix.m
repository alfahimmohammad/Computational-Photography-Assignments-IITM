function [A] = ComposeMotionBlurMatrix(CodeSeq,n)
CodeSeq = CodeSeq(:)/sum(CodeSeq);
k = size(CodeSeq,1);
ZeroPaddedCodeSeq = sparse([CodeSeq; zeros(n-1,1)]);
A = gallery('circul',ZeroPaddedCodeSeq)';% Create Circulant Matrix
A = A(:,1:n); % Keep first n columns out of (n+k-1) columns