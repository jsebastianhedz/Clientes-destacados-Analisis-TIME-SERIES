clc
clear all
close all
% save CGM2021

%Este porograma es para realizar el analisis de los archivos CGM anuales
%del operador de red ElectroHuila para clientes de grandes consumos.
%% # 1. Se realiza la organización de los datos, para que cada numero de ID
% corriente unico de la medida de un cliente se vuelva una serie de tiempo
%Procedimiento de analisis experto por Juan Sebastian
%-Primero descargar la matrix de consumos por top ciclos ('80', '81', '82'
% , '60', '39', '5', '12', '19', '109', '6', '124')
% La tabla exportada de excel es la agrupación de los balances mensuales
% del 2021
tic
[~,sheet_name]=xlsfinfo('RURALJULIO.xlsx');
for k=1:numel(sheet_name)
  data{k}=xlsread('RURALJULIO.xlsx',sheet_name{k});
end
toc
DataJunioFMUNO=[data{1,1}];
DataJunioFMUNO=[DataJunioFMUNO zeros(size(data{1,1},1),1)];
%  save data 
% load("data.mat");
DataJunio=data{1,1};
TST=(1:1:size(DataJunio(1,2:1:end),2));
%Caracteristica promedio
Meanz=zeros(size(data{1,1},1),1);
MaxM=zeros(size(data{1,1},1),1);
MinM=zeros(size(data{1,1},1),1);
Dvst=zeros(size(data{1,1},1),1);
coefP=zeros(size(data{1,1},1),1);
b=zeros(size(data{1,1},1),1);
%Reglas de control de graficos atraves de rangos
ReglaUNO=zeros(size(data{1,1},1),1);%1.Regla:Desviación estandar de con-
% -consumo negativa superior al 50% 
MRj=zeros(size(data{1,1},1),size(data{1,1},2)-3);
MR=zeros(size(data{1,1},1),1);
UCL=zeros(size(data{1,1},1),1);
LCL=zeros(size(data{1,1},1),1);
ReglaDOS=zeros(size(data{1,1},1),1); %Dos de tres puntos +-2dvst
ReglaTRES=zeros(size(data{1,1},1),1); %4 de 5 puntos +-1dvst
ReglaCUATRO=zeros(size(data{1,1},1),1); %8 pts consecutivos <mean
ReglaCINCO=zeros(size(data{1,1},1),1); %8 pts consecutivos fuera del
% area 1Dvst
ReglaSEIS=zeros(size(data{1,1},1),1); %15 pts consecutivo area +-1dvst
ReglaSIETE=zeros(size(data{1,1},1),1); %14 pts intercalandose
ReglaOCHO=zeros(size(data{1,1},1),1); %6 pts seguidos desminuyendo o aumentan
for i=1:1:size(data{1,1},1)
    Meanz(i) = mean(nonzeros(DataJunio(i,2:1:end)));%Caracteristica mean
    MaxM(i) = max(DataJunio(i,2:1:end));%Caracteristica max 
    MinM(i) = min(nonzeros(DataJunio(i,2:1:end)));%Caracteristica min
    Dvst(i) = std(nonzeros(DataJunio(i,2:1:end)));%Caracteristica Dst
    numP=sum((DataJunio(i,2:1:end)-Meanz(i)).*(TST-mean(TST)));
    denP=sqrt(sum((DataJunio(i,2:1:end)-Meanz(i)).^2)*sum((TST-...
        mean(TST)).^2));
    coefP(i,1)=numP/denP;%Caracteristica de Pearson-relación de consumo
    % respecto al tiempo
    denPB=sqrt(sum((DataJunio(i,2:1:end)-Meanz(i)).^2));
    b(i,1)=numP/denPB;%Caracteristica de pendiente
    %Reglas de control de graficos atraves de rangos
    R1=DataJunio(i,2:1:end);
    MRdata=DataJunio(i,2:1:end);
    R1(R1<(Meanz(i)-3*Dvst(i)) | R1>(Meanz(i)+3*Dvst(i)))=1;
    ReglaUNO(i)=sum(R1==1); %Regla1.
    for j=1:1:size(R1,2)-1
        MRj(i,j)=abs(MRdata(1,j+1)-MRdata(1,j));
    end
    MR(i)=sum(MRj(i,:))/(size(R1,2)-1);
    UCL(i)=Meanz(i)+2.66*MR(i);
    LCL(i)=Meanz(i)-2.66*MR(i);
    %Regla dos
    R2R1=DataJunio(i,2:1:end);
    R2R1(R2R1>(Meanz(i)+2*Dvst(i)))=1;
    R2R2=DataJunio(i,2:1:end);
    R2R2(R2R2<(Meanz(i)-2*Dvst(i)))=1;
    for j=3:1:size(R1,2)
        A=[R2R1(1,j-2) R2R1(1,j-1) R2R1(1,j)];
        B=[R2R2(1,j-2) R2R2(1,j-1) R2R2(1,j)];
        if (A(1,1)==1 && A(1,2)==1) || (B(1,1)==1 && B(1,2)==1)
            ReglaDOS(i)=ReglaDOS(i)+1;%Regla2.
        elseif (A(1,2)==1 && A(1,3)==1) || (B(1,2)==1 && B(1,3)==1)
            ReglaDOS(i)=ReglaDOS(i)+1;%Regla2.
        elseif (A(1,1)==1 && A(1,3)==1) || (B(1,1)==1 && B(1,3)==1)
            ReglaDOS(i)=ReglaDOS(i)+1;%Regla2.
        end
    end
    %Regla tres
    R3R1=DataJunio(i,2:1:end);
    R3R1(R3R1>(Meanz(i)+1*Dvst(i)))=1;
    R3R2=DataJunio(i,2:1:end);
    R3R2(R3R2<(Meanz(i)-1*Dvst(i)))=1;
    for j=5:1:size(R1,2)
        A=[R3R1(1,j-4) R3R1(1,j-3) R3R1(1,j-2) R3R1(1,j-1) R3R1(1,j)];
        B=[R3R2(1,j-4) R3R2(1,j-3) R3R2(1,j-2) R3R2(1,j-1) R3R2(1,j)];
        if (A(1,1)==1 && A(1,2)==1 && A(1,3)==1 && A(1,4)==1)||(B(1,1)==1 && B(1,2)==1 && B(1,3)==1 && B(1,4)==1)
            ReglaTRES(i)=ReglaTRES(i)+1;%Regla3.
        elseif (A(1,2)==1 && A(1,3)==1 && A(1,4)==1 && A(1,5)==1)||(B(1,2)==1 && B(1,3)==1 && B(1,4)==1 && B(1,5)==1)
            ReglaTRES(i)=ReglaTRES(i)+1;%Regla3.
        end
    end
    %Regla cuatro
    R4R1=DataJunio(i,2:1:end);
    R4R1(R4R1<Meanz(i))=1;
    R4R2=DataJunio(i,2:1:end);
    R4R2(R4R2>Meanz(i))=1;
    for j=8:1:size(R1,2)
        A=[R4R1(1,j-7) R4R1(1,j-6) R4R1(1,j-5) R4R1(1,j-4) R4R1(1,j-3)...
            R4R1(1,j-2) R4R1(1,j-1) R4R1(1,j)];
        B=[R4R2(1,j-7) R4R2(1,j-6) R4R2(1,j-5) R4R2(1,j-4) R4R2(1,j-3)...
            R4R2(1,j-2) R4R2(1,j-1) R4R2(1,j)];
        if (A(1,1)==1 && A(1,2)==1 && A(1,3)==1 && A(1,4)==1 && A(1,5)==1 && A(1,6)==1 && A(1,7)==1 && A(1,8)==1)||(B(1,1)==1 && B(1,2)==1 && B(1,3)==1 && B(1,4)==1 && B(1,5)==1 && B(1,6)==1 && B(1,7)==1 && B(1,8)==1)
            ReglaCUATRO(i)=ReglaCUATRO(i)+1;%Regla4.
        end
    end    
    %Regla cinco
    R5=DataJunio(i,2:1:end);
    R5(Meanz(i)+1*Dvst(i)>R5 & R5<Meanz(i)-1*Dvst(i))=1;
    for j=8:1:size(R1,2)
        A=[R5(1,j-7) R5(1,j-6) R5(1,j-5) R5(1,j-4) R5(1,j-3)...
            R5(1,j-2) R5(1,j-1) R5(1,j)];
        if A(1,1)==1 && A(1,2)==1 && A(1,3)==1 && A(1,4)==1 && A(1,5)==1 && A(1,6)==1 && A(1,7)==1 && A(1,8)==1
            ReglaCINCO(i)=ReglaCINCO(i)+1;%Regla5.
        end
    end
    %Regla 6
    R6=DataJunio(i,2:1:end);
    R6(and(R6<(Meanz(i)+1*Dvst(i)),R6>Meanz(i)-1*Dvst(i)))=1;
    for j=15:1:size(R1,2)
        A=[R6(1,j-14) R6(1,j-13) R6(1,j-12) R6(1,j-11) R6(1,j-10)...
            R6(1,j-9) R6(1,j-8) R6(1,j-7) R6(1,j-6) R6(1,j-5)...
            R6(1,j-4) R6(1,j-3) R6(1,j-2) R6(1,j-1) R6(1,j)];
        if A(1,1)==1 && A(1,2)==1 && A(1,3)==1 && A(1,4)==1 && A(1,5)==1 && A(1,6)==1 && A(1,7)==1 && A(1,8)==1 && A(1,9)==1 && A(1,10)==1 && A(1,11)==1 && A(1,12)==1 && A(1,13)==1 && A(1,14)==1 && A(1,15)==1
            ReglaSEIS(i)=ReglaSEIS(i)+1;%Regla6.
        end
    end  
    %Regla 7
    R7=DataJunio(i,2:1:end-1);
    for j=14:1:size(R1,2)
        A=[R6(1,j-13) R6(1,j-12) R6(1,j-11) R6(1,j-10)...
            R6(1,j-9) R6(1,j-8) R6(1,j-7) R6(1,j-6) R6(1,j-5)...
            R6(1,j-4) R6(1,j-3) R6(1,j-2) R6(1,j-1) R6(1,j)];
        if A(1,1)>A(1,2) && A(1,3)>A(1,4) && A(1,5)>A(1,6) && A(1,7)>A(1,8) && A(1,9)>A(1,10) && A(1,11)>A(1,12) && A(1,13)>A(1,14) 
            ReglaSIETE(i)=ReglaSIETE(i)+1;%Regla7.
        end
    end  
    %Regla 8
    R8=DataJunio(i,2:1:end-1);
    for j=8:1:size(R1,2)
        A=[R6(1,j-7) R6(1,j-6) R6(1,j-5) R6(1,j-4)...
            R6(1,j-3) R6(1,j-2) R6(1,j-1) R6(1,j)];
        if (A(1,1)>A(1,2) && A(1,2)>A(1,3) && A(1,3)>A(1,4) && A(1,4)>A(1,5) && A(1,5)>A(1,6) )||(A(1,1)<A(1,2) && A(1,2)<A(1,3) && A(1,3)<A(1,4) && A(1,4)<A(1,5) && A(1,5)<A(1,6) ) 
            ReglaOCHO(i)=ReglaOCHO(i)+1;%Regla8.
        end
    end  
end
Analisis=[DataJunio Meanz Dvst ReglaUNO ReglaDOS ReglaTRES ReglaCUATRO ...
    ReglaCINCO ReglaSEIS ReglaSIETE ReglaOCHO b coefP UCL LCL];%Falta mejorar la organización
filename = 'ResultadoAnalisisjuliorural.xlsx';
writematrix(Analisis,filename,'Sheet',1)