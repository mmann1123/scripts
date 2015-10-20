  my_listw2mat = function (listw) 
  {
    
    #  These functions use bigmemory package to create large spatial weights matrix works with R\R-2.15.3   
    # use with my_nb2mat.R
    require(bigmemory)
    n <- length(listw$neighbours)
    if (n < 1) 
      stop("non-positive number of entities")
    cardnb <- card(listw$neighbours)
    if (any(is.na(unlist(listw$weights)))) 
      stop("NAs in general weights list")
    #res <- matrix(0, nrow = n, ncol = n)
    res <- big.matrix(n, n, type='double', init=NULL)
    options(bigmemory.allow.dimnames=TRUE)
    
    for (i in 1:n) if (cardnb[i] > 0) 
      res[i, listw$neighbours[[i]]] <- listw$weights[[i]]
    if (!is.null(attr(listw, "region.id"))) 
      row.names(res) <- attr(listw, "region.id")
    res
  }