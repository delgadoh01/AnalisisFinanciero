%% Gestion de portafolios de inversion
% Realizar una optimizaci?n Minima Varianza tomando en cuenta los indices de la hoja
% DatosAAPL.xlsx
% Para este caso, asuma que el periodo de inversion es 1 a?o
% As? mismo, asuma que los limites inferiores y superiores de cada
% instrumento es de 0% y 30% y que no hay apalancamiento
% y que siempre se deve invertir al menos en el 100% de los instrumentos

%% Paso 1. Limpieza de pantalla y workspace
clc;
clear;

%% Paso 2. Cerrar todas las ventanas de matlab abierta
close all;

%% Paso 3. Cargar datos
[data_MV, str]=xlsread('DatosAAPL3.xlsx');
[f,c]=size(data_MV);
Indices=str(1,2:c+1);
x=data_MV(:,:);

% Periodo a evaluar de los 5 a?os
years=5;
x=x(1:round(years*251),:);   

% Grafica de comportamiento historico
figure();
plot(x);
legend(Indices);
grid on;
title('Comportamiento historico del valor de las acciones','FontName','Times New Roman','FontSize', 12);
xlabel('Tiempo en las unidades correspondientes','FontName','Times New Roman','FontSize', 12);
ylabel('Valor de las acciones','FontName','Times New Roman','FontSize', 12);


%% Paso 4. Definir los parametros inciales
m=25; % Numero de portafolios en la forntera eficiente

%% Paso 5. Generacion de retornos
%[f,c]=size(data_MV);

% Convertir los precios a retornos anuales
Retornos=zeros(1,1);
for j=1:c;
 for i=253:f;
  Retornos(i-253+1,j)=data_MV(i,j)/data_MV(i-253+1,j)-1;
 end
end

% Grafica simultaneamente los retornos
%figure(1);
figure();
plot(Retornos);
legend(Indices);
grid on;
title('Comportamiento historico de los retornos anuales','FontName','Times New Roman','FontSize', 12);
xlabel('Tiempo en las unidades correspondientes','FontName','Times New Roman','FontSize', 12);
ylabel('Retorno anual en %','FontName','Times New Roman','FontSize', 12);

%% Paso 6. Calcular el retorno esperado y matirz de varianzas y covarianzas
n_assets=size(Retornos,2);
mu=mean(Retornos);
vc=cov(Retornos); % Matriz de covarianzas, en la diagonal esta la varianza

%% Paso 7. Creacion de la frontera eficiente
% Se crea un objeto Portafolio para un proceso de optiizacion
% El cual servira para definir los patametros de analisis
P = Portfolio;

% Los comandos set definen las propiedades
% 1. Media y varianza
P=setAssetMoments(P,mu,vc);

% 2. Limite inferior igual a cero y limite superior de 30%
lb=zeros(n_assets,1); % Lower bound
ub=0.30*ones(n_assets,1); % Upper bound
P=setBounds(P,lb,ub);

% 3. Presupuesto de inversion hasta 100%
P=setBudget(P,1,1);

% 4. Estrimar la frontera eficiente
w=estimateFrontier(P,m);

% 5. Se procede a obtener los vectores de desviaciones y retornos que componen
% los puntosde la frontera eficiente y se grafica el riesgo vs retorno
[risk, ret]=estimatePortMoments(P,w);
%figure(2);
figure();
plot(risk,ret,'r');
grid on;
title('Frontera eficiente','FontName','Times New Roman','FontSize', 12);
xlabel('Varianza (riesgo) en %','FontName','Times New Roman','FontSize', 12);
ylabel('Retorno anual en %','FontName','Times New Roman','FontSize', 12);

%% Paso 8. Determinar el portafolio riesgoso optimo

rf=0.065; %Tasa libre de riesgo
w=w';

% Con coeficiente de aversion al riesgo de 90 y de 180 para afin y averso
% respectivamente
[Opt_Riesgo_MV, Opt_Retorno_MV, Opt_Wts_MV, RiskyFraction, OverallRisk, OverallReturn]=portalloc(risk,ret,w,rf,rf,90);
[Opt_Riesgo_MV_2, Opt_Retorno_MV_2, Opt_Wts_MV_2, RiskyFraction_2, OverallRisk_2, OverallReturn_2]=portalloc(risk,ret,w,rf,rf,180);

%% Paso 9. Graficos
%figure(3);
figure();
subplot(1,2,1);
plot(risk*100,ret*100,'m-',0,rf*100,'r:s',Opt_Riesgo_MV*100,Opt_Retorno_MV*100,'b:d',OverallRisk*100,OverallReturn*100,'g:p',[0;Opt_Riesgo_MV*100],[rf*100,Opt_Retorno_MV*100]);
title('Portafolio Optimo con A=90','FontName','Times New Roman','FontSize', 12);
xlabel('Riesgo (%)','FontName','Times New Roman','FontSize', 12);
ylabel('Retorno (%)','FontName','Times New Roman','FontSize', 12);

subplot(1,2,2);
plot(risk*100,ret*100,'m-',0,rf*100,'r:s',Opt_Riesgo_MV_2*100,Opt_Retorno_MV_2*100,'b:d',OverallRisk_2*100,OverallReturn_2*100,'g:p',[0;Opt_Riesgo_MV_2*100],[rf*100,Opt_Retorno_MV_2*100]);
title('Portafolio Optimo con A=180','FontName','Times New Roman','FontSize', 12);
xlabel('Riesgo (%)','FontName','Times New Roman','FontSize', 12);
ylabel('Retorno (%)','FontName','Times New Roman','FontSize', 12);

% Busca los porcentajes distintos a cero y los guarda en Empresas
for ii=1:n_assets;
  if Opt_Wts_MV(ii)~=0;
       Empresas(ii)=1;
       PesoEmpresas(ii)=Opt_Wts_MV(ii);
  else
      Empresas(ii)=0;
      PesoEmpresas(ii)=0;
  end
end

% Descarta los porcentajes iguales a cero
Empr=find(Empresas);
PesoEmpresas(PesoEmpresas==0)=[];

% Identifica las empresas que si tendran un porcentaje de inversion
Etiquetas=(Indices(Empr));

% Grafica el pastel con los porcentajes optimos de las empresas 
%figure(4);
figure();
labels = Etiquetas;
pie(PesoEmpresas*100, labels);
title('Porcentajes para invertir en las empresas','FontName','Times New Roman','FontSize', 12);

%% Calculo del VAR
%% Paso 10. Riqueza actual del portafolio (MXN)
N=1000000;

%% Paso 11. Pesos del portafolio optimo
w2=Opt_Wts_MV;

%% Paso 12. Calculo de retorno diario
data= data_MV(:,1:c);
R=diff(data)./data(1:end-1,:);

%% Paso 13. Calculo de matriz de varianzas y covarianzas
SIGMAdt=cov(R);

%% Paso 14. Varianza del portafolio o Riesgo del portafolio
Activos=zeros(1,c);
%spdt=portstats([0 0 0 0 0 0 0 0], SIGMAdt, w2);
spdt=portstats(Activos, SIGMAdt, w2);

%% Paso 15. Nivel de confianza 99%
alfa=1-0.99;

%% Paso 16. Calculo de VaR (Value at Risk) o maxima perdida que se 
% puede obtener por dia a un nivel de confianza
VaR=portvrisk(0, spdt, alfa, N);

%% Paso 17. Impresion de Resultados
formatSpec1 = 'Inversion Inicial= %10.0f MXN \n'; 
fprintf(formatSpec1, N); % Es la inversion inicial
formatSpec2 = 'Retorno= %10.4f %% \n'; 
fprintf(formatSpec2, Opt_Retorno_MV*100); % Es el rendimiento esperado
formatSpec3 = 'Riesgo= %10.4f %% \n'; 
fprintf(formatSpec3, spdt*100); % Es el riesgo esperado
formatSpec4 = 'Perdida Maxima Diaria= %10.0f MXN \n'; 
fprintf(formatSpec4, VaR); % Es lo maximo que se puede perder diario

Empresa = Indices';
Porcentaje = w2';
T = table(Empresa,Porcentaje)



