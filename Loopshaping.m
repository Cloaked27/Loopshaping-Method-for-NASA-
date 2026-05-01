s = tf('s');
P = 10/(s*(100*s+1)*(0.1*s+1));
poli_P  = pole(P);
% The system is marginally BIBO stable (not strictly stable), because it has a pole at 0, 
% while the other poles are in the left half-plane (C_).
% The first constraint is the algebraic one: S + T = 1, at all frequencies.
% The second constraint is due to the pole at 0, which we know will 
% transfer to the open-loop L (L must also have a pole at 0 to respect the first condition of internal stability in the closed-loop).
% The Internal Model Principle (IMP) states that to perfectly track a reference, we need the poles of the reference 
% to be present either in the poles of the Plant or in the poles of the compensator.
% Since a unit step has a pole at 0 (1/s), and we already have it in P => tracking is guaranteed for any stabilizing controller.
Ws = 2100/(s/0.1+1)^2; 
%%
bodemag(Ws, P);
% We notice that at the end of the low frequencies (the interval where we would like to have performance) there is a 40db difference.
% This means that our C has to push hard to compensate for this

%%
%%
Wt = s/100/(s/1000+1);
bodemag(Wt, Ws, tf(1,1)) ;
% the 2 intersect under 1, so the necessary condition is respected. This condition is necessary, because at least one of Ws and Wt has to be <1 at any frequency.
% If both were > 1, that would mean that at that frequency, both S and T would be small, and this would break S + T = 1
% w2 = 100(w2 is where Wt = 1), which means that the medium freq band is [e-1, e2], so we have 3 decades.
% After some calculations, we have to lose about 60dB so this band BARELY allows us to use the -20db/dec slope.
%%
C1 = 12*(100*s+1)*(0.1*s+1)/((s/100+1)*(s/1000+1)*(s/100000+1))*(s+2)/(s+0.5)*0.5/2;
%C1 is proper so it attenuates the noise and shocks coming with the command, which take place at high frequencies, where C1 is a low pass filter.
L = P*C1;
[M1, ~] = bode(Wt, 0.1);
[M2, ~] = bode(Ws, 100);
R_jf = Ws/(1-M1);
R_if = (1-M2)/Wt;
%here we created the margins for our conditions. So L has to be above R_jf, and below R_if in their respective intervals.
bodemag(R_jf, {1e-3,1e-1});
hold on;
bodemag(R_if, {1e2, 1e4});
bodemag(L, {1e-3, 1e4});
%%
nyquist(L)
% from the nyquist plot we extract the phase margain : 69, more than enough
%%
S = feedback(1, P*C1);
%bode(S);
norm(S, inf) % = 1.2217 => Mv > 0.5
% this value happens because of the WaterBed effect. We anticipated it at the beggining of our project, when we said that C has to push hard to compensate the difference betwen Ws and P
nyquist(L); %CLOSED LOOP STABLE: YES
%%
T = 1-S;
w = logspace(-3, 4, 1e4);
[Mperf, ~] = bode(Ws*S, w);
[Mrob, ~] = bode(Wt*T, w);
vector_suma = squeeze(Mrob) + squeeze(Mperf);
plot(log10(w), vector_suma)
gamma_prob = max(vector_suma) %this is below 1, so we have robust performance.
