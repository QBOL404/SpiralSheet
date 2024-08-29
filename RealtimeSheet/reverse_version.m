N = 12*8;
r = 2^(1/12);
f_i = 33;
note_i = -4; 
f = f_i * r.^(-32 + note_i:N-2);
theta = pi/2 - 2*pi*log2(f/f_i);
R = log2(f);
P = 2;
f_P = f_i * r.^(-32 + note_i:1/P:N-2);
theta_P = pi/2 - 2*pi*log2(f_P/f_i); 
R_P = log2(f_P); 
s = polarplot(theta_P, R_P, 'b-');
rlim([0 max(R_P)-2.9]);

set(gca,'thetaticklabel',{'C' 'B' 'A#' 'A' 'G#' 'G' 'F#' 'F' 'E' 'D#' 'D' 'C#'});
set(gca,'rticklabel',[]);

hold on


for i = 1:N
    ho(i) = polarplot(theta(i), R(i), 'ro', 'MarkerFaceColor', [1 .6 .6], 'MarkerSize', 10);
    hl(i) = polarplot([theta(i) theta(i)], [0 R(i)], 'r-');
    ho(i).Visible = 'off';
    hl(i).Visible = 'off';
end


mididevinfo
device = mididevice(0);
plot_note = [];
off_note_exp = false;
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
        set(ho(plot_note - midi_note_i),'visible','on');
        set(hl(plot_note - midi_note_i),'visible','on');
    end
    for i = 1:length(off_note)
        off_index = (plot_note == off_note(i));
        set(ho(plot_note(off_index)-midi_note_i),'visible','off');
        set(hl(plot_note(off_index)-midi_note_i),'visible','off');
        plot_note(off_index) = [];
    end
    drawnow;
end