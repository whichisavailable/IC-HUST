function [NextObs,Reward,IsDone,LoggedSignals] = myStepFunction(action,LoggedSignals)

% Reward
r = 1;
% Penalty
p = -10;

global env

[observation,~,~]=env.step(action);
sys=observation.agent;
LoggedSignals.State=[sys.H;sys.targetHeight];
NextObs = LoggedSignals.State;

% Check terminal condition.
h = NextObs(1);
aim = NextObs(2);
IsDone = abs(h-aim) < 0.1;

% Get reward.
if IsDone
    Reward = r;
else
    Reward = p;
end

end

