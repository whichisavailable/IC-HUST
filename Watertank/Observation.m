classdef Observation < handle
    properties
        agent  
        t
        score
        targetHeight
    end
    
    
    methods
    
        function setObservation(self,env)
            self.agent=env.watertank;
            self.t=env.t;
            self.score=env.score.score;
            self.targetHeight=self.agent.targetHeight;
        end


        function self = Observation()
        end

       
    end
end