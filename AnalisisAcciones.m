%% Limpiar pantalla y memoria
close all;
clear all;
clc;

%% Asignar valores a las variables
s=1000; %Numero de simulaciones

%% Cargar datos de las acciones
Negocio=5;
[data_MV, str]=xlsread('DatosAAPL3.xlsx');
[f,c]=size(data_MV);
Indices=str(1,2:c+1);
x=data_MV(:,Negocio);

%% Periodo a evaluar de los 5 a?os
years=2;
x=x(1:round(years*251),:);    
    
%% Encabezado global de la figura
f = figure();
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = Indices(Negocio); 
p.TitlePosition = 'centertop'; 
p.FontSize = 12;
p.FontWeight = 'bold';


%% Histograma de diferencias de crecimiento
z=diff(x);
%figure();
subplot(3,3,1,'Parent',p);
hist(z,100);
grid on

title('Variacion Absoluta de un Periodo al Siguiente','FontName','Times New Roman','FontSize', 12);
xlabel('Valor en MXN','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);

%% Grafica del comportamiento de las acciones
 
subplot(3,3,5);
plot(x);
grid minor

title('Comportamiento historico de los datos','FontName','Times New Roman','FontSize', 12);
xlabel('Tiempo en unidades correspondientes','FontName','Times New Roman','FontSize', 12);
ylabel('Valor en Unidades Monetarias','FontName','Times New Roman','FontSize', 12);

%% Grafica del ajuste del polinomio de pronostico

% Cargar datos
y=x;
%y=data_MV(:,Negocio);

% Ajuste a un polinomio
nn=length(y);
xx=(1:1:nn);
xx=xx';

% Grafica puntos
subplot(3,3,4);
hist(y,100);
grid minor;

title('Valor promedio historico','FontName','Times New Roman','FontSize', 12);
xlabel('Valor de la accion en unidades monetarias','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);

% Promedio
ValorPromedio=mean(y);
legend(num2str(ValorPromedio), 'location','Best');

% Grafica pronostico
subplot(3,3,6);
curvefit = fit(xx,y,'poly3','normalize','off');
plot(curvefit,xx,y);
%plot(curvefit);
grid minor;

title('Valor pronosticado a 12 meses','FontName','Times New Roman','FontSize', 12);
xlabel('Tiempo en unidades correspondientes','FontName','Times New Roman','FontSize', 12);
ylabel('Valor en Unidades Monetarias','FontName','Times New Roman','FontSize', 12);

% Pronostico
ValorPronosticado=curvefit(nn+253);
legend(num2str(ValorPronosticado), 'location','Best');

%% Histograma de cocientes de crecimiento

n=length(x);

for i=1:n-1;
  ww(i)=x(i+1)/x(i);
end;
ww=ww';

subplot(3,3,2);
hist(ww,100);
grid on

title('Variacion Relativa de un Periodo al Siguiente','FontName','Times New Roman','FontSize', 12);
xlabel('Cociente del periodo siguiente entre el actual','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);



%% Histograma de crecimiento relativo al primer valor

v=x/x(1);

subplot(3,3,3);
hist(v,100);
grid on

title('Variacion Relativa de los Periodos con Respecto al Primero','FontName','Times New Roman','FontSize', 12);
xlabel('Cociente del los periodos entre el primero','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);

%% Ajuste a distribuciones parametricas - 1

x=z;

[D PD]=allfitdist(x,'PDF');
C= {'nakagami', 'rayleigh','rician', 'birnbaumsaunders', ...
    'generalized pareto','inversegaussian', 'logistic', ...
    'loglogistic', 'tlocationscale'};
nC = length(C);
nD = length(D);

for k=1:nC
for i=1:nD
  switch D(1,i).DistName 
      case C{k};
      D(i) = [];
      D(nD) = D(1);
  end
end
end

switch D(1,1).DistName
case  'generalized extreme value'
    K=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    Mu=D(1,1).Params(1,3);
    y = gevrnd(K, Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'beta'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = betarnd(a,b, s, 1);
    save autos.dat y -ascii;
case  'exponential'
    mu = D(1,1).Params(1,1);
    y = exprnd(mu, s, 1);
    save autos.dat y -ascii;
case   'extreme value'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = evrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'gamma'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = gamrnd(a,b, s, 1);
    save autos.dat y -ascii;
case   'lognormal'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = lognrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case   'normal'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = normrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'weibull'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = wblrnd(a,b, s, 1);
    save autos.dat y -ascii;
end

D(1);
close(figure(2));

load autos.dat;
x= autos;

subplot(3,3,7);
hist(x,50);
hold on
y = ylim; % Limites vertivales del eje y
plot([0 0],[y(1) y(2)])
grid on

title('Distribucion de probabilidad','FontName','Times New Roman','FontSize', 12);
xlabel('Valor en MXN','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);

k=find(x>0);
prob=length(k)/s;
sd1=['Prob de exito: '];
legend(sd1, num2str(prob), 'location','Best');

hold off
%% Ajuste a distribuciones parametricas - 2

x=ww;

[D PD]=allfitdist(x,'PDF');
C= {'nakagami', 'rayleigh','rician', 'birnbaumsaunders', ...
    'generalized pareto','inversegaussian', 'logistic', ...
    'loglogistic', 'tlocationscale'};
nC = length(C);
nD = length(D);

for k=1:nC
for i=1:nD
  switch D(1,i).DistName 
      case C{k};
      D(i) = [];
      D(nD) = D(1);
  end
end
end

switch D(1,1).DistName
case  'generalized extreme value'
    K=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    Mu=D(1,1).Params(1,3);
    y = gevrnd(K, Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'beta'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = betarnd(a,b, s, 1);
    save autos.dat y -ascii;
case  'exponential'
    mu = D(1,1).Params(1,1);
    y = exprnd(mu, s, 1);
    save autos.dat y -ascii;
case   'extreme value'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = evrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'gamma'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = gamrnd(a,b, s, 1);
    save autos.dat y -ascii;
case   'lognormal'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = lognrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case   'normal'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = normrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'weibull'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = wblrnd(a,b, s, 1);
    save autos.dat y -ascii;
end

D(1);
close(figure(2));

load autos.dat;
x= autos;

subplot(3,3,8);
hist(x,50);
hold on
y = ylim; % Limites vertivales del eje y
plot([1 1],[y(1) y(2)]);
grid on

title('Distribucion de probabilidad','FontName','Times New Roman','FontSize', 12);
xlabel('Cociente del periodo siguiente entre el actual','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);

k=find(x>1);
prob=length(k)/s;
sd1=['Prob de exito: '];
legend(sd1, num2str(prob), 'location','Best');

hold off
%% Ajuste a distribuciones parametricas - 3

x=v;

[D PD]=allfitdist(x,'PDF');
C= {'nakagami', 'rayleigh','rician', 'birnbaumsaunders', ...
    'generalized pareto','inversegaussian', 'logistic', ...
    'loglogistic', 'tlocationscale'};
nC = length(C);
nD = length(D);

for k=1:nC
for i=1:nD
  switch D(1,i).DistName 
      case C{k};
      D(i) = [];
      D(nD) = D(1);
  end
end
end

switch D(1,1).DistName
case  'generalized extreme value'
    K=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    Mu=D(1,1).Params(1,3);
    y = gevrnd(K, Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'beta'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = betarnd(a,b, s, 1);
    save autos.dat y -ascii;
case  'exponential'
    mu = D(1,1).Params(1,1);
    y = exprnd(mu, s, 1);
    save autos.dat y -ascii;
case   'extreme value'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = evrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'gamma'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = gamrnd(a,b, s, 1);
    save autos.dat y -ascii;
case   'lognormal'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = lognrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case   'normal'
    Mu=D(1,1).Params(1,1);
    Sigma = D(1,1).Params(1,2);
    y = normrnd(Mu, Sigma, s, 1);
    save autos.dat y -ascii;
case  'weibull'
    a = D(1,1).Params(1,1);
    b=D(1,1).Params(1,2);
    y = wblrnd(a,b, s, 1);
    save autos.dat y -ascii;
end

D(1);
close(figure(2));

load autos.dat;
x= autos;

subplot(3,3,9);
hist(x,50);
hold on;
y = ylim; % Limites vertivales del eje y
plot([1 1],[y(1) y(2)])
grid on

title('Distribucion de probabilidad','FontName','Times New Roman','FontSize', 12);
xlabel('Cociente del los periodos entre el primero','FontName','Times New Roman','FontSize', 12);
ylabel('Frecuencia','FontName','Times New Roman','FontSize', 12);

k=find(x>1);
prob=length(k)/s;
sd1=['Prob de exito: '];
legend(sd1, num2str(prob), 'location','Best');

hold off;


