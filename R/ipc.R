library(tidyverse)
library(readxl)
ipc <- read_excel("datos/IPC 4 indvar_ div M_B10_Tot Pais_Int y Mon.xls",
                  skip = 4)

hay_algo <- function(x) any(!is.na(x))

i <- apply(ipc, 1, hay_algo) %>%
  which

j <- apply(ipc, 2, hay_algo) %>%
  which

nrow(ipc)
# ipc[i, j] %>% View

# Pierde 322 filas y 2 columnas
ipc <- ipc[i, j]

names(ipc) <-
  c("Codigo", "Nombre",
    "ipc_Pais", "var_Mes_Pais", "var_AcumAnio_Pais", "var_12m_Pais",
    "ipc_Mvd", "var_Mes_Mvd", "var_AcumAnio_Mvd", "var_12m_Mvd",
    "ipc_Int", "var_Mes_Int", "var_AcumAnio_Int", "var_12m_Int")

ipc <-
  ipc %>%
  mutate(
    Codigo = ifelse(grepl("^20", Nombre), paste(Codigo, Nombre), Codigo),
    fecha = ifelse(grepl("^[0-9]", Codigo), NA, Codigo)
    ) %>%
  dplyr::select(fecha, Codigo:var_12m_Int) %>%
  fill(fecha) %>%
  slice(-1:-4) %>%
  separate(fecha, sep = " ", into = c("mes", "anio")) %>%
  filter(!grepl("^Fuente", mes) & !is.na(Nombre)) %>%
  mutate(Codigo = ifelse(is.na(Codigo), "00", Codigo),
         anio = as.integer(anio),
         mes = case_when(
           mes == "Septiembre" ~ "Setiembre",
           mes == "Octuber" ~ "Octubre",
           TRUE ~ mes
         ),
         nmes = case_when(
           mes == "Enero" ~ 1,
           mes == "Febrero" ~ 2,
           mes == "Marzo" ~ 3,
           mes == "Abril" ~ 4,
           mes == "Mayo" ~ 5,
           mes == "Junio" ~ 6,
           mes == "Julio" ~ 7,
           mes == "Agosto" ~ 8,
           mes == "Setiembre" ~ 9,
           mes == "Octubre" ~ 10,
           mes == "Noviembre" ~ 11,
           mes == "Diciembre" ~ 12
           )
         ) %>%
  dplyr::select(anio, mes, nmes, Codigo:var_12m_Int)

save(ipc, file = "salidas/ipc.RData")
