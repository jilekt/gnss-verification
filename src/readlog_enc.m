function dev = readlog_enc(filepath, type, trim)  % VALID #1

FIELD_COUNT = 17;

fid = fopen(filepath, 'r');
M = textscan(fid, repmat('%f', 1, FIELD_COUNT), 'CollectOutput', true, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'Headerlines', 1);
fclose(fid);
M = M{1};

if nargin > 2
    M = M(gettrimmedidx(size(M, 1), trim), :);
end

switch type
    case 'sp-cepl'
        % remove blocks with corrupted time sync or timing
        sub_id = M(:, 10);
        b_idx = [false; diff(sub_id) ~= 1 & diff(sub_id) ~= -50];  % get idx from bad block
        discard_idx = [];
        if sum(b_idx) > 0
            for i = find(b_idx).'
                discard_idx = [discard_idx, find(sub_id(1:i-1) == 0, 1, 'last') : (i + find(sub_id(i:end) == 0, 1, 'first') - 2)];
            end
            
            M(discard_idx, :) = [];
            warning('%d blocks with corrupted time sync were discarded!', sum(b_idx))
        end

        % trim data; first and last need to be master samples (synced with 1 PPS)
        M(1:(find(M(:, 15) == 0, 1, 'first')-1), :) = [];
        M((find(M(:, 15) == 0, 1, 'last')+1):end, :) = [];
       
        % parse items
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

        dev.sample_type = M(:, 15); % sample type [0..master (synced with 1 PPS), 1..slave]
        dev.timer_sync  = M(:, 16); % state of internal timer in mcu [ticks], valid only for a master sample
        dev.ticks_sync  = M(:, 17); % encoder state when 1-turn signal comes
end

end
