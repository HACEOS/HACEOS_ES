classdef md_puerta_fte_dep < hcs.md_puerta
% md_puerta_fte_dep - Subclase para fuentes dependientes
%
% Esta subclase se encarga de asignar el objeto de tipo puerta dependiente,
% hereda de la superclase md_puerta
%
% Propiedades de md_puerta_fte_dep:
%	* tipo_fuente
%   * tipo_dep
%   * id_dep
%   * constante
%
% Metodos de md_puerta_fte_dep:
%
% See also md_puerta, formato_caso

%   HACEOS - Herramienta para el Analisis de Circuitos Electricos de Orden Superior
%   Copyright (c) 2025, Grupo de Investigacion en Campos Electromagneticos y Fenomenos Energeticos - CAFE
%					    Universidad Tecnologica de Pereira (UTP)
%  	Por: Brandon Ospina y Brian Gordon, CAFE-UTP
%   y Wilson Gonzalez Vanegas, CAFE-UTP y Universidad Nacional de Colombia Sede Manizales
%
%   Este archivo es parte del proyecto HACEOS.
%   Cubierto por la licencia 3-clause BSD (mas detalles en el archivo LICENSE).
%   Vea https://github.com/HACEOS/ para mayor informacion.
% 	
%   Nota: este archivo es libre de tildes para evitar posibles conflictos en sistemas sin codificacion UTF-8

    properties
        tipo_fuente
        tipo_dep
        id_dep
        constante
    end
    methods
        function obj = puertas_ftes_depend(naturaleza, naturaleza_dependencia, id_puerta_dependencia, constante_proporcionalidad)
            % Constructor
        
        end
        
    end
end