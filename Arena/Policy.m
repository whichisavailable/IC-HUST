classdef Policy < handle
    properties
        scanmap
        branchmap
        obstacles
        startPos
        endPos
        map
        astar
        path
        pathhandle
    end

    methods
        
        function self = Policy()
            
        end
        
        function action=action(self,observation)
            x0 = observation.agent.x;
            y0 = observation.agent.y;
            h0 = mod(observation.agent.h,6.28);
            self.startPos = [ceil(x0),ceil(y0)];
            self.endPos = [observation.endPos.x,observation.endPos.y];
            self.map.w = size(observation.scanMap, 1);
            self.map.h = size(observation.scanMap, 2);

            if isempty(self.scanmap)
                self.scanmap = zeros(self.map.w, self.map.h);
            end
            for i=1:self.map.w
                for j=1:self.map.h
                    self.scanmap(i,j)=self.scanmap(i,j) | observation.scanMap(i,j);
                end
            end
           

%              se = strel('square', 3);
%              self.branchmap = imdilate(self.scanmap, se);
            se = strel('square',5);
            self.branchmap = imclose(self.scanmap,se);
            self.branchmap(42,49)=0;
            filter = ones(5, 5);
            conv = conv2(self.branchmap, filter, 'same');

            [I,J]=find(self.branchmap==1);
            self.obstacles=[I J]';
            self.astar = Aplus(self.startPos, self.endPos, self.map, self.obstacles,conv);
            self.path = self.astar.path;

            x = self.path(:,1);
            y = self.path(:,2);
            
            
            delete(self.pathhandle);
            self.pathhandle = scatter(x, y, 3, 'red');


            tx = x(2);
            ty = y(2);
            alpha = atan2((ty-y0),(tx-x0))-h0;       %转向角
            alpha = mod(alpha,6.28);
            Ld = ((ty-y0)^2+(tx-x0)^2)^0.5;
            kappa = abs(2*sin(alpha)/Ld);
            u = 1;
            if(alpha>1.57 && alpha<4.71)
                v = -4*tan(alpha);
            else
                v = 4*tan(alpha);
            end
            if(abs(v)>0.1)
            u = 0.001;
            end
            
            action = [u,v];
            
                
                               
        end

    end
end