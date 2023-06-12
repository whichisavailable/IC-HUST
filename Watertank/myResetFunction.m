function [InitialObservation, LoggedSignal] = myResetFunction()
% Reset function to place custom cart-pole environment into a random
% initial state.
global env
observation = env.reset();
sys = observation.agent;
h0 = sys.H;
targetHeight = sys.targetHeight;
% Return initial environment state variables as logged signals.
LoggedSignal.State = [h0;targetHeight];
InitialObservation = LoggedSignal.State;

end
