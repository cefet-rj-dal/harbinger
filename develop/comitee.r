suppressWarnings({

  setwd("~/portos")
  
  # Refresh
  rm(list=ls())
  graphics.off()
  
  # Loading from github
  source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger-examples/main/jupyter.R")
  
  #    Harbinger Package
  #    version 1.0.737
  
  # Loading EIC libraries
  load_library("daltoolbox")
  load_library("harbinger")
  
  # Loading local code
  setwd("utils")
  source("ground.R")

  # Loading other libraries
  library(dplyr)
  library(ggplot2)
  library(TTR)
  library(lubridate)
  
  setwd("~/portos")
  
  
  setwd("datasets") # --
  ##espera_dataset <- readRDS("new/espera_atracacao_dia.rds") # <- docking waiting time per day (deprecated)
  ##atracacoes_dataset <- readRDS("new/atracacoes_dia.rds") # <- docking per day (deprecated)
  dataset <- readRDS("new/espera_atracacao_wb.rds")  # <- waiting ship amount per day (new)
  setwd("~/portos") # --
  
  
  
  
  # Correcting raw data ---
  ##espera_dataset_noid <- espera_dataset[,-1]
  ##atracacoes_dataset_noid <- atracacoes_dataset[,-1]
  ##espera_per_atracacoes <- espera_dataset_noid/atracacoes_dataset_noid
  ##espera_per_atracacoes[is.na(espera_per_atracacoes)] <- 0
  ##dataset <- cbind(espera_dataset[,1], espera_per_atracacoes)
  ##colnames(dataset)[1] <- "data"
  # --- --- --- --- --- --- 

  
  ensemble_detect <- function(terminal,dataset) {
    
    # Retrieve dataframe slice by terminal name
    seaport <- dataset %>% select(date, x = !!sym(terminal)) 
    
    ##seaport[,2] <- EMA(seaport[,2], n = 7) # It smooths the time series
    ##seaport[,2] <- c(0, diff(seaport$x)) # Time series change function
    
    # Change Finder ETS method
    model <- hcp_cf_ets()
    model <- fit(model, seaport$x)
    events1 <- detect(model, seaport$x)
    
    # Change Finder PELT method
    model <- hcp_pelt()
    model <- fit(model, seaport$x)
    events2 <- detect(model, seaport$x)
    
    # Add other models
    ##model <- model_name()
    ##model <- fit(model, seaport$x)
    ##events0 <- detect(model, seaport$x)
    
    all_events <- data.frame(
      
      ##m0 = events0$event, # <- Add other models
      m1 = events1$event,
      m2 = events2$event
      
    )
    
    # Left join all_events
    dataframe_events <- data.frame(date = seaport$date)
    dataframe_events <- cbind(dataframe_events, all_events)
    
    # Store ensemble and post processing filter criteria
    dataframe_events$vote <- rowSums(dataframe_events[, -1]) # Every method has 1 vote
    dataframe_events$congestion <- seaport$x # Seaport congestion amount per day
    
    return(dataframe_events)
    
  }
  
  output_process <- function(dataframe) {
    
    dataframe = dataframe %>%
      arrange(date) %>%
      mutate(detection = vote > 0 & c(0,diff(congestion)) == 0) %>% # Filters
      select(date, detection)
      
    dataframe <- dataframe[complete.cases(dataframe), ]
    
    return(dataframe)
    
  }
  
  soft_eval <- function(terminal, events, reference, margin = 5) {
    
    events$hit <- FALSE
    events$wrong <- FALSE
  
    events$date <- events$date %>% as.Date # Converting the dates to date format
    reference <- floor_date(reference, unit = "weeks") # Flooring reference
    reference <- reference[!duplicated(reference)]
    
    #events <- events %>% 
      #mutate(detection = agg_filter(events$detection)) # Filtering aggregat. ev.
    
    events <- events %>%
      mutate(ground = date %in% reference) # Storing reference in main dataframe
    
    events <- retrieve_plot_info(events, reference, margin) # Used in plot
    
    evaluation <- evaluate(har_eval_soft(sw_size=margin*2),
                           events$detection,
                           events$ground)
    
    message("=====================")
    message(terminal, ":")
    message("CONF MATRIX:")
    print(evaluation$confMatrix)
    message("PRECISION: ", evaluation$precision)
    message("RECALL: ", evaluation$recall)
    message("F1: ", evaluation$F1)
    message("=====================")
    
    return(events)
  }
  
  plot_events <- function(dataset, reference, title) {
    
    # Set a color palette
    color_palette <- c("Evento" = "#377eb8", "Falhou" = "#e41a1c", "Acertou" = "#4daf4a")
    
    # Create a ggplot object
    plot <- ggplot(data = dataset, aes(x = as.Date(date), y = congestion)) +
      
      geom_line(color = "black", linewidth = 1) +  # Adjust line color and size
      labs(title = title, x = "Semanas", y = "Fluxo de espera") + # Assign text
      theme_minimal() +  # Use minimal theme
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),  # Adjust x-axis text angle
            legend.position = "top",  # Move legend to the top
            legend.text = element_text(size = 8),
            panel.grid.major = element_blank(),  # Remove major grid lines
            panel.grid.minor = element_blank(),  # Remove minor grid lines
            panel.border = element_blank(),  # Remove panel border
            axis.line = element_line(colour = "black"),  # Add a black axis line
            plot.title = element_text(hjust = 0.5)) +  # Center the title
      
      geom_vline(aes(xintercept = as.Date(date), color = "Evento"), data = subset(dataset, reference$ground), linetype = "dashed") +
      geom_point(aes(xintercept = as.numeric(date), color = "Evento"), data = subset(dataset, reference$ground), size = 2, shape = 16) +
      #geom_point(aes(xintercept = as.numeric(date), color = "Falhou"), data = subset(dataset, reference$wrong), size = 2, shape = 16) +
      #geom_point(aes(xintercept = as.numeric(date), color = "Acertou"), data = subset(dataset, reference$hit), size = 2, shape = 16) +
      
      scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 week") + # Frequency
      scale_color_manual(name = "", values = color_palette) +  # Use color palette
      
      guides(color = guide_legend(override.aes = list(size = 3)))  # Adjust legend size
    
    return(plot)
    
  }
  
  detect_setup <- function(terminal, dataset, reference, start, end, margin = 5) {
    
    # Adjust ts interval ----
    date_range <- as.factor(seq(as.Date(start), as.Date(end), by="days"))
    dataset <- dataset %>% filter(date %in% date_range)
    # --- --- --- --- --- ---
    
    dataset <- ensemble_detect(terminal,dataset) # Run ensemble detection
    events <- output_process(dataset) # Post processing pass
    events <- soft_eval(terminal, events, reference, margin) # Evaluate detection against reference
    plot <- plot_events(dataset, events, terminal) # Plot events (should've used daltoolbox)
    print(plot) # needed
    
  }
  
  
  
  # Auxiliary functions ---
  
  agg_filter <- function(detection) {
    
    boolean_vector = detection
    
    # Step 1: Identify the indices of true values
    true_indices <- which(boolean_vector)
    
    # Step 2: Determine the range of true values
    start_index <- true_indices[1]
    end_index <- true_indices[length(true_indices)]
    
    # Step 3: Filter the middle true values within the range
    middle_true_values <- true_indices[true_indices > start_index & true_indices < end_index]
    
    # Result
    filtered_boolean_vector <- logical(length(boolean_vector))
    filtered_boolean_vector[middle_true_values] <- TRUE
    
    return(filtered_boolean_vector)
    
  }
  
  retrieve_plot_info <- function(events, reference, margin = 5) {
    for(i in 1:length(reference)) {
      for(j in 1:nrow(events)) {
        
        # Setting the margin window
        margin_range <- as.factor(seq(as.Date(reference[[i]] - days(margin)),
                                      as.Date(reference[[i]] + days(margin)),
                                      by="days"))
        
        # Retrieving hits and misses from main dataframe
        if(events$detection[j]) {
          if(events$date[j] %in% margin_range) 
            events$hit[j] <- TRUE
          events$wrong[j] <- TRUE
        }
        
      }
    }
    
    return(events)
    
  }
  
  # --- --- --- --- --- ---
  
  
  
  # Processing
  dataset$date <- as.factor(as.Date(dataset$date)) # Data to factor transformation
  
  # Run ensemble model setup
  detect_setup("Terminal de Tubarão", dataset, start="2016-01-01", end="2016-03-30", tubarao_reference)
  detect_setup("Paranaguá", dataset, start="2012-02-01", end="2012-08-30", paranagua_reference)
  detect_setup("Santos", dataset, start="2010-06-01", end="2010-09-30", santos_reference)
  
  
  
  
  # Save data frames as CSV files
  #write.csv(tubarao, file = "tubarao.csv", row.names = FALSE)
  #write.csv(paranagua, file = "paranagua.csv", row.names = FALSE)
  #write.csv(santos, file = "santos.csv", row.names = FALSE)

})