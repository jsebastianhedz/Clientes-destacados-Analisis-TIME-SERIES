clc
% clear all
% close all
%Este programa es para realizar el analisis de los archivos CGM mensuales
%del operador de red ElectroHuila para clientes de grandes consumos.


%% # 1. Se realiza la exportación de los datos, para que cada numero de ID a matlab
% corriente unico de la medida de un cliente se vuelva una serie de tiempo

% La tabla exportada de excel es la agrupación de los balances mensuales
% del 2022

tic
[~,sheet_name]=xlsfinfo('BalanceAgosto2022.xlsx');
for k=1:numel(sheet_name)
  CGM{k}=xlsread('BalanceAgosto2022.xlsx',sheet_name{k});
end
toc

%% 2. Se realiza la organización de los datos en una serie de tiempo según el día analizar del mes
Dia=27; % ingresar el día analizar
DiaExclucion=28; %ingresa el día que no quiere analizar mayor a la v. Dia
Horas=24;% Un día tiene 24 horas analizar, este dato es fijo
Fila=size(CGM{1,1},1);%Filas de la matriz antigua o a cambiar
Columna=size(CGM{1,1},2);%Columnas de la matriz antigua o a cambiar
MatrizCGM=CGM{1,1};
NIUs=unique(MatrizCGM(:,2));
%## Crear la nueva matriz donde se organizaran los datos, por lo tanto las
%columnas van hacer la serie de tiempo y las filas las cuentas usrs, es
%decir días*24 igual al numero de columnas y tamaño de NIUs  es el nuevo
%tamaño de filas.
% MPRIMEREADjunioActiva=zeros(size(NIUs,1),Dia*Horas);
% MPRIMEREADjunioReactiva=zeros(size(NIUs,1),Dia*Horas);
ContadorMPRIMEREADjunioActiva=1;
ContadorMPRIMEREADjunioReactiva=1;
ContadorExluido=1;
DiasA=[1:1:Dia]';%Vector de las filas analizar
for i=1:1:size(NIUs,1) %Este for busca las filas de las cuentas en la 
    % matriz de CGM(antigua o a cambiar) y las reorganiza en la matriz
    %MPRIMEREADjunioactiva/reactiva. En en la variable CuentasExclui 
    %muestra las cuentas con el contenido incompleto.
    [Filacgm,Colcgm]=find(MatrizCGM(:,2)==NIUs(i,1));
    MatIntermedio=MatrizCGM(Filacgm,1:50);
    %El numero 26 es la columa 24 h en activa, el numero 50 24h reactiva
    if size(MatIntermedio,1)>=DiaExclucion
        MatIntermedio=MatIntermedio(1:DiaExclucion,:);
    elseif size(MatIntermedio,1)<Dia
        CuentasExlui(ContadorExluido,:)=[NIUs(i,1) size(MatIntermedio,1)];
        ContadorExluido=ContadorExluido+1;
        continue;
    elseif size(MatIntermedio,1)==Dia || MatIntermedio(end,1)==Dia
        Mattransladar=MatIntermedio(1:end,:);
        continue;
    elseif size(MatIntermedio,1)==Dia || MatIntermedio(end,1)~=Dia
        CuentasExlui(ContadorExluido,:)=[NIUs(i,1) size(MatIntermedio,1)];
        ContadorExluido=ContadorExluido+1;        
        continue;        
    end
    if MatIntermedio(end,1)==DiaExclucion
        Mattransladar=MatIntermedio(1:end-1,:);
    end
    MatrassActiva=Mattransladar(:,3:26);
    MatrassReactiva=Mattransladar(:,27:50);
    MatrassActivaVector=reshape(MatrassActiva.',1,[]);
    MatrassReactivaVector=reshape(MatrassReactiva.',1,[]);
    MPRIMEREADjunioActiva(ContadorMPRIMEREADjunioActiva,:)=[NIUs(i) MatrassActivaVector];
    ContadorMPRIMEREADjunioActiva=ContadorMPRIMEREADjunioActiva+1;
     MPRIMEREADjunioReactiva(ContadorMPRIMEREADjunioReactiva,:)=[NIUs(i) MatrassReactivaVector];
    ContadorMPRIMEREADjunioReactiva=ContadorMPRIMEREADjunioReactiva+1;
end
%% 3. En este paso se aplica control estadistico En la matriz MPRIMEREAD
%Caracteristica promedio
TST=(1:1:size(MPRIMEREADjunioActiva(1,2:1:end),2));%Serie de tiempo
Meanz=zeros(size(MPRIMEREADjunioActiva,1),1); %Promedio
MaxM=zeros(size(MPRIMEREADjunioActiva,1),1); %Maximo
MinM=zeros(size(MPRIMEREADjunioActiva,1),1); %Minimo
Dvst=zeros(size(MPRIMEREADjunioActiva,1),1); %Desviacion estandar
coefP=zeros(size(MPRIMEREADjunioActiva,1),1); %Coeficiente Pearson
b=zeros(size(MPRIMEREADjunioActiva,1),1); %Pendiente
%Reglas de control de graficos atraves de rangos
ReglaUNO=zeros(size(MPRIMEREADjunioActiva,1),1);%1.Regla:Desviación estandar de con-
% -consumo negativa superior al 50% 
MRj=zeros(size(MPRIMEREADjunioActiva,1),size(MPRIMEREADjunioActiva,2)-1);
MR=zeros(size(MPRIMEREADjunioActiva,1),1);
UCL=zeros(size(MPRIMEREADjunioActiva,1),1);
LCL=zeros(size(MPRIMEREADjunioActiva,1),1);
ReglaDOS=zeros(size(MPRIMEREADjunioActiva,1),1); %Dos de tres puntos +-2dvst
ReglaTRES=zeros(size(MPRIMEREADjunioActiva,1),1); %4 de 5 puntos +-1dvst
ReglaCUATRO=zeros(size(MPRIMEREADjunioActiva,1),1); %8 pts consecutivos <mean
ReglaCINCO=zeros(size(MPRIMEREADjunioActiva,1),1); %8 pts consecutivos fuera del
% area 1Dvst
ReglaSEIS=zeros(size(MPRIMEREADjunioActiva,1),1); %15 pts consecutivo area +-1dvst
ReglaSIETE=zeros(size(MPRIMEREADjunioActiva,1),1); %14 pts intercalandose
ReglaOCHO=zeros(size(MPRIMEREADjunioActiva,1),1); %6 pts seguidos desminuyendo o aumentan
ContadorNIUzeros=1;
Matrizdifusa=zeros(size(MPRIMEREADjunioActiva,1),size(MPRIMEREADjunioActiva,2)-1);%almacenar difusa reactiva
for i=1:1:size(MPRIMEREADjunioActiva,1)
    if sum(MPRIMEREADjunioActiva(i,2:end))==0 || sum(MPRIMEREADjunioActiva(i,2:end))<=100
        CuentasZeros(ContadorNIUzeros,:)=[MPRIMEREADjunioActiva(i,1) sum(MPRIMEREADjunioActiva(i,2:end)) sum(MPRIMEREADjunioReactiva(i,2:end))];
        ContadorNIUzeros=ContadorNIUzeros+1;
    continue;
    else
    Meanz(i) = mean(nonzeros(MPRIMEREADjunioActiva(i,2:1:end)));%Caracteristica mean
    MaxM(i) = max(MPRIMEREADjunioActiva(i,2:1:end));%Caracteristica max 
    MinM(i) = min(nonzeros(MPRIMEREADjunioActiva(i,2:1:end)));%Caracteristica min
    Dvst(i) = std(nonzeros(MPRIMEREADjunioActiva(i,2:1:end)));%Caracteristica Dst
    numP=sum((MPRIMEREADjunioActiva(i,2:1:end)-Meanz(i)).*(TST-mean(TST)));
    denP=sqrt(sum((MPRIMEREADjunioActiva(i,2:1:end)-Meanz(i)).^2)*sum((TST-...
        mean(TST)).^2));
    coefP(i,1)=numP/denP;%Caracteristica de Pearson-relación de consumo
    % respecto al tiempo
    denPB=sqrt(sum((MPRIMEREADjunioActiva(i,2:1:end)-Meanz(i)).^2));
    b(i,1)=numP/denPB;%Caracteristica de pendiente
    %Reglas de control de graficos atraves de rangos
    R1=MPRIMEREADjunioActiva(i,2:1:end);
    MRdata=MPRIMEREADjunioActiva(i,2:1:end);
    R1(R1<(Meanz(i)-3*Dvst(i)) | R1>(Meanz(i)+3*Dvst(i)))=1;
    ReglaUNO(i)=sum(R1==1); %Regla1.
    for j=1:1:size(R1,2)-1
        MRj(i,j)=abs(MRdata(1,j+1)-MRdata(1,j));
    end
    MR(i)=sum(MRj(i,:))/(size(R1,2)-1);
    UCL(i)=Meanz(i)+2.66*MR(i);
    LCL(i)=Meanz(i)-2.66*MR(i);
    %Regla dos
    R2R1=MPRIMEREADjunioActiva(i,2:1:end);
    R2R1(R2R1>(Meanz(i)+2*Dvst(i)))=1;
    R2R2=MPRIMEREADjunioActiva(i,2:1:end);
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
    R3R1=MPRIMEREADjunioActiva(i,2:1:end);
    R3R1(R3R1>(Meanz(i)+1*Dvst(i)))=1;
    R3R2=MPRIMEREADjunioActiva(i,2:1:end);
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
    R4R1=MPRIMEREADjunioActiva(i,2:1:end);
    R4R1(R4R1<Meanz(i))=1;
    R4R2=MPRIMEREADjunioActiva(i,2:1:end);
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
    R5=MPRIMEREADjunioActiva(i,2:1:end);
    R5(Meanz(i)+1*Dvst(i)>R5 & R5<Meanz(i)-1*Dvst(i))=1;
    for j=8:1:size(R1,2)
        A=[R5(1,j-7) R5(1,j-6) R5(1,j-5) R5(1,j-4) R5(1,j-3)...
            R5(1,j-2) R5(1,j-1) R5(1,j)];
        if A(1,1)==1 && A(1,2)==1 && A(1,3)==1 && A(1,4)==1 && A(1,5)==1 && A(1,6)==1 && A(1,7)==1 && A(1,8)==1
            ReglaCINCO(i)=ReglaCINCO(i)+1;%Regla5.
        end
    end
    %Regla 6
    R6=MPRIMEREADjunioActiva(i,2:1:end);
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
    R7=MPRIMEREADjunioActiva(i,2:1:end);
    for j=14:1:size(R1,2)
        A=[R6(1,j-13) R6(1,j-12) R6(1,j-11) R6(1,j-10)...
            R6(1,j-9) R6(1,j-8) R6(1,j-7) R6(1,j-6) R6(1,j-5)...
            R6(1,j-4) R6(1,j-3) R6(1,j-2) R6(1,j-1) R6(1,j)];
        if A(1,1)>A(1,2) && A(1,3)>A(1,4) && A(1,5)>A(1,6) && A(1,7)>A(1,8) && A(1,9)>A(1,10) && A(1,11)>A(1,12) && A(1,13)>A(1,14) 
            ReglaSIETE(i)=ReglaSIETE(i)+1;%Regla7.
        end
    end  
    %Regla 8
    R8=MPRIMEREADjunioActiva(i,2:1:end);
    for j=8:1:size(R1,2)
        A=[R6(1,j-7) R6(1,j-6) R6(1,j-5) R6(1,j-4)...
            R6(1,j-3) R6(1,j-2) R6(1,j-1) R6(1,j)];
        if (A(1,1)>A(1,2) && A(1,2)>A(1,3) && A(1,3)>A(1,4) && A(1,4)>A(1,5) && A(1,5)>A(1,6) )||(A(1,1)<A(1,2) && A(1,2)<A(1,3) && A(1,3)<A(1,4) && A(1,4)<A(1,5) && A(1,5)<A(1,6) ) 
            ReglaOCHO(i)=ReglaOCHO(i)+1;%Regla8.
        end
    end 
    end
end
DifusaA=MPRIMEREADjunioActiva(:,2:1:end);%Regla difusa reactiva
DifusaR=MPRIMEREADjunioReactiva(:,2:1:end);%Regla difusa reactiva    
Matrizdifusa=(DifusaA<DifusaR);
ReglaDifusa=sum(Matrizdifusa,2);
Analisis=[MPRIMEREADjunioActiva Meanz Dvst ReglaUNO ReglaDOS ReglaTRES ReglaCUATRO ...
    ReglaCINCO ReglaSEIS ReglaSIETE ReglaOCHO ReglaDifusa b coefP UCL LCL];%Falta mejorar la organización
filename = '2022AgostoBALANCECGMResultados.xlsx';
writematrix(Analisis,filename,'Sheet',1)
writematrix(CuentasExlui,filename,'Sheet',2)
writematrix(CuentasZeros,filename,'Sheet',3)

figure(1)
plot(normalize((MPRIMEREADjunioActiva(:,2:end)'),1,'range'))
plot(MPRIMEREADjunioActiva(:,2:end)','Color',[0.7, 0.75, 0.71],'LineStyle','--','LineWidth',1)
plot(MPRIMEREADjunioActiva(:,2:end)','Color',[0.06, 0.06, 0.06],'LineStyle','--','LineWidth',1)
ylabel('Consumo hora-hora kWh')
xlabel('24 horas-mes agosto 2022')
xticks([])
xticklabels({})
yticks([])

FilaCXXX=([2,8,34,35,44,45,518,520,521,547,558,584,587,594,619,632,633,634,640,652,656,656,661,663,673,675,691,711,714,718,728,733,754,757,809,874,2,8,34,35,44,45,518,520,521,547,584,587,619,632,633,634,640,652,661,663,673,691,711,714,718,728,733,754,809,874,913,921,995,1004,1014,1023,1026,1031,1042,1054,1057,1062,1110,1119,1131,1143,1152,1166,1167,1179
])';
Filactac=([2,663,673,691,2,663,673,691,913,1110,1167,1179
])';
for i=1:1:size(Filactac,1)
    figure(1)
    plot(MPRIMEREADjunioActiva(FilaCXXX(i),2:end)','LineStyle','--','LineWidth',1)
    ylabel('Consumo hora-hora kWh')
    xlabel('24 horas-mes agosto 2022')
    xticks([])
    xticklabels({})
    hold on
end