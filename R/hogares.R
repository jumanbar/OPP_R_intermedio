library(tidyverse)
library(haven)

hog <- 
  read_sav("datos/H_2011_TERCEROS.zip") %>% 
  mutate_if(is.labelled, as.integer) %>% 
  mutate(anio = as.character(anio), 
         numero = as.character(numero)) %>% 
  rename_all(tolower)
names(hog)

arch <- 
  dir(path = "datos", pattern = "^H_.*\\.zip") %>% 
  grep("2011", ., invert = TRUE, value = TRUE)

nombres <- list(H_2011_TERCEROS.sav = names(hog))

sel <- 
  c("anio", "numero", "dpto", "nomdpto", "region_3", "region_4", "secc", "segm",
    "mes", "pesoano", "pesosem", "pesotri", "pesomen", "c1", "d23", "d24", 
    "d25", "ht11", "yhog", "ysvl")

hog <- hog %>% select(sel)


# h16 <- read_delim("datos/H_2016_Terceros.dat", 
#                   "\t", escape_double = FALSE, 
#                   locale = locale(decimal_mark = ",", 
#                                   encoding = "ISO-8859-1"), trim_ws = TRUE)
# 
# 
# View(h16)


for (i in 1:length(arch)) {
  if (grepl("2016", arch[i])) {
    tmp <- read_delim(file.path("datos", arch[i]), 
                      "\t", escape_double = FALSE, 
                      locale = locale(decimal_mark = ",", 
                                      encoding = "ISO-8859-1"), 
                      trim_ws = TRUE) %>% 
      mutate(anio = as.character(anio),
             numero = as.character(numero)) %>% 
      rename_all(tolower)
    
  } else {
    tmp <- 
      read_sav(file.path("datos", arch[i])) %>% 
      mutate_if(is.labelled, as.integer) %>% 
      mutate(anio = as.character(anio),
             numero = as.character(numero)) %>% 
      rename_all(tolower)
  }
  names(tmp) <- tolower(names(tmp))
  nombres[[arch[i]]] <- names(tmp) 
  
  pesos <- c("pesosem", "pesotri", "pesomen")
  for (j in 1:length(pesos)) {
    if (!any(names(tmp) == pesos[j])) {
      cat("Archivo", arch[i], "columna", pesos[j], "\n")
      tmp[pesos[j]] <- tmp$pesoano
    }
      }
  
  tmp <- tmp %>% select(sel)
  
  hog <- full_join(hog, tmp)
}

# Archivo H_2012_TERCEROS.sav columna pesosem
# Archivo H_2012_TERCEROS.sav columna pesotri
# Archivo H_2012_TERCEROS.sav columna pesomen
# Archivo H_2016_Terceros.dat columna pesosem
# Archivo H_2018_Terceros.sav columna pesosem

# 
# inter <- nombres[[1]]
# for (i in 2:length(nombres))
#   inter <- intersect(inter, nombres[[i]])
# 
# inter %>% dput

# load("salidas/hog.RData")

hog <- 
  hog %>%
  mutate(
    anio = as.integer(anio),
    nmes = mes,
    mes = case_when(
      nmes == 1 ~ "Enero",
      nmes == 2 ~ "Febrero",
      nmes == 3 ~ "Marzo",
      nmes == 4 ~ "Abril",
      nmes == 5 ~ "Mayo",
      nmes == 6 ~ "Junio",
      nmes == 7 ~ "Julio",
      nmes == 8 ~ "Agosto",
      nmes == 9 ~ "Setiembre",
      nmes == 10 ~ "Octubre",
      nmes == 11 ~ "Noviembre",
      nmes == 12 ~ "Diciembre"
    )) %>% 
  dplyr::select(anio, mes, nmes, numero:segm, pesoano:ysvl)

save(hog, file = "salidas/hog.RData")
