clear;
clc;
close all force
clf;

% GUI part
%{
function openLink(~, ~)
    url = 'https://sites.google.com/view/qbolab';
    web(url, '-browser');
end
%}
gui_fig = uifigure("Name", "Control Panel", "Position", [1500, 600, 560, 400]);

update = uibutton(gui_fig, "state", "Text", "Apply", "Position", [450 10 100 50], "FontSize", 20, "FontColor", 'r');
update.Tooltip = "Apply the modified settings.";

north_group = uibuttongroup(gui_fig, "Title", "Control Pitch", "Position", [10 180 120 70], "FontSize", 18);
north_group.Tooltip = "Change the note displayed at the 12 o'clock position.";
north_note = uidropdown(north_group, "FontSize", 15);
north_note.Items = ["C","B","A#","A","G#","G","F#","F","E","D#","D","C#"];
north_note.Position = [20 5 80 30];
north_note.Value = "A";

slide_group = uibuttongroup(gui_fig, "Title", "Octave range", "Position", [10, 300, 240, 90], "FontSize", 18);
slide_group.Tooltip = "Adjust the octave display range.";
octave_slide = uislider(slide_group, "range", "Position", [15, 40, 200, 3], "Limits", [0, 8], "FontSize", 18);
octave_slide.MajorTicks = [0, 1, 2, 3, 4, 5, 6, 7, 8];
octave_slide.MinorTicks = [];

direction_gui = uibuttongroup(gui_fig, "Title", 'Direction', "Position",[170 10 150 130], "FontSize", 18);
direction_gui.Tooltip = "Change the direction in which the pitch increases.";
direction_b1 = uiradiobutton(direction_gui,"Text","Top->Down","Position",[10 20 130 30], "FontSize", 18);
direction_b2 = uiradiobutton(direction_gui,"Text","Down->Top","Position",[10 60 130 30], "FontSize", 18);

scale_gui = uibuttongroup(gui_fig, "Title", 'Scale', "Position",[10 10 150 130], "FontSize", 18);
scale_gui.Tooltip = "Change the scale of the notes.";
scale_b1 = uiradiobutton(scale_gui,"Text","Linear","Position",[10 20 130 30], "FontSize", 18);
scale_b2 = uiradiobutton(scale_gui,"Text","Log","Position",[10 60 130 30], "FontSize", 18);

%homepage = uicontrol(gui_fig, "Tooltip", "L",  "Position", [500, 10, 20, 20], 'Callback', @openLink);
% GUI part


% velocity 업데이트 함수.
function vel = update_velocity(x)
    vel = x - 1;
    % MarkerSize가 0일 경우 오류가 발생하기에 0이 되는 것을 방지.
    if vel < 1
        vel = 1; 
    end
end

% plot parameter 업데이트 함수. 노트 개수(N)와 scale을 
function [theta_P, y, l_theta_P, l_y, P] = dev(N, scale)
    r = 2^(1/12);
    
    f_i = 55; % initial freq 
    note_i = 33; % initial note
    
    % parted spiral line
    P = 5;
    
    f_P = f_i*r.^(-note_i+1:1:N-2);
    theta_P = pi/2 - 2*pi*log2(f_P/f_i);
    
    l_f_P = f_i*r.^(-note_i+1:1/P:N-2);
    l_theta_P = pi/2 - 2*pi*log2(l_f_P/f_i);

    if scale == 0
        y = 1./f_P;
        l_y = 1./l_f_P;
        return
    else
        y = log2(1./f_P);
        l_y = log2(1./l_f_P);
        return
    end
end

% 나선악보를 그리기 위한 기초 변수 선언.
N = 12*8+12;
[theta_P, log_R_P, l_theta_P, l_log_R_P, P] = dev(N, 0); % type: linear=0, log=1

n_start = 1 + 12*round(octave_slide.Value(1))+12;

r = linspace(0, 1, length(l_log_R_P)).^(0.5);
r = (r - min(r)) / (max(r) - min(r));
line_color = 1 - r;

s_base = polarplot(l_theta_P, l_log_R_P, 'Color', [0, 0, 0, 0]);

R = log_R_P(1); % 추가

note_label = ["C","B","A#","A","G#","G","F#","F","E","D#","D","C#","C","B","A#","A","G#","G","F#","F","E","D#","D","C#","C","B","A#","A","G#","G","F#","F","E","D#","D","C#"];

min_R = min(log_R_P); % 계산 속도를 위해 수정 

rlim([min(log_R_P(n_start:end)) max(log_R_P(n_start:end))]);
set(gca,'thetaticklabel', note_label(1:12));
set(gca,'rticklabel',[]);
set(gcf,'position',[300,150,800,800]);
set(gcf, "Name", "Spiral Sheet")
hold on

% 배경 라인 객체 생성.
for i=1:length(l_theta_P)-1
    s(i) = polarplot(l_theta_P(i:i+1), l_log_R_P(i:i+1), 'Color', [line_color(i), 0,1 - line_color(i)]);
    s(i).Visible = 'on';
end

% 각 plot point 객체 생성
for i=1:N
    ho(i)=polarplot(theta_P(i+12),log_R_P(i+12),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
    hl(i)=polarplot([theta_P(i+12) theta_P(i+12)],[min_R log_R_P(i+12)],'r-', LineWidth=1.5);
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
device = mididevice(0);

note_list = zeros(1, N); % index: note number, 값이 1일 경우 켜진 note / 0일 경우 꺼진 note.
velocity_list = ones(1, N); % 각 note의 velocity 값 저장.
pedal_signal = false; % pedal_signal 초기화.

% while문을 돌며 midi signal에 따라 나선악보 업데이트.
while 1
    % GUI part
    if update.Value
        % WIP
        disp("Update start");
        for i=1:N
            ho(i).Visible = 'off';
            hl(i).Visible = 'off';
        end
        for i=1:length(l_theta_P)-1
            s(i).Visible = 'off';
        end
        N = 12*8;
        [theta_P, log_R_P, l_theta_P, l_log_R_P, P] = dev(N, scale_b2.Value); % type: linear=0, log=1
        
        n_start = 1 + 12*round(octave_slide.Value(1))+12;
        n_end = 12*round(octave_slide.Value(2))+12;

        n_n = find(strcmp(note_label, north_note.Value), 2);
        n_n = n_n(2);
        
        plot_theta = l_theta_P(P*n_start+n_n-16:P*n_end+n_n-16);
        plot_log = l_log_R_P(P*n_start+n_n-16:P*n_end+n_n-16);
        r = linspace(0, 1, length(plot_log)).^(0.5);
        r = (r - min(r)) / (max(r) - min(r));
        line_color = 1 - r;

        if direction_b2.Value == 1
            set(gca,'thetaticklabel', flip(note_label(n_n-8:3+n_n)));
            if n_start < n_end
                rlim([min(plot_log(:)) max(plot_log(:))]);
            end
            for i=1:length(plot_log)-1
                s(i) = polarplot(plot_theta(i:i+1), plot_log(i:i+1), 'Color', [1 - line_color(i), 0, line_color(i)]);
                s(i).Visible = 'on';
            end
            for i=1:N
                ho(i)=polarplot(theta_P(127+3-(i+n_n)),log_R_P(127+3-(i+n_n)),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
                hl(i)=polarplot([theta_P(127+3-(i+n_n)) theta_P(127+3-(i+n_n))],[min(log_R_P(n_start+n_n-16:n_end+n_n-16)) log_R_P(127+3-(i+n_n))],'r-', LineWidth=1.5);
                ho(i).Visible = 'off';
                hl(i).Visible = 'off';
            end
        else
            set(gca,'thetaticklabel', note_label(n_n-3:8+n_n));
            if n_start < n_end
                rlim([min(plot_log(:)) max(plot_log(:))]);
            end
            for i=1:length(plot_log)-1
                s(i) = polarplot(plot_theta(i:i+1), plot_log(i:i+1), 'Color', [line_color(i), 0,1 - line_color(i)]);
                s(i).Visible = 'on';
            end
            for i=1:N
                ho(i)=polarplot(theta_P(i-4+n_n),log_R_P(i-4+n_n),'ro','MarkerFaceColor',[1 .6 .6],'MarkerSize',10);
                hl(i)=polarplot([theta_P(i-4+n_n) theta_P(i-4+n_n)],[min(log_R_P(n_start+n_n-16:n_end+n_n-16)) log_R_P(i-4+n_n)],'r-', LineWidth=1.5);
                ho(i).Visible = 'off';
                hl(i).Visible = 'off';
            end
        end
        update.Value = false;
        disp("Finish");
    end
    
    % GUI part

    %msgArray = midireceive(device); % midi device에서 midi signal을 받아옴.
    msgArray = [];
    % Print midi
    if length(msgArray)>0
        msgArray
    end

    if isempty(msgArray) % 입력이 없을 경우velocity만 업데이트.
        velocity_list = arrayfun(@update_velocity, velocity_list);
        vel = num2cell(velocity_list);
        [ho.MarkerSize] = vel{:};
        pause(0.01)
        drawnow;
        continue
    end
    
    % signal의 note number에 따라 index 값을 1로 변경.
    note_list([msgArray([msgArray.Type] == 1).Note]) = 1; 
    CC_signal = msgArray([msgArray.Type] == 12); 
    note_signal = msgArray([msgArray.Type] == 1); 

    % CC 신호와 아예 분리로 수정. > 속도면에서 단점이 있으면 

    % -- pedal catch
    if length(CC_signal)==1 % 길이가 1일때만 
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
        velocity_list([note_signal.Note]) = [note_signal.Velocity];
    else
       velocity_list([note_signal([note_signal.Velocity]~=0).Note]) = [note_signal([note_signal.Velocity] ~= 0).Velocity];
    end

    % note_off 신호 존재에 따른 note 업데이트.
    if ~only_on_signal
        note_list([msgArray([msgArray.Type] == 2).Note]) = 0; % -- 에러 발생 가능 코드 
    else

        note_list([note_signal([note_signal.Velocity] == 0).Note]) = 0;
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
    set(ho(note_list==1), 'MarkerFaceColor', [1 .6 .6], 'visible','on');
    set(hl(note_list==1),'visible','on');
    
    % pedal_signal이 없을 경우 note를 바로 끔, 있을 경우 시간에 따라 작어짐.
    if pedal_signal == true
        
    else
        set(ho(note_list == 0),'visible','off');
    end
    % 잔음 노트의 색을 파란색으로 변경.
    set(ho(note_list == 0), 'MarkerFaceColor',[1, .8, .8]);
    set(hl(note_list == 0),'visible','off');

    drawnow;
end