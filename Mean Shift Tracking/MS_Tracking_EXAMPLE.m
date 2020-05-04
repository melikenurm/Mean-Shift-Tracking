%% Mean-Shift Video Tracking
% by Sylvain Bernhardt
% July 2008
%% Description
% This is a simple example of how to use
% the Mean-Shift video tracking algorithm
% implemented in 'MeanShift_Algorithm.m'.
% It imports the video 'Ball.avi' from
% the 'Videos' folder and tracks a selected
% feature in it.
% The resulting video sequence is played after
% tracking, but is also exported as a AVI file
% 'Movie_out.avi' in the 'Videos' folder.

clear all
close all

%% Import movie and time it with tic/toc
tic
[Length,height,width,Movie]=Import_mov('Videos/ball.avi');
toc
%% Variables 
index_start = 1;%videonun frame nosunu tutacak indis
% mean shift convergence benzerlik e�i�i, bu de�erin alt�ndaysa hedef bulundu
f_thresh = 0.16;%f_thresh = 0.16;
% mean shift conv. itr. say�s�, her framede en fazla bu itr. kadar ort. hesaplanacak
max_it = 15;%pembe i�in 15, ye�il 30, mavi 5
% se�ilen b�lge kadar boyutlu kernel penceresi(her noktan�n a��rl���n� belirleyecek)
kernel_type = 'Epanechnikov';%kernel_type = 'Epanechnikov';
radius = 2;%radius = 2;

%% Target Selection in Reference Frame
%ilk framede takip edilecek objeyi se�me
%se�ilen b�lge(T), sol �st k��esi(x0,y0), y�ksekli�i(H) ve geni�li�i(W)
[T,x0,y0,H,W] = Select_patch(Movie(index_start).cdata,0);
pause(0.2);

%% Run the Mean-Shift algorithm
% Calculation of the Parzen Kernel window
%se�ilen b�y�kl�kte parzen window, gauss da��l�m�ndan a��rl�klar
%se�ilen alan�n merkezindeki piksellerin a��rl��� daha y�ksek olsun objeyi
%temsil etme g�c� y�ksek olan birimler
%a��rl�k penceresi(k), x y�n�ndeki gradyeni(gx), y y�n�ndeki gradyeni(gy)
[k,gx,gy] = Parzen_window(H,W,radius,kernel_type,0);
% Conversion from RGB to Indexed colours
% to compute the colour probability functions (PDFs)
%her renk tonuna bir index atanarak g�r�nt�ler index numaralar� �eklinde
%ifade ediliyor
[I,map] = rgb2ind(Movie(index_start).cdata,65536);
Lmap = length(map)+1;%ka� farkl� ton var
T = rgb2ind(T,map);%se�ilen b�lge de ilk g�r�nt�de belirlenen indexler �eklinde ifade ediliyor
% Estimation of the target PDF
% se�ilen b�lgedeki her bir renk tonunun konumsal a��rl���na ba�l� olarak
% histogram�n(q) hesaplanmas�
q = Density_estim(T,Lmap,k,H,W,0);
% Flag for target loss
loss = 0;%hedefi kaybetti mi?
% Similarity evolution along tracking
f = zeros(1,(Length-1)*max_it);%her framede max_it say�s� kadar hesaplanan benzerlik de�erleri
% Sum of iterations along tracking and index of f
f_indx = 1;%ka��nc� benzerlik yaz�lacak? 
% Draw the selected target in the first frame
%hedefe ilk frame �zerinde �er�eve �izilmesi
Movie(index_start).cdata = Draw_target(x0,y0,W,H,...
    Movie(index_start).cdata,2);
%% TRACKING
WaitBar = waitbar(0,'Tracking in progress, be patient...');
% From 1st frame to last one
%videonun sonuna kadar her frame i�in mean shift uygulan�r
for t=1:Length-1
    % Next frame
    I2 = rgb2ind(Movie(t+1).cdata,map);%s�radaki frame'i ilk framede belirledi�imiz renk haritas�ndaki indislerle ifade ediyoruz
    % Apply the Mean-Shift algorithm to move (x,y)
    % to the target location in the next frame.
    %s�radaki framede nesnenin yerini(x,y) bulmak i�in mean shift uygulan�r
    %I2 frame'inde q histogram�na en benzer �er�eveyi bulmak
    [x,y,loss,f,f_indx,w] = MeanShift_Tracking(q,I2,Lmap,...
        height,width,f_thresh,max_it,x0,y0,H,W,k,gx,...
        gy,f,f_indx,loss);
    % Check for target loss. If true, end the tracking
    if loss == 1
        break;
    else
        % Drawing the target location in the next frame
        %bir sonraki framede hedef �zerinde �er�eve �izilir
        Movie(t+1).cdata = Draw_target(x,y,W,H,Movie(t+1).cdata,2);
        % Next frame becomes current frame
        y0 = y;
        x0 = x;
        % Updating the waitbar
        waitbar(t/(Length-1));
    end
end
close(WaitBar);
%% End of TRACKING

% g�ncellenmi� videoyu g�ster
scrsz = get(0,'ScreenSize');
figure(1)
set(1,'Name','Movie Player','Position',...
    [scrsz(3)/2-width/2 scrsz(4)/2-height/2 width height],...
    'MenuBar','none');
axis off
% Image position inside the figure
set(gca,'Units','pixels','Position',[1 1 width height])
% Play the movie
movie(Movie);

%% End of File
%=============%