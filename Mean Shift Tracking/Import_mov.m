%% Mean-Shift Video Tracking
% by Sylvain Bernhardt
% July 2008
% Updated March 2012

function [lngth,h,w,mov]=Import_mov(path)
infomov = VideoReader(path);
lngth = infomov.numberOfFrames;%video ka� frameden olu�uyor? 
h = infomov.Height;%videonun bir frameinin y�ksekli�i 
w = infomov.Width;%videonun bir frameinin geni�li�i
mov(1:lngth) = struct('cdata', zeros(h, w, 3, 'uint8'), 'colormap', []);
% her bir frame mov yap�s�n�n bir eleman� olacak
for k = 1 : lngth
    mov(k).cdata = read(infomov, k);
end