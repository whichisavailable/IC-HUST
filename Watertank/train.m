abspath=utils('abspath');
global env

env = Env(abspath('sys.ini'));

ObservationInfo = rlNumericSpec([2 1]);
ObservationInfo.Name = 'watertank';
ObservationInfo.Description = 'H,targetHeight';
%%%%动作状态空间
ActionInfo = rlFiniteSetSpec([0 1 2 3 4 5 6 8 12 15]);
ActionInfo.Name = 'watertank Action';
%%创建环境
ENV = rlFunctionEnv(ObservationInfo,ActionInfo,'myStepFunction','myResetFunction');
%%
%%%%创建DQN
statePath = [
    imageInputLayer([2 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(12,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(12,'Name','CriticStateFC2')];
actionPath = [
    imageInputLayer([1 1 1],'Normalization','none','Name','action')
    fullyConnectedLayer(12,'Name','CriticActionFC1')];
commonPath = [
    additionLayer(2,'Name','add')
    reluLayer('Name','CriticCommonRelu')
    fullyConnectedLayer(1,'Name','output')];
criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = addLayers(criticNetwork, commonPath);    
criticNetwork = connectLayers(criticNetwork,'CriticStateFC2','add/in1');
criticNetwork = connectLayers(criticNetwork,'CriticActionFC1','add/in2');

criticOpts = rlRepresentationOptions('LearnRate',0.01,'GradientThreshold',1);
obsInfo = getObservationInfo(ENV);
actInfo = getActionInfo(ENV);
critic = rlRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'state'},'Action',{'action'},criticOpts);
agentOpts = rlDQNAgentOptions(...
    'UseDoubleDQN',false, ...    
    'TargetUpdateMethod',"periodic", ...
    'TargetUpdateFrequency',4, ...   
    'ExperienceBufferLength',100000, ...
    'DiscountFactor',0.8, ...
    'MiniBatchSize',256);
agent = rlDQNAgent(critic,agentOpts);
%%
trainOpts = rlTrainingOptions(...
    'MaxEpisodes', 1000, ...
    'MaxStepsPerEpisode', 500, ...
    'Verbose', false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',480); 
% Train the agent.
%load('agentData.mat')
trainingStats = train(agent,ENV,trainOpts);
%%
%save('trained_agent.mat','agent')      %存好训练好的agent可以再次训练
%generatePolicyFunction(agent)          %训练好后运行得到agentData
%load('agentData.mat')              

%load('trained_agent.mat','agent');