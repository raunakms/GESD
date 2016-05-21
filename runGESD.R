gesd <- function(obs, alpha, value.zscore=NA, r=NA) {
	#### Define and Declare Variables ####
	n <- length(obs)
	if(is.na(r)){r <- floor(n/2)} # by default, set upper bound on number of outliers 'r' to 1/2 sample size
	R <- numeric(length=r) # test statistics for 'r' outliers
	lambda <- numeric(length=r) # critical values for 'r' outliers
	outlier_ind <- numeric(length=r) # removed outlier observation values
	outlier_val <- numeric(length=r) # removed outlier observation values
	m <- 0 # number of outliers
	obs_new <- obs # temporary observation values
	
	#### Find outliers ####
	for(i in 1:r){
	
		#### Compute test statistic ####
		if((value.zscore == "YES") | (value.zscore == "Y")){
			z <- abs(obs_new) # If Z-score is alrealy computed
		}else if((value.zscore == "NO") | (value.zscore == "N")){
			z <- abs(obs_new - mean(obs_new))/sd(obs_new) # Z-scores
		} else{
			print("ERROR! Inappropriate value for value.score=[YES|NO]")
		}
		
		max_ind <- which(z==max(z),arr.ind=T)[1] # in case of ties, return first one
		R[i] <- z[max_ind] # max Z-score
		outlier_val[i] <- obs_new[max_ind] # removed outlier observation values
		outlier_ind[i] <- which(obs_new[max_ind] == obs, arr.ind=T)[1] # index of removed outlier observation values
		obs_new <- obs_new[-max_ind] # remove observation that maximizes |x_i - x_mean|
		
		#### Compute critical values ####
		##n_obs <- length(obs_new) # subset sample size
		p <- 1 - alpha/(2*(n-i+1)) # probability
		t_pv <- qt(p,df=(n-i-1)) # Critical value from Student's t distribution
		lambda[i] <- ((n-i)*t_pv) / (sqrt((n-i-1+t_pv^2)*(n-i+1)))
		
		#### Find exact number of outliers: largest 'i' such that R_i > lambda_i ####
		# print(c(i, R[i], lambda[i]))
		# try ((R[i] > lambda[i]), finally <- print(c(i, R[i], lambda[i]))
		# )
		if(!is.na(R[i]) & !is.na(lambda[i])) { # qt can produce NaNs
			if (R[i] > lambda[i]) {
				m <- i
			}
			# else {
				# break
			# }
			
		}
	}

	vals <- data.frame(NumOutliers=1:r, TestStatistic=R, CriticalValue=lambda)
	# print(vals)
	
	#### Rank outlier observations ####
	outlier_rank <- numeric(length=n)
	if (m > 0) {
		for (i in 1:m) {
			# outlier_rank[outlier_ind[i]] <- i
			outlier_rank[which(obs==outlier_val[i])] <- i
		}
	}
	num_outliers <- sum(outlier_rank != 0) #14 and 25 missing
	res <- c(num_outliers, outlier_rank)
	names(res) <- c("Total", names(obs))
	
	return(res)	
}
