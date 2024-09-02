# 3DspiralSheet 
by. QBOL

* 디바이스마다 Midi off 메세지의 유무가 다르므로, 코드 설정이 필요합니다.
* DAW 등으로 Midi 파일을 재추출하면 off 메세지가 생길 수 있습니다.
  
### Design An Audio Plugin Example
DAW 적용을 위한 VST 개발 (matlab)
* 현재는 example만 있음

### Python App
.wav file to continuous spiral

module you need:
numpy
tkinter
pyinstaller
matplotlib
librosa
os
pygame

to make .exe: 
> pyinstaller -w cont_spiral.py

to use:
.mp3 .wav 있는 폴더 선택
음원 선택 후 execute

### Realtime Sheet
midi input Device를 통해 실시간으로 음표를 입력 받아서 출력할 수 있음

### 3D Spiral Code
`MIDIToSpiral5.mlx` <br> 
`Midi_to_Spiral_video.mlx` (Advanced) <br> 
`VideoAudioConcat.ipynb` 오디오와 영상을 합치기 위한 파이썬 코드 

### QBOL 3D Spiral Score WIKI
http://optics.dgist.ac.kr/wiki/index.php/3D_Spiral_Score
