%% Mean-Shift Video Tracking
% by Sylvain Bernhardt
% July 2008
% Updated March 2012

function [lngth,h,w,mov]=Import_mov(path)
infomov = VideoReader(path);
lngth = infomov.numberOfFrames;%video kaç frameden oluþuyor? 
h = infomov.Height;%videonun bir frameinin yüksekliði 
w = infomov.Width;%videonun bir frameinin geniþliði
mov(1:lngth) = struct('cdata', zeros(h, w, 3, 'uint8'), 'colormap', []);
% her bir frame mov yapýsýnýn bir elemaný olacak
for k = 1 : lngth
    mov(k).cdata = read(infomov, k);
end