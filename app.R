#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


library(shiny)
library(ggplot2)
library(sf)
library(dplyr)
library(here)
library(tidyverse)
library(cowplot)
library(fuzzyjoin)
library(scales)
library(bslib)
library(shinyWidgets)
library(ggrepel)

#if you do not have the saved shapefiles already, run 
#source(here("scripts","00_shapefiles.R"))
source(here("scripts","03_google_trends_data_setup.R"))
source(here("scripts","04_NPS_irma_data_setup.R"))
source(here("scripts","05_data_analysis_visitation.R"))

#list of names for visual
visit_dict <- c(
  "park density (parks per sq km)" = "park_density",
  "visits per park" = "visit_p_park",
  "combined vistation score" = "visit_score"
)

# Define UI
ui <- fluidPage(
  navset_tab(
    nav_panel("States comparison",
      fluidRow(
        column(12,div(style = "height:15px; font-size:20px;",
                      "U.S. National Parks: interest and visitation by state and season"))),
      fluidRow(
                column(12, div(style = "height:35px;font-size:25px;","    "))),
      fluidRow(
        column(1," "),
        column(3, div(style = "height:30px;font-size:20px;",
                       " ")),
        column(4,
                       sliderTextInput("selected_season", "Select time period:", 
                              choices = unique(GTrelative_df$season),
                              selected = unique(GTrelative_df$season)[1], 
                              animate = TRUE)),
                column(4, " ")),
      fluidRow(column(1," "),
               column(10, div(style = "height:25px;font-size:15px;",
                              " ")),
                column(1, " ")),
      fluidRow(
                column(1, " "),
                column(5, div(style = "height:35px;font-size:20px;",
                              "Visitation by state  ")),
                column(5, " ")),
      fluidRow(column(1, " "),
                column(5,
                      selectInput("visit_var", "Choose a visitation metric:", 
                                  choices = visit_dict, # Dropdown for column
                                  selected = "visit_p_park")),
                column(5, " ")),
      fluidRow(column(1, " "),
               column(5, div(style = "height:15px;font-size:12px;",
                             "*see Reference tab for metric descriptions")),
               column(5, " ")),
      fluidRow(
                column(1," "),
               column(2,plotOutput("mapPlot_akhi_visit")),
              column(9,plotOutput("mapPlot_48_visit"))),
      fluidRow(
        column(12, div(style = "height:25px;font-size:15px;",
                       " "))),
      fluidRow(column(1," "),
               column(10, div(style = "height:25px;font-size:20px;",
                              "Interest (Google search) trends by state")),
               column(1, " ")),
      fluidRow(
                column(1," "),
                column(2,plotOutput("mapPlot_akhi_interest")),
                column(9,plotOutput("mapPlot_48_interest"))
                )
),
    nav_panel("Timeseries", 
              fluidRow(
                column(12,div(style = "height:15px; font-size:20px;",
                              "U.S. National Parks: interest and visitation over time"))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:20px;","    "))),
              fluidRow(
                column(1," "),
                column(5,
                selectInput("selected_state", "Select state for time series:", 
                      choices = c("", sort(unique(GTtime_df$state))),
                      selected = "")),
                column(5,
                       selectInput("visit_var", "Choose a visitation metric:", 
                                   choices = visit_dict, # Dropdown for column
                                   selected = "visit_p_park")),
                column(1, " ")),
              fluidRow(column(6, " "),
                       column(5, div(style = "height:10px;font-size:12px;",
                                     "*see Reference tab for metric descriptions")),
                       column(1, " ")),
              fluidRow(
                column(12, div(style = "height:10px;font-size:10px;","    "))),
              fluidRow(
                plotOutput("visitation_timeSeriesPlot")
              ),
              fluidRow(
                plotOutput("interest_timeSeriesPlot")
                ),
              fluidRow(
                plotOutput("ratio_timeSeriesPlot")
              )
              ),
    nav_panel("Insights", 
              fluidRow(
                column(12,div(style = "height:15px; font-size:20px;",
                              "Simple analysis of U.S. National Parks interest and visitation over time"))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:20px;","    "))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:16px;",
                               "Discrepancies between interest and visitation: "))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:13px;","
                               which states have high interest but low visitation?"))),
              fluidRow(
                column(12, div(style = "height:10px;font-size:10px;","    "))),
              fluidRow(
                column(1, " "),
                column(10,
                       plotOutput("plot_ratio_all", height = "600px")),
                column(1, " ")),
              fluidRow(
                column(12, div(style = "height:30px;font-size:20px;","    "))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:13px;","
                               The outliers here seem to be New Jersey and Rhode Island in 2020. Lets explore their time series"))),
              fluidRow(
                column(1, " "),
                column(10,
                       plotOutput("plot_ratio_outlier")),
                column(1, " ")),
              fluidRow(
                column(12, div(style = "height:30px;font-size:20px;","    "))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:13px;","
                               It appears that these discrepancies might be due to April and May 2020 and December 2020 in Rhode Island when they had no visits."))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:20px;","    "))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:13px;","
                              Now lets look at the data without these two outlier dates to identify states there seems to be
                               a consistently higher interest than visitation in National Parks."))),
              fluidRow(
                column(1, " "),
                column(10,
                       plotOutput("highlight_ratio_plot",height="600px")),
                column(1, " ")),
              fluidRow(
                column(12, div(style = "height:30px;font-size:16px;",
                               "Do states with higher search interest in national parks also have higher visitation?"))),
              fluidRow(
                column(12, div(style = "height:30px;font-size:13px;","
                               At a glance, there doesn't seem to be a correlation at the state level"))),
              fluidRow(
                column(12, div(style = "height:10px;font-size:10px;","    "))),
              fluidRow(
                column(10,
                       plotOutput("spearman_plot")),
                column(2, " ")),
              fluidRow(
                column(1," "),
                column(10, div(style = "height:30px;font-size:13px;","
                               The correlation estimate is 0.41, p-value < 0.005")),
                column(1, " ")),
              fluidRow(
                column(4," "),
                column(4, div(style = "height:30px;font-size:15px;","
                               stay tuned for more!")),
                column(4, " ")),
              ),
    nav_panel("Reference",
              fluidRow(
                column(12, div(style = "height:35px;font-size:25px;","    "))),
            fluidRow(
              column(1," "),
              column(10,"The state comparison shows search interest in national parks across different states aggregated by the selected time period. 
              These values are normalized on a scale of 0 to 100, relative to the state with the highest search interest. 
              The state time series show relative search interest where each value represents interest relative to the 
               highest point on the chart between 2019-2025. For more information, visit <https://trends.google.com/>."),
              column(1, " ")),
          fluidRow(
              column(12, div(style = "height:35px;font-size:25px;","    "))),
          fluidRow(
              column(1," "),
              column(10,"The park visitation score is calculated as : Score = (park density + visits per park)/2, 
              where park density = number of parks per state / total state land (in sq. km), and visits per park is the total
              number of visits for each state divided by the number of parks in that state."),
              column(1, " ")),
fluidRow(
  column(1," "),
  column(10,"The park visitation data was sourced from IRMA Database for NPS Visitation: https://irma.nps.gov/"),
  column(1, " ")))
        ))

# Define server logic
server <- function(input, output, session) {
  
  Sfiltered_data_interest <- reactive({
    GTrelative_df %>%
      filter(season == input$selected_season)
  })
  
  Sfiltered_data_visit <- reactive({
    nps_visit_adj %>%
      filter(season == input$selected_season &
               visit_metric == input$visit_var) %>% 
      drop_na()
  }) 
  
  TSstate_v_data  <- reactive({
    nps_visit_adj %>%
      filter(state == input$selected_state &
               visit_metric == input$visit_var) 
    })
  

  selected_state <- reactiveVal(NULL)
  
  output$mapPlot_48_interest <- renderPlot({
    # Merge data for each region
    lower_48_map_i <- l48_shp %>%
      left_join(Sfiltered_data_interest(), by = "state")
    
    # standardize range
    interest_range <- range(Sfiltered_data_interest()$interest, na.rm = TRUE)
    
    # Create individual maps
    p  <- ggplot() +
      geom_sf(data = lower_48_map_i, aes(fill = interest), color = "black") +
      scale_fill_viridis_c(option = "magma", name = "Interest", limits = interest_range,
                           breaks = c(0, 50, 100)) +
      theme_void() +
      theme(plot.title = element_text(size = 18),
            legend.title = element_text(size=15, margin = margin(b = 10)),
            legend.text = element_text(size=15),
            legend.key.size = unit(1.5, "cm"))

    return(p)
  })
    
  output$mapPlot_akhi_interest <- renderPlot({
      # Merge data for each region
      alaska_map_i <- ak_shp %>%
        left_join(Sfiltered_data_interest(), by = "state")
      
      hawaii_map_i <- hi_shp %>%
        left_join(Sfiltered_data_interest(), by = "state")
      
      # standardize range
      interest_range <- range(Sfiltered_data_interest()$interest, na.rm = TRUE)
      
      akp <- ggplot() +
        geom_sf(data = alaska_map_i, aes(fill = interest), color = "black") +
        scale_fill_viridis_c(option = "magma", guide = "none", limits = interest_range)  +  # No legend for AK
        theme_void() +
        theme(plot.title = element_text(size = 18))
      
      hip <- ggplot() +
        geom_sf(data = hawaii_map_i, aes(fill = interest), color = "black") +
        scale_fill_viridis_c(option = "magma", guide = "none", limits = interest_range) +  # No legend for HI
        theme_void() +
        theme(plot.title = element_text(size = 18))
      
      plot_grid(akp, hip, ncol = 1, rel_heights = c(1, .8))

  })
  
  output$mapPlot_48_visit <- renderPlot({
    # Merge data for each region
    lower_48_map_v <- l48_shp %>%
      left_join(Sfiltered_data_visit(), by = "state")
    
    # standardize range
    visit_range <- range(Sfiltered_data_visit()$visit_value, na.rm = TRUE)
    
    # Create individual maps
    pv  <- ggplot() +
      geom_sf(data = lower_48_map_v, aes(fill = visit_value), color = "black") +
      scale_fill_viridis_c(name = names(visit_dict)[visit_dict == input$visit_var], 
                           limits = visit_range) +
      theme_void() +
      theme(plot.title = element_text(size = 18),
            legend.title = element_text(size=15, margin = margin(b = 10)),
            legend.text = element_text(size=15),
            legend.key.size = unit(1.5, "cm"))
    
    return(pv)
  })
  
  output$mapPlot_akhi_visit <- renderPlot({
    # Merge data for each region
    alaska_map_v <- ak_shp %>%
      left_join(Sfiltered_data_visit(), by ="state")
    
    hawaii_map_v <- hi_shp %>%
      left_join(Sfiltered_data_visit(), by = "state")
    
    # standardize range
    visit_range <- range(Sfiltered_data_visit()$visit_value, na.rm = TRUE)
    
    akpv <- ggplot() +
      geom_sf(data = alaska_map_v, aes(fill = visit_value), color = "black") +
      scale_fill_viridis_c(guide = "none", limits = visit_range)  +  # No legend for AK
      theme_void() +
      theme(plot.title = element_text(size = 18))
    
    hipv <- ggplot() +
      geom_sf(data = hawaii_map_v, aes(fill = visit_value), color = "black") +
      scale_fill_viridis_c(guide = "none", limits = visit_range) +  # No legend for HI
      theme_void() +
      theme(plot.title = element_text(size = 18))
    
    plot_grid(akpv, hipv, ncol = 1, rel_heights = c(1, .8))
    
  })

  output$interest_timeSeriesPlot <- renderPlot({

    if (input$selected_state == "") {

      return(ggplot(GTtime_df, aes(x = date, y = interest)) +
             #  geom_line(size=3, color="darkblue") +
               geom_smooth(stat="smooth", size=3, color="darkblue")+
               ggtitle(paste("average relative interest over time (all states)",input$selected_state)) +
               theme_classic()+
               xlab("") + ylab("relative interest")+
              # scale_x_date(labels = scales::date_format("%b %Y"), breaks = "3 months")+
               theme(
                 plot.title = element_text(size = 18, 
                                           face = "bold", hjust = 0.5),
                 axis.title = element_text(size=18),
                 axis.text = element_text(size=18),
                 axis.ticks = element_blank() 
               ))
    }
    
    GTstate_data <- GTtime_df %>%
      filter(state == input$selected_state)
    
    if(nrow(GTstate_data) > 0) {
     ggplot(GTstate_data, aes(x = date, y = interest)) +
        geom_line(size=3, color="darkblue") +
        ggtitle(paste("relative interest over time for ",input$selected_state)) +
        theme_classic()+
        xlab("") + ylab("relative interest")+
       # scale_x_date(labels = scales::date_format("%b %Y"), breaks = "3 months")+
        theme(
          plot.title = element_text(size = 18, 
                                    face = "bold", hjust = 0.5),
          axis.title = element_text(size=18),
          axis.text = element_text(size=18),
          axis.ticks = element_blank() 
        )
    } else {
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                 label = paste("No time series data available for", input$selected_state)) +
        theme_void() +
        xlim(0, 1) + ylim(0, 1)
    }
  })
  
  
  output$visitation_timeSeriesPlot <- renderPlot({
    
    if (input$selected_state == "") {
      mean_visit <- nps_visit_adj %>% group_by(date) %>% 
        filter(visit_metric == "visit_p_park") %>% 
        summarise(avg_visit= mean(visit_value), sd_visit = sd(visit_value))
      
      return(ggplot(mean_visit, aes(x = date, y = avg_visit)) +
               #  geom_line(size=3, color="darkblue") +
               geom_smooth(stat="smooth", size=3, color="darkgreen")+
               ggtitle("average visits per park over time (all states)") +
               theme_classic()+
               xlab("") + ylab("visits per park")+
             #  scale_x_date(labels = scales::date_format("%b %Y"), breaks = "3 months")+
               theme(
                 plot.title = element_text(size = 18, 
                                           face = "bold", hjust = 0.5),
                 axis.title = element_text(size=18),
                 axis.text = element_text(size=18),
                 axis.ticks = element_blank() 
               ))
    }
    
    TSstate_v_data <- TSstate_v_data() 
    
    if(nrow(TSstate_v_data) > 0) {
      ggplot(TSstate_v_data, aes(x = date, y = visit_value)) +
        geom_line(size=3, color="darkgreen") +
        ggtitle(paste("visitation over time for ",input$selected_state)) +
        theme_classic()+
        xlab("") + ylab(paste(names(visit_dict)[visit_dict == input$visit_var]))+
       # scale_x_date(labels = scales::date_format("%b %Y"), breaks = "3 months")+
        theme(
          plot.title = element_text(size = 18, 
                                    face = "bold", hjust = 0.5),
          axis.title = element_text(size=18),
          axis.text = element_text(size=18),
          axis.ticks = element_blank() 
        )
    } else {
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, 
                 label = paste("No time series data available for", input$selected_state)) +
        theme_void() +
        xlim(0, 1) + ylim(0, 1)
    }
  })

    output$spearman_plot <- renderPlot({
      return(spearman_plot)})
    
    output$plot_ratio_all <- renderPlot({
      return(plot_ratio_all)}, height=600)
    
    output$plot_ratio_outlier <- renderPlot({
      return(plot_ratio_outlier)})
    
    output$highlight_ratio_plot <- renderPlot({
      return(highlights_ratio_plot)}, height=600)
    
output$ratio_timeSeriesPlot <- renderPlot({
      
      if (input$selected_state == "") {

        return(ggplot() +
                 annotate("text", x = 0.5, y = 0.5, 
                          label = paste("Select state to view timeseries")) +
                 theme_void() +
                 xlim(0, 1) + ylim(0, 1))
      }
      
      Ratiostate_data <- nps_analysis_iv_ratio %>%
        filter(state == input$selected_state)
      
      if(nrow(Ratiostate_data) > 0) {
        ggplot(Ratiostate_data, aes(x = date, y = ratio)) +
          geom_line(size=3, color="purple4") +
          ggtitle(paste("interest vs visitation over time for ",input$selected_state)) +
          theme_classic()+
          xlab("") + ylab("interest / visitation")+
          # scale_x_date(labels = scales::date_format("%b %Y"), breaks = "3 months")+
          theme(
            plot.title = element_text(size = 18, 
                                      face = "bold", hjust = 0.5),
            axis.title = element_text(size=18),
            axis.text = element_text(size=18),
            axis.ticks = element_blank() 
          )
      } else {
        ggplot() +
          annotate("text", x = 0.5, y = 0.5, 
                   label = paste("No time series data available for", input$selected_state)) +
          theme_void() +
          xlim(0, 1) + ylim(0, 1)
      }
    })
    
    
}
# Run the application 
shinyApp(ui = ui, server = server)