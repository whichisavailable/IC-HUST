# WaterTank Challenge简介
WaterTank Challenge是一个由Matlab代码编写的仿真环境。主要要求挑战者编写Matlab代码控制水箱液位至目标液位。控制量为水箱进水阀门，控制量为正数，具体见下图
<div align="left">
<img src=https://gitee.com/coralab/ic-challenge/raw/master/Watertank/pics/system.png width=50%/>
</div>



## 1. 水箱动力学模型
水箱动力学模型具体描述见
[matlab链接](https://www.mathworks.com/help/slcontrol/gs/watertank-simulink-model.html).

小车的动力学模型，如下Simulink模型所示
<div align="left">
<img src=https://gitee.com/coralab/ic-challenge/raw/master/Watertank/pics/watertank_system.png width=100%/>
</div>


其中，[a,b]分别是水箱进水阀和出水阀系数，H为液位高度，u是进水阀开度。可知水箱出水速度与水箱液位高度有关。

另外仿真环境对水箱阀门设置了“饱和”机制（如下图所示），即挑战者传递给仿真器的水箱阀门控制量，将会被限制在一定范围内。

<div align="left">
<img src=https://gitee.com/coralab/ic-challenge/raw/master/Arena/pics/saturation.png width=30%/>
</div>


## 2. Observation（当前环境信息）

仿真环境每隔一段时间，将会把仿真环境的信息以Observation类的形式告知挑战者，它的成员变量包含  
```
agent		%当前水箱信息   
t            	%当前所用时间  
score      	%当前挑战者的分数  
targetHeight   	%目标液位高度 
```

## 3. 得分（暂无）


## 4. 设计控制策略
挑战者需要设计并提交一个Policy类文件，主要完成action函数。action函数传入参数为observation，传出action。仿真器会在特点的时间间隔调用action，依据挑战者设计的策略得到action，即控制量[u,v]，从而控制小车。
```
classdef Policy < handle        function action=action(self,observation) 		  	sys=observation.agent;
          u=-10*sin(observation.t);
        	action=[u];        end
end
```

## 5. Main函数
以下是Main函数的基本代码，main读取系统配置文件对仿真环境进行配置，之后进入仿真循环。在循环中，仿真器对Water Tank Challenge进行物理仿真，计算出水箱状态，并且每一次调用挑战者设计控制策略，然后把控制策略作用于水箱的控制中。
```
env = Env('sys.ini');   %读取系统配置文件policy=Policy();if (env.succeed)    observation = env.reset();    while 1        env.render();        action=policy.action(observation); %调用挑战者的控制策略        [observation,done,info]=env.step(action); %物理仿真        disp(info);        if(done)            break;        end        wait(100);    endend```

## 6. 仿真配置文件sys.ini
为了方便挑战者进行测试，挑战者可以通过仿真配置文件sys.ini，进行相应配置。例如配置水箱控制饱和范围，水箱目标液位，是否录制游戏运行过程等。具体见该文件。
```
usat=5              % 饱和范围
sp=20              % 目标液位
ip=3             %进水阀系数
op=2             %出水阀系数
noise_level=0  % 系统模型噪声
```




