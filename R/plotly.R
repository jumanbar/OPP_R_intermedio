library(ggplot2)
library(plotly)
p <- ggplot(data = diamonds) +
  aes(x = cut, fill = clarity) +
  geom_bar(position = "dodge")

# Al imprimir p se ve un gráfico normal (y estático) de ggplot:
p

# Con la función ggplotly el gráfico es convertido al formato de plotly: un
# gráfico web (basado en javascript), el cual es interactivo hasta cierto punto
# (probar pasar el puntero del mouse por encima de las barras o hacer click en
# la leyenda):
ggplotly(p)
