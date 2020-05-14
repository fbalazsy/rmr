clear;
close all;
clc;

%INPUT
%Startovacie pozicie
%2 5 8 11 14 17 20 23 26 29 32 35 38 41 44 47 50 53 56 59 62 65 68 71 74 77
%80 83 86 89 92 95 98 101 104 107 11 113 116
start=53;
%Cielova pozicia Xcm, Ycm
ciel=[150 -325]; 
%Roztec kolies
razvor=0.23; 
%Polomer robota
polomerRobota=35;
%Mierka enkodera
mierka_enkoder = 0.000085292090497737556558;
%Buffer enkodera
maxBuffer = 65535;
halfEnkoder = 35000;
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
%Inicializacia premennych
x = zeros(8025,1);
y = zeros(8025,1);
uholEnkoder = zeros(8025,1);
natocenie = zeros(8025,1);
tmp=0;

%Vypocet polohy pre vsetky pohlady lidaru
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
     
end

Xcm=x*100;
Ycm=y*100;
inkrementLid = zeros(309,1);
xLidar = zeros(309,1);
yLidar = zeros(309,1);
%Mam polohu zobrazim co ma prave lidar po
position=round(mean(find(abs(cas-round(lidarData.data(start-1,1),-2))<=10^-10)));   

for col=1:1:lidarData.data(start-1,2)
    tmp=tmp-360/lidarData.data(start-1,2);
    inkrementLid(col)=tmp;
    xLidar(col)= cos((uholGyro(position))+deg2rad(inkrementLid(col)))*(lidarData.data(start,col)/10) + Xcm(position);
    yLidar(col)= sin((uholGyro(position))+deg2rad(inkrementLid(col)))*(lidarData.data(start,col)/10) + Ycm(position);
end

figure(1)
hold on
grid on
plot(xLidar,yLidar,'k.', 'MarkerSize', 10)

uholNatoceniaPrekaz=deg2rad(atan2d((ciel(2))-Ycm(position), (ciel(1)-Xcm(position))));
%Hlavne sluzi ako offset pre lidar body
uholNatoceniaCiel=rad2deg(uholNatoceniaPrekaz-uholEnkoder(position)) 

%Uhol potrebujem v pluse
if(uholNatoceniaCiel>0) 
   uholNatoceniaCiel=360-(uholNatoceniaCiel);
end
%Robot od ciela
vzdialenost=sqrt((ciel(1)-Xcm(position))^2+(ciel(2)-Ycm(position))^2);

%Najdem prekazku presne podla prezentacie
alfaI=abs(uholNatoceniaCiel)-abs(inkrementLid(1));
prekazka = false;
%Nachystam si alfaI pre vsetky lidar body
for col=1:1:lidarData.data(start-1,2)
  alfaI=alfaI-abs(inkrementLid(1));
  alfaIarray(col)=alfaI;
end

for col=1:1:lidarData.data(start-1,2)
    %Odfiltrujem lidar body co su dalej ako prekazka a tie co su mimo cestu
    if(vzdialenost>lidarData.data(start,col)/10 && lidarData.data(start,col)/10>0)
        alfaI=abs(alfaIarray(col));
        kritD=(polomerRobota/sind(alfaI));
        if(alfaI<90 && kritD >0 && kritD>lidarData.data(start,col)/10)
            xPrekazka(col)= cos((uholGyro(position))+deg2rad(inkrementLid(col)))*(lidarData.data(start,col)/10) + Xcm(position);
            yPrekazka(col)= sin((uholGyro(position))+deg2rad(inkrementLid(col)))*(lidarData.data(start,col)/10) + Ycm(position);
            prekazka = true;
        end
    end
end

%Vyfarbi ciel
plot(ciel(1), ciel(2), 'g*', 'MarkerSize', 25); 
%Ukaz robota
plot(Xcm(position), Ycm(position), 'bo', 'MarkerSize', polomerRobota); 

%Ked tam je nejaka prekazka
if(prekazka)
%Vykresli prekazku
plot(xPrekazka,yPrekazka,'r.', 'MarkerSize', 10);

%Vypocet optimalnej cesty
%Ignoruj prve nuly
prvy = find(xPrekazka~=0, 1);

%Vzdialenost robota ku koncovym bodom prekazky
robotDoP1=(sqrt((xPrekazka(prvy)-Xcm(position))^2+(yPrekazka(prvy)-Ycm(position))^2));
robotDoP2=(sqrt((xPrekazka(end)-Xcm(position))^2+(yPrekazka(end)-Ycm(position))^2));
%Dlzky hran celeho cost lichobeznika vid prezentacia
hrana1=robotDoP1 + (sqrt((ciel(1)-xPrekazka(prvy))^2+(ciel(2)-yPrekazka(prvy))^2)) 
hrana2=robotDoP2 + (sqrt((ciel(1)-xPrekazka(end))^2+(ciel(2)-yPrekazka(end))^2))
%Vypocitame natocenie od prekazky pre vyhodnejsiu cestu
if(hrana1<hrana2)
    %Zahrn polomer robota
    priratajRobota=asind(polomerRobota/robotDoP1);
    natocenie=priratajRobota + atan2d((yPrekazka(prvy))-Ycm(position), (xPrekazka(prvy)-Xcm(position)));
else
    priratajRobota=asind(polomerRobota/robotDoP2);
    natocenie=atan2d((yPrekazka(end))-Ycm(position), (xPrekazka(end)-Xcm(position))) - priratajRobota;
end
%Nakresli natocenie
quiver(Xcm(position), Ycm(position),cosd(natocenie),sind(natocenie),'b','AutoScaleFactor',200)
else
%Nakresli natocenie
plot([Xcm(position), ciel(1)],[Ycm(position),ciel(2)],'b')
end



