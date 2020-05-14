clear;
close all;
clc;
%Nacitaj data z lidaru predpripravene z lidardata.txt
load('lidarData.mat');
%Posuvy kolies a natocenie robota je tu:
%Nacitaj data robota
robotData = importdata('robotdata.txt',' ',1);
cas=round(robotData.data(:,1),-2);

%Nacitam enkodre a uhol natocenia robota
lavyEnkoder=(robotData.data(:,2)); 
pravyEnkoder=(robotData.data(:,3)); 
uhol=(robotData.data(:,4))/100; 
uholGyro=deg2rad(uhol + 170.04);

%Roztec kolies
razvor=0.23; 
%Mierka enkodera
mierka_enkoder = 0.000085292090497737556558;
%Buffer enkodera
maxBuffer = 65535;
halfEnkoder = 35000;
%Inicializacia premennych
x = zeros(8025,1);
y = zeros(8025,1);
uholEnkoder = zeros(8025,1);
natocenie = zeros(8025,1);
uhToX = zeros(8025, 1);
uhToY = zeros(8025, 1);

%Pocitam cestu z podvozku vid prezentacia
for col=1:1:8024
    posun_vpravo=pravyEnkoder(col+1)-pravyEnkoder(col);
    posun_vlavo=lavyEnkoder(col+1)-lavyEnkoder(col);
    
    if(posun_vpravo>halfEnkoder)
        posun_vpravo=pravyEnkoder(col+1)-maxBuffer-pravyEnkoder(col);
    elseif(-posun_vpravo>halfEnkoder)
        posun_vpravo=pravyEnkoder(col+1)+maxBuffer-pravyEnkoder(col);
    end
    
    if(posun_vlavo>halfEnkoder)
        posun_vlavo=lavyEnkoder(col+1)-maxBuffer-lavyEnkoder(col);
    elseif(-posun_vlavo>halfEnkoder)
        posun_vlavo=lavyEnkoder(col+1)+maxBuffer-lavyEnkoder(col);
    end
    
    lavyEnkoder(col)=mierka_enkoder*(posun_vlavo);
    pravyEnkoder(col)=mierka_enkoder*(posun_vpravo);
    natocenie(col)=(pravyEnkoder(col)-lavyEnkoder(col))/razvor; 
    uholEnkoder(col+1)= uholEnkoder(col)+natocenie(col);
    
    if (abs(natocenie(col))<=0)
        x(col+1)= x(col)+((lavyEnkoder(col)+pravyEnkoder(col))/2)*cos(uholEnkoder(col));
        y(col+1)= y(col)+((lavyEnkoder(col)+pravyEnkoder(col))/2)*sin(uholEnkoder(col));
    else
        x(col+1)= x(col)+((razvor*(pravyEnkoder(col)+lavyEnkoder(col)))/(2*(pravyEnkoder(col)-lavyEnkoder(col))))*(sin(uholEnkoder(col+1))-sin(uholEnkoder(col))); 
        y(col+1)= y(col)-((razvor*(pravyEnkoder(col)+lavyEnkoder(col)))/(2*(pravyEnkoder(col)-lavyEnkoder(col))))*(cos(uholEnkoder(col+1))-cos(uholEnkoder(col))); 
    end
    
    uhToX(col+1)=cos(uholEnkoder(col)); 
    uhToY(col+1)=sin(uholEnkoder(col)); 

end

Xcm=x*100;
Ycm=y*100;
row=2;
inkrement = zeros(309,1);
xLidar = zeros(309,1);
yLidar = zeros(309,1);

figure(1)
grid on
hold on
%Pocitam a zobrazim lidar
for j=1:1:39
    position=round(mean(find(abs(cas-round(lidarData.data(row-1,1),-2))<=10^-10)));    
    for col=1:1:lidarData.data(row-1,2)
        
        %V prvej chodbe je to divne tak je tu filter
        if(lidarData.data(row,col) > 2000) 
        lidarData.data(row,col)=0; 
        end
        
        inkrement(col)=-lidarData.data(row+1,col);
        %Uhly natocenia robota chytam z gyra namiesto podvozku
        xLidar(col)= cos((uholGyro(position))+deg2rad(inkrement(col)))*(lidarData.data(row,col)/10) + Xcm(position);
        yLidar(col)= sin((uholGyro(position))+deg2rad(inkrement(col)))*(lidarData.data(row,col)/10) + Ycm(position);
    end
    row=row+3;
    plot(xLidar,yLidar,'k.')
end
%Zobrazim cestu
plot(Xcm,Ycm)


