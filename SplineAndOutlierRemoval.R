#---------------------------------------------------------------------
# This function takes a time series w/ dates (x, dates) and returns a spline smoothed time series with outliers removed.
# Outliers are identified as points with absolute value more than out_sigma * sd, where sd is the residual
# standard deviation between the input data and the initial spline fit, and out_sigma is a variable
# coefficient. The spline smoothing parameter spline_spar controls the smoothness of the fit (see spline.smooth help)
# and out_iterations controls the number of times that outliers are checked and removed w/ subsequent spline refit
# pred_dates is a vector of dates where spline smoothed predictions of x are desired. If NA, then a daily series spanning
# min(dates)-max(dates) is returned
SplineAndOutlierRemoval <- function(x, dates, out_sigma=3, spline_spar=0.3, out_iterations=1,pred_dates){
  dates <- as.numeric(dates) # spline doesn't work with dates
  pred_dates = as.numeric(pred_dates)
  # if prediction dates aren't provided, we assume we want daily ones
  if(is.na(pred_dates[1])){
    pred_dates <- min(dates, na.rm=T):max(dates, na.rm=T)}
  # eliminate outliers and respline
  for(i in 1:out_iterations){
    # fit a smoothing spline to non-missing data
    spl <- try(smooth.spline(dates[!is.na(x)], x[!is.na(x)], spar=spline_spar), silent=T)
    if(inherits(spl, 'try-error')){
      print("Failed to fit smoothing spline")
      return(NA)
    }
    smooth_x <- try(predict(spl, dates)$y, silent=T) # calculate spline smoothed values
    if(inherits(smooth_x, 'try-error')){
      print("Failed to predict with spline")
      return(NA)
    }
    smooth_x_resid <- x - smooth_x # calculate residuals from spline
    smooth_x_resid_sd <- try(sd(smooth_x_resid, na.rm=T), silent=T) # standard dev of absolute value of residuals
    if(inherits(smooth_x_resid_sd, 'try-error')){
      print("Failed to get sd of residuals")
      return(NA)
    }
    outliers <- abs(smooth_x_resid) > out_sigma * smooth_x_resid_sd
    outliers[is.na(outliers)] <- F
    if(sum(outliers) > 0){
      # if we found outliers, eliminate them in x and refit up to iterations
      x[outliers] <- NA
    }else{
      # if we didn't find any outliers, we abandon the iteration and return the smoothed values
      smooth_x_return <- try(predict(spl, pred_dates)$y, silent=T)
      if(inherits(smooth_x_return, 'try-error')){
        print("No outliers, but failed to predict with final spline")
        return(NA)
      }else{
        return(smooth_x_return)
      }
    }
  }
  # fit the spline to the outlier screened data, then return the predicted series
  spl <- try(smooth.spline(dates[!is.na(x)], x[!is.na(x)], spar=spline_spar), silent=T)
  if(inherits(spl, 'try-error')){
    print("Failed to predict with final spline")
    return(NA)
  }else{
    smooth_x_return <- try(predict(spl, pred_dates)$y, silent=T)
    if(inherits(smooth_x_return, 'try-error')){
      return(NA)
    }else{
      return(smooth_x_return)
    }
  }
}


# 
# # And a testing example:
# 
# set.seed(42)
# t <- seq(0, 4*pi, len=80)
# dates <- seq(as.Date("2000-1-1"), as.Date("2001-12-31"), len=length(t))
# pred_dates <-  seq(min(dates), max(dates),by='week' ) # dates where pred is wanted
# x <- -cos(t) + rnorm(length(t), 0, 0.3)
# x[sample(1:length(t), 35)] <- NA
# smooth_x <- SplineAndOutlierRemoval(x=x, dates=dates, pred_dates=pred_dates)
# smoother_x <- SplineAndOutlierRemoval(x, dates, pred_dates=pred_dates, spline_spar=0.5)
# 
# plot(dates, x)
# points(pred_dates, smooth_x, type="l", col=4)
# points(pred_dates, smoother_x, type="l", col=2)
