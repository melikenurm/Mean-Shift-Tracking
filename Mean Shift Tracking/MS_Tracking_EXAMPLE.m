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
% mean shift convergence benzerlik eþiði, bu deðerin altýndaysa hedef bulundu
f_thresh = 0.16;%f_thresh = 0.16;
% mean shift conv. itr. sayýsý, her framede en fazla bu itr. kadar ort. hesaplanacak
max_it = 15;%pembe için 15, yeþil 30, mavi 5
% seçilen bölge kadar boyutlu kernel penceresi(her noktanýn aðýrlýðýný belirleyecek)
kernel_type = 'Epanechnikov';%kernel_type = 'Epanechnikov';
radius = 2;%radius = 2;

%% Target Selection in Reference Frame
%ilk framede takip edilecek objeyi seçme
%seçilen bölge(T), sol üst köþesi(x0,y0), yüksekliði(H) ve geniþliði(W)
[T,x0,y0,H,W] = Select_patch(Movie(index_start).cdata,0);
pause(0.2);

%% Run the Mean-Shift algorithm
% Calculation of the Parzen Kernel window
%seçilen büyüklükte parzen window, gauss daðýlýmýndan aðýrlýklar
%seçilen alanýn merkezindeki piksellerin aðýrlýðý daha yüksek olsun objeyi
%temsil etme gücü yüksek olan birimler
%aðýrlýk penceresi(k), x yönündeki gradyeni(gx), y yönündeki gradyeni(gy)
[k,gx,gy] = Parzen_window(H,W,radius,kernel_type,0);
% Conversion from RGB to Indexed colours
% to compute the colour probability functions (PDFs)
%her renk tonuna bir index atanarak görüntüler index numaralarý þeklinde
%ifade ediliyor
[I,map] = rgb2ind(Movie(index_start).cdata,65536);
Lmap = length(map)+1;%kaç farklý ton var
T = rgb2ind(T,map);%seçilen bölge de ilk görüntüde belirlenen indexler þeklinde ifade ediliyor
% Estimation of the target PDF
% seçilen bölgedeki her bir renk tonunun konumsal aðýrlýðýna baðlý olarak
% histogramýn(q) hesaplanmasý
q = Density_estim(T,Lmap,k,H,W,0);
% Flag for target loss
loss = 0;%hedefi kaybetti mi?
% Similarity evolution along tracking
f = zeros(1,(Length-1)*max_it);%her framede max_it sayýsý kadar hesaplanan benzerlik deðerleri
% Sum of iterations along tracking and index of f
f_indx = 1;%kaçýncý benzerlik yazýlacak? 
% Draw the selected target in the first frame
%hedefe ilk frame üzerinde çerçeve çizilmesi
Movie(index_start).cdata = Draw_target(x0,y0,W,H,...
    Movie(index_start).cdata,2);
%% TRACKING
WaitBar = waitbar(0,'Tracking in progress, be patient...');
% From 1st frame to last one
%videonun sonuna kadar her frame için mean shift uygulanýr
for t=1:Length-1
    % Next frame
    I2 = rgb2ind(Movie(t+1).cdata,map);%sýradaki frame'i ilk framede belirlediðimiz renk haritasýndaki indislerle ifade ediyoruz
    % Apply the Mean-Shift algorithm to move (x,y)
    % to the target location in the next frame.
    %sýradaki framede nesnenin yerini(x,y) bulmak için mean shift uygulanýr
    %I2 frame'inde q histogramýna en benzer çerçeveyi bulmak
    [x,y,loss,f,f_indx,w] = MeanShift_Tracking(q,I2,Lmap,...
        height,width,f_thresh,max_it,x0,y0,H,W,k,gx,...
        gy,f,f_indx,loss);
    % Check for target loss. If true, end the tracking
    if loss == 1
        break;
    else
        % Drawing the target location in the next frame
        %bir sonraki framede hedef üzerinde çerçeve çizilir
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

% güncellenmiþ videoyu göster
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