%--------------------------------------------------------------------------
% Created by:  William J. Ebel  on 9/8/24
%
% Revision history:
%      Date     Reason
% 
% Purpose:  This script implements a series of algorithms uesd for robot
%   calibration including the robot sensors (line-following, ranger) as
%   well as the PID controller.  
%     This script contains variable initializations which will cause the
%   control_loop to behave differently in order to carry out calibration
%   procedures.  The specific calibration procedures are listed below
%   along with the parameter configuration for each. 
%
%                ************** DRAFT **************
%
%   1. line-following sensor calibration:  the goal is to specify the amin
%      vector which is a subtracted component used to eliminate noise.
%         runtime = 30;
%         modeflg = 1;
%         amin = [0 0 0 0 0 0 0 0];
%
%   2. IR ranging sensor calibration:  The goal is to create a function
%      called IRmap.m that will map the raw sensor value into a distance
%      estimate in units of inches.  
%         runtime = 1;
%         modeflg = 1;
%   
%   3. Wheel radius calibration:  The goal is to specify the variable R
%      which defines the wheel radius (same for both wheels).  Place two
%      white strips on the black line with a known distance between them.
%         runtime = 3;
%         modeflg = 10;
%         Lspeed = ??;    % pick a moderate robot speed
%         Rspeed = ??;    % pick same speed as Lspeed
%         Kpd = 1;        % scale factor for generic PID controller params
%         amin = [...];   % from calibration #1
%   
%   4. Dead-Reckoning check:  Check to see if the motors are balanced by
%      driving the robot forward without any motor control.
%         runtime = 3;
%         modeflg = 10;
%         Lspeed = ??;    % pick a moderate robot speed
%         Rspeed = ??;    % pick same speed as Lspeed
%         Kpd = 0;        % scale factor for generic PID controller params
%   
%   5. Motor speed calibration:  The goal is to create a function
%      speed_map.m which maps the desired motor speed into a speed index.
%         runtime = 3;
%         modeflg = 10;
%         Lspeed = ??;    % pick one of a set of speeds to create a curve
%         Rspeed = ??;    % pick same speed as Lspeed
%         Kpd = 1;        % scale factor for generic PID controller params
%         amin = [...];   % from calibration #1
%   
%   6. PID controller calibration:  The goal is to find the constants Kp,
%      Ki, and Kd so that the robot follows the line closely, even when on
%      a turn.  
%         runtime = 3;
%         modeflg = 10;
%         Lspeed = ??;    % choose a speed of 10 inches/sec
%         Rspeed = ??;    % choose a speed of 10 inches/sec
%         Kp = 0;         % proportional controller constant
%         Ki = 0;         % integral controller constant
%         Kd = 0;         % differential controller constant
%         Kpd = [];       % turns off the generic PID controller
%         amin = [...];   % from calibration #1
%
% Important Variables:  
%      runtime: (sec) the total runtime for the control loop
%         mode:  1 or 10 (might be modified in the future)
% line_lost_max:  number of allowable loop iterations with no line detect
%  line_breaks:  number of line breaks to find before stopping the robot
%   Lspeed:  Left motor speed, range [-100,100]
%   Kp, Ki, Kd:  PID controller gain parameters
%          Kpd:  Generic PID controller gain factor, usually set to 1
%                represents the full set of variables for one time step.
%         amin:  line-following sensor noise floor values
%            R:  wheel radius (inches)
%            L:  wheel base width (inches)
%
%--------------------------------------------------------------------------
clc;

% run parameters
runtime = 1;       % (sec) run time for this function
mode = 10;           % see documentation above

line_lost_max = 5;  % number of loop times with lost lines before stopping
line_breaks   = 2;  % number of line breaks to find (stop at last one)

% motor speed parameters
Lspeed = 40;    % 40 nominal LEFT motor speed
Rspeed = 40;    % 40 nominal RIGHT motor speed

% PID controller parameters
Kp  = 0;    % proportional controller constant
Ki  = 0;    % integral controller constant
Kd  = 0;    % differential controller constant
Kpd = 1;    % empty = PID using Kp, Ki, Kd;  factor = use default PID

% sensor noise floor vector
amin = [0 0 0 0 0 0 0 0];  % set the noise floor values

% robot physical parameters
R = 1;       % 1.377 (inches) wheel radius
L = 1;       % 6.133 (inches) wheel base width

% perform the control_loop to operate the robot
control_loop;