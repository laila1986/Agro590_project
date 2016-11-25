
scenario_generator <- function(inputs){  
  x <- c()
  for(i in 1:length(inputs)) {
    idx <- sample(1:length(inputs[[i]]), 1)
    x <- c(x,as.character(inputs[[i]][idx]))
    
  }
  x <- data.frame(matrix(x,byrow =T,ncol = 7))
  names(x) <- names(inputs)  
  return(x)
}


multiscenario_random <- function(inputs,n=3){
  
  if(n > 10) stop("Oooops... Too many scenarios!")
  
  scenarios <-  data.frame()
  
  for(i in 1:n){
    x <- scenario_generator(inputs)
    x$scenario <- paste0(LETTERS[i])
    scenarios <- rbind(scenarios,x)
  }
  return(scenarios)
}
