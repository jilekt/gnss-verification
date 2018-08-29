function dev = readlog_gnss(filepath, type, trim)
%READLOG_GNSS   Read GNSS log to a structure.
%   DEV = READLOG_GNSS(P) reads data from file in path P to the data structure DEV.

switch type
    case 'navicore-bd982'
        R1 = 0;

    case 'gsofexporter-bd982'
        R1 = 1;
end

if isempty(filepath) || filepath(end) == '\' || filepath(end) == '/'
    M = nan(0, 30);
else
    M = csvread(filepath, R1, 0);
end

if nargin > 2
    if length(trim) == 1
        M = M(1:ceil(size(M, 1) * trim), :);  % end trim
    else
        M = M((1+fix((size(M, 1)-1) * trim(1))) : ceil(size(M, 1) * trim(2)), :);  % start & end trim
    end
end

switch type
    case 'navicore-bd982'  % based on NMEA
        dev.utc_hour = M(:, 1);  % UTC hour   of day [hours]
        dev.utc_min  = M(:, 2);  % UTC minute of day [minutes]
        dev.utc_sec  = M(:, 3);  % UTC second of day [seconds]

        dev.t_utc = dev.utc_hour * 3600 + dev.utc_min * 60 + dev.utc_sec;  % [s]

        dev.lat = M(:, 4);  % latitude  [deg]
        dev.lon = M(:, 5);  % longitude [deg]
        dev.hgt = M(:, 6);  % height (ellipsoidal) [m]

        dev.yaw      = deg2rad(M(:, 7));  % yaw angle  [rad]
        dev.tilt     = deg2rad(M(:, 8));  % tilt angle [rad]
        dev.range    = M(:, 9);           % length of internal vector (baseline) [m]

        dev.rmse_e  = M(:, 10);  % RMS error of east  (longitude) [m]
        dev.rmse_n  = M(:, 11);  % RMS error of north (latitude)  [m]
        dev.rmse_u  = M(:, 12);  % RMS error of up    (height)    [m]

        dev.e = M(:, 13);  % east  component of external vector (in ENU) [m]
        dev.n = M(:, 14);  % north component of external vector (in ENU) [m]
        dev.u = M(:, 15);  % up    component of external vector (in ENU) [m]

        dev.soltype_pos = M(:, 16);  % solution type of position    (0..not-valid, 1..autonomous, 2..dgnss,     4..rtk-fixed, 5..rtk-float)
        dev.soltype_ori = M(:, 17);  % solution type of orientation (0..not-valid, 1..autonomous, 2..rtk-float, 3..rtk-fixed, 4..dgnss)

    case 'gsofexporter-bd982'  % based on GSOF+RT17/27
        dev.t_gps = M(:, 1) / 1000;  % gps week time [s]            |GSOF-Time|

        dev.e = M(:, 2);  % east  (in local ENU) [m]                |GSOF-TPlaneENU|
        dev.n = M(:, 3);  % north (in local ENU) [m]                |GSOF-TPlaneENU|
        dev.u = M(:, 4);  % up    (in local ENU) [m]                |GSOF-TPlaneENU|

        dev.rmse_e = M(:, 5);  % rms error of east  (longitude) [m] |GSOF-SIGMA|
        dev.rmse_n = M(:, 6);  % rms error of north (latitude)  [m] |GSOF-SIGMA|
        dev.rmse_u = M(:, 7);  % rms error of up    (height)    [m] |GSOF-SIGMA|

        dev.v_hor = M(:, 8);  % horizontal speed [m/s]              |GSOF-Velocity|
        dev.course= M(:, 9);  % tracking angle (heading) [rad]      |GSOF-Velocity|

        dev.yaw   = M(:, 10);  % yaw angle [rad]                    |GSOF-Attitude|
        dev.pitch = M(:, 11);  % pitch angle [rad]                  |GSOF-Attitude|
        dev.roll  = M(:, 12);  % roll angle [rad]                   |GSOF-Attitude|

        dev.flags_pos = M(:, 13); %                                 |GSOF-TIME|

        dev.lat = M(:, 14);  % latitude [deg]                       |GSOF-LLH|
        dev.lon = M(:, 15);  % longitude [deg]                      |GSOF-LLH|
        dev.hgt = M(:, 16);  % height [m]                           |GSOF-LLH|

        dev.svsused = M(:, 17);   % number of SVs used in solution  |GSOF-TIME|
        dev.v_vert  = M(:, 18);   % vertical speed [m/s]            |GSOF-Velocity|

        dev.flags_ori   = M(:, 19); %                               |GSOF-Attitude|
        dev.svsused_ori = M(:, 20); %                               |GSOF-Attitude|
        dev.mode_ori    = M(:, 21); %                               |GSOF-Attitude|
        dev.range       = M(:, 22); %                               |GSOF-Attitude|

        dev.rmse_yaw   = sqrt(M(:, 23)); % rms error of yaw [rad]   |GSOF-Attitude|
        dev.rmse_pitch = sqrt(M(:, 24)); % rms error of pitch [rad] |GSOF-Attitude|
        dev.rmse_roll  = sqrt(M(:, 25)); % rms error of roll [rad]  |GSOF-Attitude|
        dev.rmse_range = sqrt(M(:, 26)); % rms error of range [m]   |GSOF-Attitude|
end

end
