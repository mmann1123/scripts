my_nb2mat = function (neighbours, glist = NULL, style = "W", zero.policy = NULL) 
  {
  #  These functions use bigmemory package to create large spatial weights matrix works with R\R-2.15.3   
  # use with my_listw2mat.R
  
    print('this function allow you to create spatial weights matrixes
          larger  than 15gb')
    if (is.null(zero.policy)) 
      zero.policy <- get("zeroPolicy", envir = .spdepOptions)
    stopifnot(is.logical(zero.policy))
    if (!inherits(neighbours, "nb")) 
      stop("Not a neighbours list")
    listw <- nb2listw(neighbours, glist = glist, style = style, 
                      zero.policy = zero.policy)
    res <- my_listw2mat(listw)
    attr(res, "call") <- match.call()
    res
  }