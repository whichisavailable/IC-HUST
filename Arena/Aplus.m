classdef Aplus
    properties
        map
        boundary
        obstacles
        path
        conv
    end
    
    methods
        function self = Aplus(startPos,endPos,map,obstacles, conv)
            self.map.XMAX=map.w;
            self.map.YMAX=map.h;
            self.map.start=endPos;  %起始点 注意必须在地图范围内
            self.map.goal=startPos;  %目标点 注意必须在地图范围内
            
            self.boundary=self.getBoundary();
            self.obstacles=obstacles;
            self.conv = conv;
            self.obstacles=[self.obstacles self.boundary];
            
            self.path=self.AStarSearch(self.map,self.conv);
        end
        
        function path=AStarSearch(self,map,conv)
            path=[];
            open=[];
            close=[];
            %findFlag用于判断while循环是否结束
            findFlag=false;
            
            %open变量每一行  [节点坐标，代价值F=G+H,代价值G,父节点坐标]
            open =[map.start(1), map.start(2) , 0+self.h(map.start,map.goal,conv) , 0 , map.start(1) , map.start(2)];
            
            next=self.MotionModel();
            
            %=======================重复以下过程==============================
            while ~findFlag
                %首先判断是否达到目标点，或无路径
                if isempty(open(:,1))
                    disp('No path to goal!!');
                    return;
                end

                %判断目标点是否出现在open列表中
                [isopenFlag,Id]=self.isopen(map.goal,open);
                if isopenFlag
                    disp('Find Goal!!');
                    close = [open(Id,:);close];
                    findFlag=true;
                    break;
                end
                
                %a.按照Openlist中的第三列（代价函数F）进行排序，查找F值最小的节点
                [~,I] = sort(open(:,3)); %对OpenList中第三列排序
                open=open(I,:);%open中第一行节点是F值最小的
                
                %b.将F值最小的节点(即open中第一行节点)，放到close第一行(close是不断积压的)，作为当前节点
                close = [open(1,:);close];
                current = open(1,:);
                open(1,:)=[];
                
                %c.对当前节点周围的8个相邻节点，算法的主体：
                for in=1:length(next(:,1))
                    
                    %获得相邻节点的坐标,代价值F先等于0,代价值G先等于0  ,后面两个值是其父节点的坐标值，暂定为零(因为暂时还无法判断其父节点坐标是多少)
                    m=[current(1,1)+next(in,1) , current(1,2)+next(in,2) , 0 , 0 , 0 ,0];
                   
                    %m(3)=self.h(m(1:2),map.goal);
                    
                    %>>如果它不可达，忽略它，处理下一个相邻节点  (注意，obstacle这个数组中是包括边界的)
                    if self.isObstacle(m)
                        continue;
                    end
                     m(4)=current(1,4)+next(in,3); % m(4)  相邻节点G值
                    m(3)=m(4)+self.h(m(1:2),map.goal,conv);% m(3)  相邻节点F值
                    %flag == 1：相邻节点  在Closelist中  targetInd = close中行号
                    %flag == 2：相邻节点不在Openlist中   targetInd = []
                    %flag == 3：相邻节点  在Openlist中   targetInd = open中行号
                    [flag,targetInd]=self.FindList(m,open,close);
                    
                    %>>如果它在Closelist中，忽略此相邻节点
                    if flag==1
                        continue;
                    %>>如果它不在Openlist中，加入Openlist,并把当前节点设置为它的父节点
                    elseif flag==2
                        m(5:6)=[current(1,1),current(1,2)];%将当前节点作为其父节点
                        open = [open;m];%将此相邻节点加放openlist中
                    %>>剩下的情况就是它在Openlist中，检查由当前节点到相邻节点是否更好，如果更好则将当前节点设置为其父节点，并更新F,G值；否则不操作
                    else
                        %由当前节点到达相邻节点更好(targetInd是此相邻节点在open中的行号 此行的第3列是代价函数F值)
                        if m(3) < open(targetInd,3)
                            %更好，则将此相邻节点的父节点设置为当前节点，否则不作处理
                            m(5:6)=[current(1,1),current(1,2)];%将当前节点作为其父节点
                            open(targetInd,:) = m;%将此相邻节点在Openlist中的数据更新
                        end
                    end
                end
            end
            path = self.GetPath(close, self.map.start);
        end
        
        
        function [flag,targetInd]=FindList(~,m,open,close)
            %如果openlist为空，则一定不在openlist中
            if  isempty(open)
                flag = 2;
                targetInd = [];
                
            else  %open不为空时，需要检查是否在openlist中
                %遍历openlist，检查是否在openlist中
                for io = 1:length(open(:,1))
                    if isequal(  m(1:2) , open(io,1:2)  )  %在Openlist中
                        flag = 3;
                        targetInd = io;
                        return;
                    else  %不在Openlist中
                        flag = 2;
                        targetInd = [];
                    end
                end
            end
            %如果能到这一步，说明：一定不在Openlist中    那么需要判断是否在closelist中
            
            %遍历Closelist（注意closelist不可能为空）
            for ic = 1:length(close(:,1))
                if isequal(  m(1:2) , close(ic,1:2)  )  %在Closelist中
                    flag = 1;
                    targetInd = ic;
                    return;%在Closelist中直接return
                end
            end
        end
        
        function boundary=getBoundary(self)
            %获得地图的边界的坐标
            b=[];
            for i1=0:(self.map.YMAX+1)
                b=[b [0;i1]];
            end
            for i2=0:(self.map.XMAX+1)
                b=[b [i2;0]];
            end
            for i3=0:(self.map.YMAX+1)
                b=[b [self.map.XMAX+1;i3]];
            end
            for i4=0:(self.map.XMAX+1)
                b=[b [i4;self.map.YMAX+1]];
            end
            boundary=b;
        end
        
        
        function path = GetPath(~,close,start)
            ind=1;
            path=[];
            while 1
                path=[path; close(ind,1:2)];
                %path=[close(ind,1:2); path];
                if isequal(close(ind,1:2),start)
                    break;
                end
                for io=1:length(close(:,1))
                    if isequal(close(io,1:2),close(ind,5:6))
                        ind=io;
                        break;
                    end
                end
            end
        end
        
        
        function hcost = h(~,m,goal,conv)
            %计算启发函数代价值 ，这里采用曼哈顿算法
             hcost =10* abs(  m(1)-goal(1)  )+10*abs(  m(2)-goal(2)  );
             hcost = hcost + 40*conv(m(1),m(2));
        end
        
        function flag = isObstacle(self,m)
            %判断节点m是否为障碍点，如果是就返为1，不是就返回0
            for io=1:length(self.obstacles(1,:))
                if isequal(self.obstacles(:,io)',m(1:2))
                    flag=true;
                    return;
                end
            end
            if self.map.goal(1) ~= m(1) || self.map.goal(2) ~= m(2)
            if m(2)==50
                flag = true;
                return;
            end
            if m(1)==50
                flag = true;
                return;
            end
                
            end
            flag=false;
        end
%         function flag = isObstacle( self,cur_pos,surround)
%             %判断节点m是否为障碍点，如果是就返为1，不是就返回0
%             %注意：这里不仅搜索了节点的8领域，而且对两倍距离的区域的8个点也进行了搜索，其目的同函数isObstacle_boundary类似，防止路径贴着障碍物边缘进行
%             m=[cur_pos(1,1)+surround(1)*2 , cur_pos(1,2)+surround(2)*2];
%             n=[cur_pos(1,1)+surround(1) , cur_pos(1,2)+surround(2)];
% 
%             %判断领域点是否是障碍物，如果是则返回1
%             for io=1:length(self.obstacles(1,:))
%                 if isequal(self.obstacles(:,io)',m(1:2)) || isequal(self.obstacles(:,io)',n(1:2))
%                     flag=true;
%                     return;
%                 end
%             end
%             flag=false;
%         end
        
        function [isopenFlag,Id] = isopen(~,node,open)
            %判断节点是否在open列表中，在open中，isopenFlag = 1,不在open中，isopenFlag = 0 .并反回索引号
            isopenFlag = 0;
            Id = 0;
            
            %如果open列表为空，则不在open列表中
            if  isempty(open)
                isopenFlag = 0;
            else %open列表不为空时
                for i = 1:length( open(:,1) )
                    if isequal(  node(1:2) , open(i,1:2)  )  %在Openlist中
                        isopenFlag = 1;
                        Id = i;
                        return;
                    end
                end
            end
        end
        
        function next = MotionModel(~)
            %当前节点  周围的八个相邻节点  与  当前节点的坐标差值（前两列）
            %当前节点  周围的八个相邻节点  与  当前节点的距离值（最后一列）
            next = [-1,1,14;0,1,10;1,1,14;-1,0,10;1,0,10;-1,-1,14;0,-1,10;1,-1,14];
        end
    end
end

