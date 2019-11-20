# Ejemplo tomado de:
browseURL("https://renkun-ken.github.io/formattable/")

# install.packages("formattable")
# install.packages("DT")
library(formattable)
library(DT)

# Una tabla de datos
df <- data.frame(
  id = 1:10,
  name = c("Bob", "Ashley", "James", "David", "Jenny", 
           "Hans", "Leo", "John", "Emily", "Lee"), 
  age = c(28, 27, 30, 28, 29, 29, 27, 27, 31, 30),
  grade = c("C", "A", "A", "C", "B", "B", "B", "A", "C", "C"),
  test1_score = c(8.9, 9.5, 9.6, 8.9, 9.1, 9.3, 9.3, 9.9, 8.5, 8.6),
  test2_score = c(9.1, 9.1, 9.2, 9.1, 8.9, 8.5, 9.2, 9.3, 9.1, 8.8),
  final_score = c(9, 9.3, 9.4, 9, 9, 8.9, 9.25, 9.6, 8.8, 8.7),
  registered = c(TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE, FALSE),
  stringsAsFactors = FALSE)

# Definición de formato:
#
# El segundo argumento es una lista cuyos nombres coinciden con los nombres de
# las columnas de df y que usa diferentes ejemplos para dar formato a las
# celdas.
#
# Lo más interesante es que el formato de cada celda no es especificado caso a
# caso, si no que se expresa a través de reglas.
#
# Por ejemplo, la columna age se imprime con fondo blanco para la menor edad
# encontrada y naranja para la celda de mayor edad
#
# Por otro lado, la columna grade es tiene un comportamiento binario: si == "A"
# la fuente será verde y "negrita", pero normal en otros casos.
df_linda <- 
  formattable(df, list(
  age = color_tile("white", "orange"),
  grade = formatter(
    "span", style = x ~ ifelse(x == "A", 
                               style(color = "green", font.weight = "bold"), 
                               NA)),
  # La siguiente línea define el formato de dos columnas al mismo tiempo:
  area(col = c(test1_score, test2_score)) ~ normalize_bar("pink", 0.2),
  final_score = formatter("span",
                          style = x ~ style(color = ifelse(rank(-x) <= 3, "green", "gray")),
                          x ~ sprintf("%.2f (rank: %02d)", x, rank(-x))),
  registered = formatter("span",
                         style = x ~ style(color = ifelse(x, "green", "red")),
                         x ~ icontext(ifelse(x, "ok", "remove"), ifelse(x, "Yes", "No")))
))

# Así se ve por defecto:
print(df_linda)

# Así se ve convertida a datatable (paquete DT), lo cual agrega varias
# herramientas, como ordenar por columnas, caja de búsqueda y más:
df_linda%>% 
  as.datatable()

# También es posible combinar formattable con kableExtra:
browseURL("https://haozhu233.github.io/kableExtra/use_kableExtra_with_formattable.html")
