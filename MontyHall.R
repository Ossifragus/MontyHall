mont <- function(choice=1) {
  doors <- 1:3
  car <- sample(doors, 1)
  if (choice == car) {
    host <- sample(doors[-c(choice)], 1)
  } else {
    host <- doors[-c(choice, car)]
  }
  switch <- doors[-c(choice, host)]
  return(c(choice, car, switch, host))
}

countMTH <- function(n) {
  result <- replicate(n, mont())
  open3 <- result[4,] == 3
  open3games <- result[, open3]
  return(c(mean(open3games[1,] == open3games[2,]),
           mean(open3games[3,] == open3games[2,])))
}

set.seed(1)
countMTH(10^4)

system.time(countMTH(10^6))
