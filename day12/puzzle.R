#install.packages(c("readr"), repo = "https://cran.r-project.org/")
library(readr)
library(purrr)

lines <- read_lines("input.txt")
heightMap <- map(lines, function(line) map_dbl(utf8ToInt(line), function(letter) letter - 97))
maxY = length(heightMap)
maxX = length(heightMap[[1]])

startX <- 0
startY <- 0
endX <- 0
endY <- 0
for (i in seq_along(heightMap)){
    for (j in seq_along(heightMap[[i]])){
        if (heightMap[[i]][[j]] == -28){
            endX <- j
            endY <- i
            heightMap[[i]][[j]] <- 25
        }
        if (heightMap[[i]][[j]] == -14){
            startX <- j
            startY <- i
            heightMap[[i]][[j]] <- 0
        }
    }
}

breadthFirstSearch <- function(startX, startY, maxUpward = 1, maxDownward = 25){
    visited <- list()
    stack <- list(c(startX, startY))
    lengths <- vector("list", length = maxY)
    for(i in seq_along(lengths)) { 
        lengths[[i]] <- vector("list", length = length(heightMap[[i]]))
        for (j in seq_along(lengths[[i]])) lengths[[i]][[j]] <- 1000
    }
    lengths[[startY]][[startX]] <- 0

    withinReach <- function(x,y){
        currentHeight <- heightMap[[currentY]][[currentX]]
        return( heightMap[[y]][[x]] <= currentHeight + maxUpward &&
                heightMap[[y]][[x]] >= currentHeight - maxDownward)}

    while(length(stack) > 0){
        currentX <- stack[[1]][[1]]
        currentY <- stack[[1]][[2]]
        currentLength <- lengths[[currentY]][[currentX]]
        stack[[1]] <- NULL
        v <- FALSE
        for (i in seq_along(visited)) if (currentX == visited[[i]][[1]] && currentY == visited[[i]][[2]]) v <- TRUE
        if (!v){
            visited[[length(visited) + 1]] <- c(currentX, currentY)
            if(length(visited) %% 100 == 0) cat(".")

            if (currentX > 1)
                if (withinReach(currentX - 1, currentY)){
                    stack[[length(stack) + 1]] <- c(currentX-1, currentY)
                    lengths[[currentY]][[currentX-1]] <- min(c(lengths[[currentY]][[currentX-1]], currentLength + 1))
                }
            if (currentX < maxX)
                if (withinReach(currentX + 1, currentY)){
                    stack[[length(stack) + 1]] <- c(currentX+1, currentY)
                    lengths[[currentY]][[currentX+1]] <- min(c(lengths[[currentY]][[currentX+1]], currentLength + 1))
                }
            if (currentY > 1)
                if (withinReach(currentX, currentY - 1)){
                    stack[[length(stack) + 1]] <- c(currentX, currentY-1)
                    lengths[[currentY-1]][[currentX]] <- min(c(lengths[[currentY-1]][[currentX]], currentLength + 1))
                }
            if (currentY < maxY)
                if (withinReach(currentX, currentY + 1)){
                    stack[[length(stack) + 1]] <- c(currentX, currentY+1)
                    lengths[[currentY+1]][[currentX]] <- min(c(lengths[[currentY+1]][[currentX]], currentLength + 1))
                }
        }
    }
    cat("\n")
    return(lengths)
}

minDistance <- breadthFirstSearch(startX, startY)[[endY]][[endX]]
searchFromTop <- breadthFirstSearch(endX, endY, maxUpward=25, maxDownward=1)

cat("Puzzle 1: ", minDistance, "\n")

for (i in seq_along(heightMap)){
    for (j in seq_along(heightMap[[i]])){
        if (heightMap[[i]][[j]] == 0){
            minDistance <- min(c(minDistance, searchFromTop[[i]][[j]]))
        }
    }
}
cat("Puzzle 2: ", minDistance, "\n")