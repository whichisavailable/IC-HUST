# Arena Challenge简介
Arena Challenge是一个由Matlab代码编写的仿真环境。主要要求挑战者编写Matlab代码控制小车在一个地图环境中从起点运行至终点，地图中随机放置着障碍物(见下图）。小车是一个unicycle的动力系统，并装有“雷达”探测器，可探测前方障碍物情况。最终的成绩由小车到达终点的时间以及小车是否撞上障碍物等情况综合评估而得。

详细介绍见https://gitee.com/coralab/ic-challenge

**主要改动**

Aplus.m为我们的寻路算法，控制和一些寻路的小细节在Policy.m中实现，可修改sys.ini改变环境参数。





