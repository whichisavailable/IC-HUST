classdef Env < handle
    properties
        succeed
        info
    end
    properties (Access =  {?Score,?Observation})
        agentInfo % ini for agent
        sysInfo  % ini for system
        watertank
        t  % current times
       sp % setpoint
    end
    properties   (Access =  {?Observation})
        
        score    % current score
    end
    properties (Access = private)
        startPos
        mapInfo
        render_st
        id
        viewer  % render
        st % step time
        gameover  % status for the game
        w % width
        h % height
        obv        % observation
        movieWriter
    end
    methods
        
        function self = Env(file)
            if exist(file,'file')
                self.loadIni(file);
                self.succeed=1;
            else
                self.succeed=0;
                return;
            end
            
            self.w = self.mapInfo.w;
            self.h = self.mapInfo.h;
            self.render_st=self.sysInfo.render_st;
            self.obv=Observation();
            self.watertank=WaterTank(self.startPos,rand()+5);
            self.watertank.setSatLevel(self.agentInfo.usat);
            viewer=Viewer(self.w,self.h);
            self.sp=self.agentInfo.sp;
            self.watertank.setParameter(self.agentInfo.sp,self.agentInfo.ip,self.agentInfo.op,self.agentInfo.noise_level);
            self.addViewer(viewer);
            self.startRecord();
            self.reset();
        end
        
        
        function observation=reset(self)
            self.gameover=0;
            self.t=0;
            self.st=self.sysInfo.st;
            self.score=Score(self);
            self.obv.setObservation(self);
            observation=self.obv;
            self.info='';
        end
        
        function [observation,done,info]=step(self,action)
            tspan=[self.t self.t+self.st];
            self.watertank.step(tspan,action);
            
            self.obv.setObservation(self);
            
            self.t=self.t+self.st;
            observation=self.obv;
            done= self.gameover;
            if(self.t>self.sysInfo.tend)
                done=1;
            end
            self.score.assess(self);
            self.updateInfo();
            info=self.info;
            if done
                self.done();
            end
            
            self.changeTarget();
        end
        
        
        function changeTarget(self)
            if (self.t>7.5)
                self.sp=10;
                self.watertank.setParameter(self.sp,self.agentInfo.ip,self.agentInfo.op,self.agentInfo.noise_level);
            end
        end
        
        function done(self)
            self.stopRecord();
        end
        
        
        function render(self)
            persistent render_idx
            if isempty(render_idx)
                render_idx=0;
            end
            brender=0;
            if(self.t>=render_idx*self.render_st)
                render_idx=render_idx+1;
                brender=1;
            else
                brender=0;
            end
            
            
            if brender==1
                if self.sysInfo.showViewer || self.sysInfo.record
                    if(self.sysInfo.showViewer)
                        self.viewer.show(1);
                    else
                        self.viewer.show(0);
                    end
                    
                    self.viewer.reInitAxe(self.t);
                    self.watertank.plot(self.viewer.ax);
                    self.plotInfo();
                    self.record();
                else
                    self.viewer.show(0);
                end
            end
            
        end
    end
    methods (Access = private)
        
        function loadIni(self,file)
            I = INI('File',file);
            INI file reading;
            I.read();
            sec = I.get('Sections');
            for i=1:length(sec)
                switch sec{i}
                    case 'StartPos'
                        self.startPos=I.get('StartPos');
                    case 'Agent'
                        self.agentInfo=I.get('Agent');
                    case 'System'
                        self.sysInfo=I.get('System');
                    case 'Map'
                        self.mapInfo=I.get('Map');
                end
            end
        end
        
        function addViewer(self,v)
            self.viewer=v;
        end
        
  
        
        function startRecord(self)
            if(self.sysInfo.record)
                filename=strcat('movies/',self.sysInfo.recordfile,'.avi');
                self.movieWriter= VideoWriter(filename); % Name it.
                self.movieWriter.FrameRate = self.sysInfo.frameRate; % How many frames per second.
                open(self.movieWriter);
            end
        end
        function record(self)
            if self.sysInfo.record
                drawnow;
                writeVideo(self.movieWriter, getframe(self.viewer.getHandle()));
            end
        end
        function stopRecord(self)
            if self.sysInfo.record
                close(self.movieWriter);
            end
        end
        
        function updateInfo(self)
            self.info='Current Running Time: '+string(self.t)+' s, Current Score: '+string(self.score.score);
        end
        
        function plotInfo(self)
            self.viewer.title(self.info);
        end
        
        function checkGame(self)
%             agent=self.getMainAgent();
%             if abs(agent.x-self.endPos.x)<1 && abs(agent.y-self.endPos.y)<1
%                 self.gameover=1;
%             end
        end
    end
    
end