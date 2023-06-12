classdef Viewer < handle
    properties
        h % heading
        w % width
    end
    
   properties (Access =  {?Evn})
        fh% figure handle
    end
    properties (SetAccess = private)
        ax
    end
    
    
    methods
    
        
        function self = Viewer(w,h)
            self.h=h;
            self.w=w;
            self.fh=figure('Name','Water Tank Simulator','NumberTitle','off');
            %fh.Color=[0.4 0.6 0.7];
            self.fh.MenuBar='none';
            
            
            screenSize=get (0, 'ScreenSize');
            screenw=screenSize(3);
            screenh=screenSize(4);
            
            posw=screenw*1.5/8;
            posh=screenh*1.5/4;
            
            %poswh=max(posw,posh);
            
            posx=screenw-posw;
            posy=screenh-posh;
            
            self.fh.Position =[posx posy posw posh];
            self.ax=axes('Position',[0.05 0.05 0.9 0.9],'Box','on');
            self.reInitAxe(0);   
        end
        
        function h=getHandle(self)
            h= self.fh;
        end
        
        function show(self,bshow)
            if bshow
                set(self.fh, 'Visible', 'on');
            else
                set(self.fh, 'Visible', 'off');
            end
        end
       
        function title(self,text)
            self.ax.Title.String=text;
        end
        function reInitAxe(self,t)
            %refresh (self.fh);
            %self.ax
            %self.ax.YTick = unique(floor(linspace(0,self.h,10)));
            %self.ax.XTick = unique(floor(linspace(0,self.w,10)));
            self.ax.FontSize = 12;
            self.ax.XLimMode='manual';
            self.ax.YLimMode='manual';
            self.ax.XLim=[0 self.w];
            self.ax.YLim=[0 self.h];    
            self.ax.DataAspectRatio=[1 1 1];       
            hold on;
        end
        
        
         
    end
    
end