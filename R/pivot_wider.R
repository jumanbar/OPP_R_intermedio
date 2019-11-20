# La función pivot_wider es parte del paquete tidyr, incluido en el tidyverse:
library(tidyverse)

# Datos ficticios -----
tabla <- tibble(
  concepto = rep(c("A", "B", "C"), times = 2),
  anio = rep(c(2017, 2018), each = 3),
  monto_p = rnorm(6, mean = 4255771, sd = 3.7e4),
  monto_d = monto_p / 35
  )

# Ensanchar con pivot_wider ----
tablancha <- 
  tabla %>% 
  pivot_wider(concepto, 
              names_from = anio,
              values_from = c(monto_p, monto_d))

# Visualización bonita ----
library(knitr) # contiene función kable
library(kableExtra)
tablancha %>% 
  kable(
    # Formato de columnas numéricas:
    format.args = list(big.mark = ".", decimal.mark = ","),
    # Renombrar las columnas:
    col.names = c("concepto", "2017", "2018", "2017", "2018")
    ) %>% 
  # Opciones de visualización:
  kable_styling(c("striped", "hover")) %>% 
  # Agrupamiento de encabezado:
  add_header_above(c(" " = 1, "Pesos" = 2, "Dólares" = 2))


# Atención! ----
# 
# "You can copy formatted tables from HTML and paste them into a Word document
#  without losing the format."
browseURL("https://haozhu233.github.io/kableExtra/kableExtra_and_word.html")
