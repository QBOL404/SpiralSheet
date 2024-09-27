clear;
clc;
close;

function vel = cal_velocity(x)
    vel = x - 1;
    if vel < 1
        vel = 1;
    end
end

N = 12*8;
r = 2^(1/12);

f_i = 33; % initial freq 
note_i = -4; % initial note
f = f_i*r.^(-32+note_i:N-2);
theta = pi/2 - 2*pi*log2(f/f_i);
A = 1./f;

% parted spiral line
P = 1;

f_P = f_i*r.^(-32+note_i:1/P:N-2);
theta_P = pi/2 - 2*pi*log2(f_P/f_i);
A_P = 1./f_P;

log_R = log2(A); % 추가
log_R_P = log2(1./f_P); % 추가
midi_note_i = 20;

%l = polarplot(theta, A,'bo');
%s = polarplot(theta_P, A_P,'b-');
s = polarplot(theta_P, log_R_P,'b-'); % 추가

%R = A_P(1);
R = log_R_P(1); % 추가

%rlim([0 R])
min_R = min(log_R_P) % 계산 속도를 위해 수정 
rlim([min_R R]) % 추가
set(gca,'thetaticklabel',{'C' 'B' 'A#' 'A' 'G#' 'G' 'F#' 'F' 'E' 'D#' 'D' 'C#' })
set(gca,'rticklabel',[])
hold on

for i=1:N
    ho(i)=polarplot(theta_P(i),log_R_P(i),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
    hl(i)=polarplot([theta_P(i) theta_P(i)],[min_R log_R_P(i)],'r-');
    ho(i).Visible = 'off';
    hl(i).Visible = 'off';
    % hold on
end

% off note가 있는 경우 : true
% off note가 없는 경우 : false
off_note_exp = false;

mididevinfo
device = mididevice(0);

note_list = zeros(1, N);
note_vel = ones(1, N);
pedal_signal = false;

while 1
    msgArray = midireceive(device);

    note_list([msgArray([msgArray.Type] == 1).Note]) = 1;
    CCsignal = msgArray([msgArray.Type] == 12);

    if length(CCsignal)==1 % 에러 방지를 막고자, 길이가 1일때만 취급. 
        % CCsignal
        if CCsignal.CCNumber == 64 & CCsignal.CCValue > 0
            "pedal on"
            pedal_signal = true;
        end

        if CCsignal.CCNumber == 64 & CCsignal.CCValue == 0
            "pedal off"
            pedal_signal = false;
        end
    end
    
    if pedal_signal == false
        note_vel([msgArray([msgArray.Type] == 1).Note]) = [msgArray([msgArray.Type] == 1).Velocity];
    else
        note_vel([msgArray([msgArray([msgArray([msgArray.Type] == 1).Velocity] ~= 0).Type] == 1).Note]) = [msgArray([msgArray([msgArray([msgArray.Type] == 1).Velocity] ~= 0).Type] == 1).Velocity];
    end

    if off_note_exp
        note_list([msgArray([msgArray.Type] == 2).Note]) = 0;
    else
        if length(msgArray([msgArray.Type] == 1))>0
            msgArray([msgArray.Type] == 1);
        end
        % ControlChange 부분을 필터링 하기 위해 필터링 추가함.
        % 코드가 갈수록 보기 어려워져서 읽기 쉽게 정리해야 할 것 같음.
        note_list([msgArray([msgArray([msgArray([msgArray.Type] == 1).Velocity] == 0).Type] == 1).Note]) = 0;
        %note_list([msgArray([msgArray([msgArray.Type] == 1).Velocity] == 0).Note]) = 0;
    end
    
    note_vel = arrayfun(@cal_velocity, note_vel);
    vel = num2cell(note_vel);
    [ho.MarkerSize] = vel{:};
    
    set(ho(note_list == 1),'visible','on');
    set(hl(note_list == 1),'visible','on');
    
    if pedal_signal == true
        
    else
        set(ho(note_list == 0),'visible','off');
    end
    %set(ho(note_list == 0),'visible','off');
    set(hl(note_list == 0),'visible','off');

    drawnow;
end