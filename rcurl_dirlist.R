#list all files in a FTP directory

rcurl_dirlist <- function(url, full = TRUE){
  dir <- unlist(
    strsplit(
      getURL(url,
             ftp.use.epsv = FALSE,
             dirlistonly = TRUE),
      "\n")
  )
  if(full) dir <- paste0(url, dir)
  return(dir)
}


rcurl_dirlist(paste('ftp://ladsweb.nascom.nasa.gov/allData/6/',product,'/',sep=''))
