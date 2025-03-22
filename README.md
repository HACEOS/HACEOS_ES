![GitHub Logo](/docs/Figuras/Logo_HACEOS.png)

# Una herramienta para analizar circuitos eléctricos de orden superior de forma simbólica en el dominio del tiempo

-----------------------------------------------------------------------------------
HACEOS (Herramienta de Análisis de Circuitos Eléctricos de Orden Superior) es un paquete de clases y funciones 
desarrolladas en [MATLAB][1] bajo el paradigmad de la programación orientada a objetos para analizar circuitos 
eléctricos de manera simbólica, empleando modelos generales mediante ecuaciones integro-diferenciales que permiten 
encontrar voltajes y corrientes como funciones del tiempo. Los elementos considerados por HACEOS son: resistencia, 
inductancia, capacitancia, indutancias mutuamente acopladas  por inducción, fuentes dependientes e independientes 
de voltaje y corriente. Adicionalmente, para incluir el análisis de condiciones iniciales, HACEOS permite el 
uso de interruptores simples y compuestos.


Requerimientos del sistema
-------------------------------
* [MATLAB][1] version 7.3 (R2016b) o superior.
* [Toolbox de matemática simbólica de MATLAB][2]


Instalación
------------
La instalación y uso de HACEOS requiere que el usuario esté familiarizado con la sintaxis 
básica de [MATLAB][1] para el uso de funciones y sus principales tipos de datos. Aunque no 
es estrictamente necesario, se recomienda que el usuario posea conocimientos básicos de programación 
orientada a objetos. Para instalar HACEOS solo es necesario agregar al path de MATLAB todos los
archivos asociados a la herramienta, o simplemente se puede emplear el breve instalador
incluido en la distribución. Para esto solo se requiere acceder desde MATLAB a la carpeta 
`<HACEOS_ES>` y ejecutar el comando:

		instalar_haceos

Citación de HACEOS
------------
Los [autores][3] exigimos que cualquier publicación derivada del uso de HACEOS incluyan 
explícitamente una cita de la siguiente forma:

>   W. González-Vanegas, B.S. Ospina-Rendon, and B. Gordon-Arango, "HACEOS: Herramienta de Análisis
    de Circuitos Eléctricos de Orden Superior," 2025. [En línea]. Disponible en: [https://github.com/HACEOS/HACEOS_ES][4]

---- 
 [1]: https://www.mathworks.com/
 [2]: https://www.mathworks.com/products/symbolic.html
 [3]: https://github.com/HACEOS/HACEOS_ES/AUTORES
 [4]: https://github.com/HACEOS/HACEOS_ES
