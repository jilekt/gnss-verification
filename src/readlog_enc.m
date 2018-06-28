function dev = readlog_enc(filepath, type, trim)  % VALID #1

M = dlmread(filepath, ' ', 1, 0);

if nargin > 2
    M = M(gettrimmedidx(size(M, 1), trim), :);
end

switch type
    case 'sp-cepl'
        dev.sample_id = M(:, 1);  % Sample ID         [-]
        dev.utc_year  = M(:, 2);  % UTC year          [years]
        dev.utc_mon   = M(:, 3);  % UTC month         [months]
        dev.utc_day   = M(:, 4);  % UTC day           [days]

        dev.utc_hour  = M(:, 5);  % UTC hour   of day [hours]
        dev.utc_min   = M(:, 6);  % UTC minute of day [minutes]
        dev.utc_sec   = M(:, 7);  % UTC second of day [seconds]

        dev.t_utc = dev.utc_hour * 3600 + dev.utc_min * 60 + dev.utc_sec;  % [s]

        dev.gnss_state1 = M(:, 8);  % GNSS state 1
        dev.gnss_state2 = M(:, 9);  % GNSS state 2

        dev.sub_id   = M(:, 10);  % Sub-ID (0..49, or 0..50), 0..master (synced with 1 PPS)
        dev.ticks    = M(:, 11);  % number of ticks from encoder (0..19999) [ticks]
        dev.turns    = M(:, 12);  % number of full (360 deg) turns [turns]
        dev.setpoint = M(:, 13);  % motor set point [usteps/s]
        dev.meas_id  = M(:, 14);  % measurement ID (has same conditions)

        dev.timerstate  = M(:, 16); % state of internal timer in mcu [ticks], valid only for a master sample
        dev.sample_type = M(:, 15); % sample type [0..master (synced with 1 PPS), 1..slave]
end

end