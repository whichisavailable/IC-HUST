classdef Score < handle
    properties
        score
    end
    properties (Access = private)
        st  % simulation time step
    end
    
    
    methods
    
        function self = Score(env)
            self.score=env.sysInfo.score;

        end

        function assess(self,env)
            agent=env.watertank;
            self.st=env.sysInfo.st;
            require_action=agent.op*sqrt(env.sp)/agent.ip;
            self.score= self.score-abs(agent.H-env.sp)^2*self.st-abs(require_action-agent.action)^2*self.st;
            
        end
       
    end
end