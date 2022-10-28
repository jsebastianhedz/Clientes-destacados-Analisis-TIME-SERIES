# Clientes-destacados-Analisis-TIME-SERIES
Analsisis de serie de tiempo de clientes destacados no regulados y regulados para la detección de irregularidades o anomalias
%% Analisis de series de tiempo de consumos de clientes destacados regulados y no regulados en el distribudor/comercializador del Huila Colombia.
Se realiza análisis mediante los siguientes criterios del perfil de carga para la programación de brigadas, para cada nivel de tensión, mediante las siguientes reglas:
Novedad por lecturas de facturación
Novedad por PQR
Novedad telemedida	Se tiene reporte por novedades por el centro de gestión de la medida CGM
Novedad sin total información	Describe linealmente la curva de consumo la proyección de la tendencia de consumo.
Novedad consumos a cero	Mide lo bien qué una Ec. Lineal describe la relación entre el consumo de energía, y el tiempo.
Regla difusa	Consumo registrado de energía reactiva mayor a la activa.
Regla 1	Un punto más allá del límite de control +-3 Desv.Estandar.
Regla 2	Dos de tres puntos seguidos más allá del +-2 Desv.Estandar.
Regla 3	4 de 5 puntos seguidos más allá de +-1 Desv.Estandar.
Regla 4	8 puntos consecutivos por encima o por debajo del promedio.
Regla 5	8 puntos consecutivos por a ambos lados de la línea de control evitando el área +-1Delta.
Regla 6	15 puntos seguidos dentro del área +-1 Desv.Estandar.
Regla 7	14 puntos arriba y abajo alternados en una fila.
Regla 8	6 puntos seguidos aumentando o disminuyendo constantemente.
Regla de indice de perdida del alimentador
Regla de indice de capacidad del transformador
Regla difusa	Consumo registrado de energía reactiva mayor a la activa.
Pendiente	Describe linealmente la curva de consumo la proyección de la tendencia de consumo.
Coef.Pearson	Mide lo bien qué una Ec. Lineal describe la relación entre el consumo de energía, y el tiempo.
Promedio	El promedio de consumo en el periodo de tiempo sin incluir consumos en cero.
Desv.Estandar	La dispersión en el tiempo de la curva de consumo en el periodo de tiempo.
LCL	Límite de control inferior con respecto su historial de consumo en el intervalo de tiempo.
UCL	Límite de control superior con respecto su historial de consumo en el intervalo de tiempo.

%% Se debe realizar seguimiento de las cuentas para su veracidad en el consumo de energía del USR y se resumen en las posibles situaciones:
	El consumo por diferencia de lectura es igual al consumo registrado en el PRIMEREAD.
	Existe mayor consumo en SIEC con respecto PRIMEREAD, por causa de falta de registro en el PRIMEREAD.
	Existe mayor consumo en PRIMEREAD sin acceso al sistema de medida sin registrar SIEC.
	Existe alguna irregularidad y/o anomalía en el sistema de medida generando mayor consu-mo en PRIMEREAD por corrección del factor multiplicador.

La programación de revisión de análisis se utiliza criterios de prioridad como:

	Indicador de pérdida del alimentador de mayor a menor.
	Indicador de pérdida del nodo de distribución de mayor a menor,
	Alta probabilidad de perdida por desviaciones, cambios de consumo y sus tipos.
	Última fecha de visita por el área de perdida mayo a un año u otro contratista donde no se eviden-cia el aseguramiento de la medida.

Las novedades encontradas, más la aprobación de ElectroHuila, el área de comercialización y su trámite correspondiente para clientes destacados se realiza la programación para la ve-rificación en terreno y hacer las respectivas acciones correctivas. Ver anexo “Entregable. Se-guimiento Destacados.xlsx” perseverancia 

La metodología propuesta y criterios de recuperación se explica en el ítem 1.1.1 tanto para clientes telemedidas y no telemedidas se expresan como una serie de tiempo. Es importante mencionar, se requiere más detalles para periodos de facturación bimestrales, por lo tanto, se complementa con otro tipo de análisis como novedades de facturación.

Es importante dejar nota sobre el tamaño del conjunto, para analizar la totalidad los USRs se tiene una muestra mayor a 1.000 series de tiempo y se considera como tamaño grande de conjunto. Por lo tanto, es necesario un algoritmo metodológico propuesto para el análi-sis y alcanzar índices de tasa de control acordes a las necesidades en la gestión de perdidas.

Las principales causas de pérdidas y motivo para la ejecución de la metodología propuesta- es determinada por la verificación en terreno por las siguientes causas:

	Ausencia de medición (diversas causas)
	Adopción de estándares y redes vulnerables al robo de energía.
	Adopción de equipos y esquemas de medición deficientes.
	Errores de conexión.
	Fallas en el registro (consumo propio, IP, cargas especiales).
	Errores en la facturación.
	Fraude interno.
	Desviación antes de la medición.
	Conexión clandestina.
	Fraude en los equipos de medición.
	Impunidad y connivencia de la sociedad (cultura de que el robo de energía no es un crimen).
