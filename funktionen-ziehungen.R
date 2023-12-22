# Simulation der Ziehungen

# install.packages("Rlab")
library(Rlab)

ziehungen <-
  replicate(
    n = 12, 
    rbern(n = 200, prob = 0.65),
    simplify = F
  )

ziehungen_names <- c()

for(i in 1:3) {
  for(j in 1:4) {
    ziehungen_names <-
      ziehungen_names %>% 
      append(paste0("Institut ", i, ", Umfrage ", j))
  }
}

ziehungen <-
  tibble(
    !!!set_names(
      ziehungen,
      ziehungen_names
    )
  )

write_csv(
  ziehungen, 
  file = "funktionen-ziehungen.csv", 
  col_names = T
)