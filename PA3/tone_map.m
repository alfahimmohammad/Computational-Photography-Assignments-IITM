function [I_TM] = tone_map(I, K, B, epsilon, set_I_white_inf)
    arguments
        I;
        K=0.15;
        B=0.95;
        epsilon=10^(-12);
        set_I_white_inf=false;
    end
        
    

I_m = exp(mean(log(I+epsilon),'all'));
I_bar = K.*(I./I_m);
if set_I_white_inf
    I_white = inf;
else
    I_white = B*max(I_bar,[],'all');
end
I_TM = I_bar.*((1+(I_bar./(I_white.^2)))./(1+I_bar));
end