
# Importación de tablas hogares

> hogares.R

## Descarga de archivos

Importar tablas de la ECH (hogares) desde 2011 hasta 2018 (el ipc basado en 2010 va desde 2011 así que me pareció un buen rango de fechas).

Lo que hice fue bajar los archivos de la ECH de esos años y extraer de los .rar los correspondientes exclusivamente a hogares. Luego los comprimí en .zip para que ocupen menos espacio, y los guardé todos en la carpeta datos.

## ECH 2016

Encontré que la ECH 2016 no tiene sav, así que en ese caso importo .dat. Esto implica que hay que hacer una expeción en el loop (con un if). Además de que se importa con otra función (read_delim, en lugar de read_sav), implica que no tiene columnas de clase `haven_labelled`, si no que son simplemente numéricas (ej: columna dpto). La solución es siempre convertir este tipo de columnas a integer (ya sea que vienen de un archivo sav o de uno dat).

Para hacer esto usé mutate_if. Ejemplo (requiere tener cargados los paquetes haven y tidyverse):

```r
hog <-
  read_sav("datos/H_2011_TERCEROS.sav") %>%
  mutate_if(is.labelled, as.integer)
```

Acá aprovecho que existe `is.labelled` para reconocer los casos de columnas haven_labelled.

## Años como character

Aparentemente al importar las tablas, en algunos casos ocurría que la columna años era clase character, en vez de integer o double. Así que me aseguré que siempre son años, agregando una línea. Ejemplo:

```r
hog <-
  read_sav("datos/H_2011_TERCEROS.sav") %>%
  mutate_if(is.labelled, as.integer) %>%
  mutate(anio = as.integer(anio))
```

## Nombres de columnas

Cambié todos los nombres de las columas a minúsculas (`rename_all(tolower)`). Además hice una lista en donde guardo los nombres originales de las columnas de todas las tablas.

## Pesos semestre, trimestre y mes

No todas las tablas tienen estas columnas. Encontré que estos casos:

- Archivo H_2012_TERCEROS.sav: falta columna pesosem  
- Archivo H_2012_TERCEROS.sav: falta columna pesotri  
- Archivo H_2012_TERCEROS.sav: falta columna pesomen  
- Archivo H_2016_Terceros.dat: falta columna pesosem  
- Archivo H_2018_Terceros.sav: falta columna pesosem  

Lo que hice fue, en estos casos, agregar estas columnas a las tablas en las que faltaba, poniendo allí los valores de pesoano. Obviamente esto casi seguramente puede tener problemas, pero por ahora lo voy a dejar así.
