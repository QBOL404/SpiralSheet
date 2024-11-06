clear;
clc;
close;
clf;

% GUI part
function bool = click()
    bool = true;
end

gui_fig = uifigure;

update = uibutton(gui_fig, "state", "Text", "Update", "Position", [340 10 100 50]);

octave_slide = uislider(gui_fig, "range", "Position", [20, 300, 200, 3], "Limits", [0, 8]);
octave_slide.MajorTicks = [0, 1, 2, 3, 4, 5, 6, 7, 8];
octave_slide.MinorTicks = [];

direction_gui = uibuttongroup(gui_fig, "Title", 'Direction', "Position",[170 10 150 130]);
direction_b1 = uiradiobutton(direction_gui,"Text","Top->Down","Position",[10 20 130 30]);
direction_b2 = uiradiobutton(direction_gui,"Text","Down->Top","Position",[10 60 130 30]);

scale_gui = uibuttongroup(gui_fig, "Title", 'Scale', "Position",[10 10 150 130]);
scale_b1 = uiradiobutton(scale_gui,"Text","Linear","Position",[10 20 130 30]);
scale_b2 = uiradiobutton(scale_gui,"Text","Log","Position",[10 60 130 30]);
% GUI part

% velocity 업데이트 함수.
function vel = update_velocity(x)
    vel = x - 1;
    % MarkerSize가 0일 경우 오류가 발생하기에 0이 되는 것을 방지.
    if vel < 1
        vel = 1; 
    end
end

% plot parameter 업데이트 함수.
function [theta_P, y] = dev(N, scale)
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

    if scale == 0
        y = 1./f_P;
        return
    else
        y = log2(1./f_P);
        return
    end
end

% 나선악보를 그리기 위한 기초 변수 선언.
N = 12*8;
[theta_P, log_R_P] = dev(N, 0); % type: linear=0, log=1
midi_note_i = 20; % -- 이렇게 해버리면 index가 남긴 한데 
% 나선악보를 그리기 위한 기초 변수 선언

n_start = 1 + 12*round(octave_slide.Value(1));
n_end = 12*round(octave_slide.Value(2));

s = polarplot(theta_P(n_start:n_end), log_R_P(n_start:n_end), 'b-'); % 추가

R = log_R_P(1); % 추가

%rlim([0 R])
min_R = min(log_R_P); % 계산 속도를 위해 수정 
rlim([min_R R]); % 추가
set(gca,'thetaticklabel',{'C' 'B' 'A#' 'A' 'G#' 'G' 'F#' 'F' 'E' 'D#' 'D' 'C#' });
set(gca,'rticklabel',[]);
set(gcf,'position',[300,150,800,800]);
hold on

% 각 plot point 객체 생성
for i=1:N
    ho(i)=polarplot(theta_P(i),log_R_P(i),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
    hl(i)=polarplot([theta_P(i) theta_P(i)],[min_R log_R_P(i)],'r-', LineWidth=1.5);
    ho(i).Visible = 'off';
    hl(i).Visible = 'off';
end

%{
midi device에 따라 note_off 신호가 따로 있거나
note_on 신호의 velocity가 0일 때 note_off를 표현함.
off note 신호가 있는 경우: false로 설정
off note 신호가 없는 경우: true로 설정
%}
only_on_signal = true;
% midi device를 device 변수에 할당.
mididevinfo
device = mididevice(1);

note_list = zeros(1, N); % index: note number, 값이 1일 경우 켜진 note / 0일 경우 꺼진 note.
velocity_list = ones(1, N); % 각 note의 velocity 값 저장.
pedal_signal = false; % pedal_signal 초기화.

% while문을 돌며 midi signal에 따라 나선악보 업데이트.
while 1
    % GUI part
    if update.Value
        % WIP
        disp("Update start");
        N = 12*8;
        [theta_P, log_R_P] = dev(N, scale_b2.Value); % type: linear=0, log=1
        midi_note_i = 20; % -- 이렇게 해버리면 index가 남긴 한데 
        n_start = 1 + 12*round(octave_slide.Value(1));
        n_end = 12*round(octave_slide.Value(2));
        s.XData = theta_P(n_start:n_end);
        s.YData = log_R_P(n_start:n_end);

        if n_start < n_end
            rlim([min(log_R_P(n_start:end)) max(log_R_P(n_start:end))]);
        end
        if direction_b2.Value == 1
            for i=1:N
                ho(i)=polarplot(theta_P(N-i+1),log_R_P(N-i+1),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
                hl(i)=polarplot([theta_P(i) theta_P(N-i+1)],[min(log_R_P) log_R_P(N-i+1)],'r-', LineWidth=1.5);
                ho(i).Visible = 'off';
                hl(i).Visible = 'off';
            end
        else
            for i=1:N
                ho(i)=polarplot(theta_P(i),log_R_P(i),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
                hl(i)=polarplot([theta_P(i) theta_P(i)],[min(log_R_P) log_R_P(i)],'r-', LineWidth=1.5);
                ho(i).Visible = 'off';
                hl(i).Visible = 'off';
            end
        end
        update.Value = false;
        disp("Finish");
    end
    
    % GUI part

    msgArray = midireceive(device); % midi device에서 midi signal을 받아옴.
    %msgArray = [];
    if isempty(msgArray) % 입력이 없을 경우
        pause(0.01)
        drawnow;
        continue
    end
    
    note_list([msgArray([msgArray.Type] == 1).Note]-midi_note_i) = 1; % signal의 note number에 따라 index 값을 1로 변경.
    CC_signal = msgArray([msgArray.Type] == 12); % pedal signal만 필터링.
    note_signal = msgArray([msgArray.Type] == 1); % CC 신호와 아예 분리로 수정. > 속도면에서 단점이 있으면 

    % -- pedal catch
    if length(CC_signal)==1 % 에러 방지를 막고자, 길이가 1일때만 취급. 
        % CCsignal
        if CC_signal.CCNumber == 64 & CC_signal.CCValue > 0
            disp("pedal on")
            pedal_signal = true;
        end

        if CC_signal.CCNumber == 64 & CC_signal.CCValue == 0
            disp("pedal off")
            pedal_signal = false;
        end
    end
    
    % -- velocity control
    
    if pedal_signal == false
        %velocity_list([msgArray([msgArray.Type] == 1).Note]) = [msgArray([msgArray.Type] == 1).Velocity];
        velocity_list([note_signal.Note]-midi_note_i) = [note_signal.Velocity];
    else
        % pedal singal이 있을 경우 note 정보만 받아오기 위한 필터링이 필요함.
        %velocity_list([msgArray([msgArray([msgArray([msgArray.Type] == 1).Velocity] ~= 0).Type] == 1).Note]) = [msgArray([msgArray([msgArray([msgArray.Type] == 1).Velocity] ~= 0).Type] == 1).Velocity];
        velocity_list([note_signal([note_signal.Velocity]~=0).Note]-midi_note_i) = [note_signal([note_signal.Velocity] ~= 0).Velocity];
    end

    % note_off 신호 존재에 따른 note 업데이트.
    if ~only_on_signal
        note_list([msgArray([msgArray.Type] == 2).Note]-midi_note_i) = 0; % -- 에러 발생 가능 코드 
    else
        % -- 리스트 확인 코드 
        % if length(msgArray([msgArray.Type] == 1))>0
        %     msgArray([msgArray.Type] == 1);
        % end
        % -- 

        note_list([note_signal([note_signal.Velocity] == 0).Note]-midi_note_i) = 0;
        %note_list([msgArray([msgArray([msgArray.Type] == 1).Velocity] == 0).Note]) = 0;
    end
    
    %{
    velocity 변화를 makersize에 업데이트. arrayfun() 함수로 velocity_list의 값마다
    update_velocity() 함수 적용.
    각 point 객체에 한번에 정보를 업데이트하기 위해 velocity_list 리스트를 cell 형태로 변경.
    %}
    velocity_list = arrayfun(@update_velocity, velocity_list);
    vel = num2cell(velocity_list);
    [ho.MarkerSize] = vel{:};
    
    % note_list의 값이 1인 index만 point와 line을 킴.
    set(ho(note_list==1),'visible','on');
    set(hl(note_list==1),'visible','on');
    
    % pedal_signal이 없을 경우 note를 바로 끔, 있을 경우 시간에 따라 작어짐.
    if pedal_signal == true
        
    else
        set(ho(note_list == 0),'visible','off');
    end
    %set(ho(note_list == 0),'visible','off');
    set(hl(note_list == 0),'visible','off');

    drawnow;
end