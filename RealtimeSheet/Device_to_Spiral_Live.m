N = 12*8;
r = 2^(1/12);

f_i = 33; % initial freq 
note_i = -1; % initial note
f = f_i*r.^(-32+note_i:N-2);
theta = pi/2 - 2*pi*log2(f/f_i);
A = 1./f;

% parted spiral line
P = 2;

f_P = f_i*r.^(-32+note_i:1/P:N-2);
theta_P = pi/2 - 2*pi*log2(f_P/f_i);
A_P = 1./f_P;

l = polarplot(theta, A,'bo');
s = polarplot(theta_P, A_P,'b-');

R = A_P(1);

rlim([0 R])
set(gca,'thetaticklabel',{'C' 'B' 'A#' 'A' 'G#' 'G' 'F#' 'F' 'E' 'D#' 'D' 'C#' })
set(gca,'rticklabel',[])
hold on

for i=1:N
    ho(i)=polarplot(theta(i),A(i),'ro');
    hl(i)=polarplot([theta(i) theta(i)],[0 A(i)],'r-');
    ho(i).Visible = 'off';
    hl(i).Visible = 'off';
    % hold on
end

% All data on and off
%p.XData = theta(plot_note - 35);
%p.YData = A(plot_note - 35);

plot_note = [];

% off note가 있는 경우 : true
% off note가 없는 경우 : false
off_note_exp = true;

mididevinfo
device = mididevice('Launchkey 25')

while 1
    msgArray = midireceive(device);

    on_no = msgArray([msgArray.Type] == 1);
    on_note = [on_no.Note];
    
    if off_note_exp
        off_note = [msgArray([msgArray.Type] == 2).Note];
    else
        off_note = [on_no([on_no.Velocity] == 0).Note];
    end
    
    plot_note = horzcat(plot_note, on_note);
   
    if ~isempty(plot_note)
        set(ho(plot_note - 35),'visible','on');
        set(hl(plot_note - 35),'visible','on');
    end
    
    for i = 1:length(off_note)
        off_index = (plot_note == off_note(i));
        
        set(ho(plot_note(off_index)-35),'visible','off');
        set(hl(plot_note(off_index)-35),'visible','off');
        
        plot_note(off_index) = [];
        
    end

    drawnow;
end