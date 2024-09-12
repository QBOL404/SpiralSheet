N = 12*8;
r = 2^(1/12);
f_i = 33; % initial freq
note_i = -4; % initial note
f = f_i*r.^(-32+note_i:N-2);
theta = pi/2 - 2*pi*log2(f/f_i);
A = 1./f;
log_R = log2(A); % 추가
midi_note_i = 20;
% parted spiral line
P = 2;
f_P = f_i*r.^(-32+note_i:1/P:N-2); 
theta_P = pi/2 - 2*pi*log2(f_P/f_i);
log_R_P = log2(1./f_P); % 수정
%l = polarplot(theta, A,'bo');
s = polarplot(theta_P, log_R_P, 'b-');
R = log_R_P(1);
rlim([min(log_R_P) R]) % 0말고 최소로 시작해봤음
set(gca,'thetaticklabel',{'C' 'B' 'A#' 'A' 'G#' 'G' 'F#' 'F' 'E' 'D#' 'D' 'C#' })
set(gca,'rticklabel',[])
hold on
for i = 1:N
    ho(i) = polarplot(theta(i), log_R(i), 'ro', 'MarkerFaceColor', [1 .6 .6], 'MarkerSize', 10);
    hl(i) = polarplot([theta(i) theta(i)], [min(log_R) log_R(i)], 'r-', 'LineWidth',1); %..
    ho(i).Visible = 'off';
    hl(i).Visible = 'off';
end
% All data on and off
%p.XData = theta(plot_note - 35);
%p.YData = A(plot_note - 35);
plot_note = [];
% off note가 있는 경우 : true
% off note가 없는 경우 : false
off_note_exp = false;
mididevinfo
device = mididevice(0)
while 1
    msgArray = midireceive(device);

    if length(msgArray)>0
        msgArray
    end
    % -- midi signal check
    % if length(msgArray)>0
    %      msgArray
    % end
    
    on_no = msgArray([msgArray.Type] == 1);
    on_note = [on_no.Note];

    CCsignal = msgArray([msgArray.Type] == 12);

    if length(CCsignal)>0
        if CCsignal.CCNumber == 64 & CCsignal.CCValue ==127
            "pedal on"
        end

        if CCsignal.CCNumber == 64 & CCsignal.CCValue == 0
            "pedal off"
        end
    end

    %on_velocity = sqrt([on_no.Velocity]+0.01)*3;
    on_velocity = ([on_no.Velocity]+1)/3;
    

    if off_note_exp
        off_note = [msgArray([msgArray.Type] == 2).Note];
    else
        off_note = [on_no([on_no.Velocity] == 0).Note];
    end
    
    plot_note = horzcat(plot_note, on_note);
    if ~isempty(plot_note)
        %set(ho(plot_note - midi_note_i), {'MarkerSize'},{plot_note});
        n = length(on_note);
        for i=1:n
          set(ho(plot_note - midi_note_i),'MarkerSize', on_velocity(i));
          set([hl(plot_note - midi_note_i) ho(plot_note - midi_note_i)] ,'visible','on');       
        end
    end
    
    for i = 1:length(off_note)
        off_index = (plot_note == off_note(i));
        
        set([hl(plot_note(off_index)-midi_note_i) ho(plot_note(off_index)-midi_note_i)],'visible','off');
        plot_note(off_index) = [];
    end
    drawnow;
end