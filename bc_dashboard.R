library(shiny)
library(ggplot2)
library(plyr)
library(dplyr)


# Data Preparation Steps

data <- read.csv("BC_data.csv")

data$Date <- strptime(as.character(data$Date.yyyy.MM.dd.),format="%m/%d/%Y")
data$Date <- as.POSIXct(data$Date)

data$DateTime <- strptime(as.character(data$DateTime),format="%m/%d/%Y %H:%M")
data$DateTime <- as.POSIXct(data$DateTime)

data$NumericDateTime <- as.numeric(data$DateTime)

data$Day <- as.numeric(as.character(strftime(data$DateTime,format="%d")))
data$Hour <- as.numeric(as.character(strftime(data$DateTime,format="%H")))

data <- data %>% filter(BC6!=0)





ui <- fluidPage(
  
  # App title ----
  titlePanel("Interactive dashboard Black cardon data analysis"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      selectInput(inputId = "color1", label = "Choose Color", choices = c("Purple" = "#800080", "Dark Blue" = "#00008B", "Red" = "#FF0000"), selected = "#00008B", multiple = FALSE),
      radioButtons(inputId = "border1", label = "Select Border", choices = c("Black" = "#000000", "White" = "#ffffff")),
      selectInput(inputId = "channel1", label = "Choose Channel", choices = c("BC1" = "BC1", "BC2" = "BC2", "BC3" = "BC3", "BC4" = "BC4", "BC5" = "BC5", "BC6" = "BC6", "BC7" = "BC7"), selected = "BC6", multiple = FALSE),
      sliderInput(inputId = "bins1xz", label = "Number of bins:", min = 1, max = 50, value = 30),
      sliderInput(inputId = "range1", label = "Data Range", min = 1, max = 31, value = c(1, 31))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "distPlot"),
      plotOutput(outputId = "distPlot1", brush = "plot_brush"),
      plotOutput(outputId = "distPlot3"),
      plotOutput(outputId = "distPlot2"),
      h2(textOutput(outputId = "plot_brush"),align="center")
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output){
  
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  
  output$distPlot <- renderPlot({
    
    sColor = input$color1
    
    p2 <- data %>%  filter(Day >= input$range1[1] & Day <= input$range1[2]) %>% ggplot()
    if(input$channel1 == "BC1"){
      p2 <- p2 + geom_histogram(aes(x=BC1),bins = input$bins1xz,col=input$border1,fill=sColor)
    }else if(input$channel1 == "BC2"){
      p2 <- p2 + geom_histogram(aes(x=BC2),bins = input$bins1xz,col=input$border1,fill=sColor)
    }else if(input$channel1 == "BC3"){
      p2 <- p2 + geom_histogram(aes(x=BC3),bins = input$bins1xz,col=input$border1,fill=sColor)
    }else if(input$channel1 == "BC4"){
      p2 <- p2 + geom_histogram(aes(x=BC4),bins = input$bins1xz,col=input$border1,fill=sColor)
    }else if(input$channel1 == "BC5"){
      p2 <- p2 + geom_histogram(aes(x=BC5),bins = input$bins1xz,col=input$border1,fill=sColor)
    }else if(input$channel1 == "BC6"){
      p2 <- p2 + geom_histogram(aes(x=BC6),bins = input$bins1xz,col=input$border1,fill=sColor)
    }else if(input$channel1 == "BC7"){
      p2 <- p2 + geom_histogram(aes(x=BC7),bins = input$bins1xz,col=input$border1,fill=sColor)
    }
    p2 <- p2 +  theme_bw()+
      theme(axis.title = element_text(size=12,color="BLACK",face="bold"),
            axis.text = element_text(size=14,color="BLACK",face="bold"))+
      labs(x="Black Carbon (ng/m3)",y="Count",title=paste("Black Carbon Concentration Histogram",input$channel1,sep = " "))
    
    p2
    #hist(x, breaks = bins, col = sColor, border = input$border1,
    #     xlab = "Waiting time to next eruption (in mins)",
    #     main = "Histogram of waiting times")
  })
  
  output$distPlot1 <- renderPlot({
    
    output$plot_click <- renderText({
      paste(input$plot_click$x,input$plot_click$y, sep=" ")
      
    })
    
    p1 <- data  %>%  filter(Day >= input$range1[1] & Day <= input$range1[2]) %>% ggplot(aes(x=DateTime))
    if(input$channel1 == "BC1"){
      p1 <- p1 + geom_line(aes(y=BC1,col="BC1"),size=0.5)
    }else
      if(input$channel1 == "BC2"){
        p1 <- p1 + geom_line(aes(y=BC2,col="BC2"),size=0.5)
      }else
        if(input$channel1 == "BC3"){
          p1 <- p1 + geom_line(aes(y=BC3,col="BC3"),size=0.5)
        }else
          if(input$channel1 == "BC4"){
            p1 <- p1 + geom_line(aes(y=BC4,col="BC4"),size=0.5)
          }else
            if(input$channel1 == "BC5"){
              p1 <- p1 + geom_line(aes(y=BC5,col="BC5"),size=0.5)
            }else
              if(input$channel1 == "BC6"){
                p1 <- p1 + geom_line(aes(y=BC6,col="BC6"),size=0.5)
              }else
                if(input$channel1 == "BC7"){
                  p1 <- p1 + geom_line(aes(y=BC7,col="BC7"),size=0.5)
                }
    p1 <- p1 +  theme_bw()+
      theme(axis.title = element_text(size=12,color="BLACK",face="bold"),
            axis.text = element_text(size=14,color="BLACK",face="bold"))+
      labs(x="Time",y="Black Carbon (ng/m3)",title="Black Carbon Concentration in Air - Dec, 2017",colour="Channel")
    
    p1
    
  })
  
  output$distPlot3 <- renderPlot({
    validate(
      need(input$plot_brush$xmin != "", "Please select a data range")
    )
    
    
    xmin <- input$plot_brush$xmin
    xmax <- input$plot_brush$xmax
    
    ymin <- input$plot_brush$ymin
    ymax <- input$plot_brush$ymax
    
    
    d1 <- data %>% filter(NumericDateTime >= xmin & NumericDateTime <= xmax)
    
    # if(input$channel1 == "BC1"){
    #   d1 <- d1 %>% filter(BC1 >= ymin & BC1 <= ymax)
    # }else if(input$channel1 == "BC2"){
    #   d1 <- d1 %>% filter(BC2 >= ymin & BC2 <= ymax)
    # }else if(input$channel1 == "BC3"){
    #   d1 <- d1 %>% filter(BC3 >= ymin & BC3 <= ymax)
    # }else if(input$channel1 == "BC4"){
    #   d1 <- d1 %>% filter(BC4 >= ymin & BC4 <= ymax)
    # }else if(input$channel1 == "BC5"){
    #   d1 <- d1 %>% filter(BC5 >= ymin & BC5 <= ymax)
    # }else if(input$channel1 == "BC6"){
    #   d1 <- d1 %>% filter(BC6 >= ymin & BC6 <= ymax)
    # }else if(input$channel1 == "BC7"){
    #   d1 <- d1 %>% filter(BC7 >= ymin & BC7 <= ymax)
    # }
    # 
    
    p1 <- d1  %>%  filter(Day >= input$range1[1] & Day <= input$range1[2]) %>% ggplot(aes(x=DateTime))
    if(input$channel1 == "BC1"){
      p1 <- p1 + geom_line(aes(y=BC1,col="BC1"),size=0.5)
    }else if(input$channel1 == "BC2"){
      p1 <- p1 + geom_line(aes(y=BC2,col="BC2"),size=0.5)
    }else if(input$channel1 == "BC3"){
      p1 <- p1 + geom_line(aes(y=BC3,col="BC3"),size=0.5)
    }else if(input$channel1 == "BC4"){
      p1 <- p1 + geom_line(aes(y=BC4,col="BC4"),size=0.5)
    }else if(input$channel1 == "BC5"){
      p1 <- p1 + geom_line(aes(y=BC5,col="BC5"),size=0.5)
    }else if(input$channel1 == "BC6"){
      p1 <- p1 + geom_line(aes(y=BC6,col="BC6"),size=0.5)
    }else if(input$channel1 == "BC7"){
      p1 <- p1 + geom_line(aes(y=BC7,col="BC7"),size=0.5)
    }
    p1 <- p1 +  theme_bw()+
      scale_y_continuous(limits = c(ymin,ymax))+
      theme(axis.title = element_text(size=12,color="BLACK",face="bold"),
            axis.text = element_text(size=14,color="BLACK",face="bold"))+
      labs(x="Time",y="Black Carbon (ng/m3)",title="Black Carbon Concentration in Air - Dec, 2017",colour="Channel")
    
    p1
    
    
  })
  
  
  
  
}

shinyApp(ui = ui, server = server,)


