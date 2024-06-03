library(shiny)
#library(ClusterR)
library(DT)
library(tidyverse)
library(factoextra)
library(ggplot2)
library(googledrive)
library(googlesheets4)
library(caret)
library(shinythemes)
library(shinycssloaders)
library(shinydashboard)
library(randomForest)
options(shiny.maxRequestSize = 1000*1024^2)
options(
  # whenever there is one account token found, use the cached token
  gargle_oauth_email = "waterfallsangee@gmail.com",
  # specify auth tokens should be stored in a hidden directory ".secrets"
  gargle_oauth_cache = ".secrets"
)
  ui <- fluidPage(    
    #theme = shinytheme("cerulean"),
    # Give the page a title
     titlePanel(fluidRow( column(8, h1("COADREADx: Predictive screening and differentiation of colorectal cancer based on gene expression biomarkers
")), column(3, offset = 1, img(height = 105, width = 300, src = "SASTRA.png"))),windowTitle = "Predictive screening of colorectal cancer" ),
    
    # Generate a row with a sidebar
    navbarPage( "", collapsible = TRUE, inverse = TRUE, theme = shinytheme('readable'),
      tabPanel("Screening Model",
      # Define the sidebar with one input
      sidebarPanel(
        width = 3,
        helpText(h2(strong("README")), style="text-align:center"),
        helpText("Single instance or Batch-input prediction mode"),
        helpText("Make sure that the CSV header fields contains the sequence of names of the Biomarkers -- uppercase, HGNC names"),
        helpText("Rows are Sample-wise expression values for each biomarker"),
        helpText("For risk-stratification of the patient, please navigate to the next tab"),
        ),
      
      sidebarPanel(
        width = 3,
        selectInput("Samples", "Prediction mode:", 
                    choices=c("Single", "Batch")),
        selectInput("cancertype", "Cancer Type:", 
                    choices=c("COADREAD")),
        selectInput("Transformation", label = HTML(paste0("Log",tags$sub("2"), " ", "transformed?")), 
                    choices=c("Yes","No")),
        fileInput("csv_input","Select CSV File to Import",accept=".csv"),
        helpText("NOTE: Make sure that the expression data for all the biomarkers are present in your input, else 'ERROR' will result."),
        actionButton("execute", label = "Submit"),
        hr(),
        selectInput("SampleDatasets", "Sample Datasets", 
                    choices=c("", "Single1" , "Single2" , "Batch")),
        hr(),
        #tags$head(includeHTML(("Google-analytics.html"))),
        tags$head(tags$style(".shiny-output-error{visibility: hidden}")),
        
        tags$head(tags$style(".shiny-output-error:after{content: 'Invalid. Please read the information and try again'; visibility: visible}")), 
        uiOutput("download"),
        ),
      mainPanel(uiOutput("Plotorprint"),uiOutput("sentence"), uiOutput("Text"), helpText(strong("Prediction probabilities provide an estimate of uncertainty of the prediction.")), helpText(strong("Suggested interpretation of the strength of evidence:")), helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'), "Probability > 0.85: High confidence"),helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),"Probability between 0.70 and 0.85: High - Moderate"), helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),"Probability between 0.60 and 0.70: Moderate - Low"),helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),"Probability < 0.60: Low confidence"), HTML("<p><br> <b>Please find the HELP document and video in the ‘About’ tab <br> Citing us: </b> <br> Ashok Palaniappan, Sangeetha Muthamilselvan, Arjun Sarathi, COADREADx: A comprehensive algorithmic dissection unravels salient biomarkers and concrete insights into the discrete progression of colorectal cancer [Submitted] <br> For academic and non-commercial use only. For other purposes, please contact the corresponding author. </p>"),width = 6,
      tags$head(
        tags$style(
          HTML(
          ".form-control {
          border-radius: 4px 4px 4px 4px;
          }
         #text {
          font-size: 24px;
          }
          #predict {
          font-size: 34px;
          }
          "
          )))
     ),
          #hr(),
     tags$footer( h5(textOutput("counter")), align="left", style="position:absolute; bottom:0; width:95%; height:50px; color: #000000; padding: 0px; background-color: transparent; z-index: 1000;")
      ),
     tabPanel("Risk Stratification", 
              sidebarPanel(
                width = 3,
                helpText(h2(strong("README")), style="text-align:center"),
                helpText(HTML(paste0("Expression values of the biomarkers in the prognostic signature may be given, with or without Log",tags$sub("2"), "-","transformation"))),
              ),
              
              sidebarPanel(
                width = 3,
                numericInput("HOTAIR","HOTAIR:",""),
                numericInput("GABRD","GABRD:",""),
                numericInput("DKK1","DKK1:",""),
                selectInput("transformation", label = HTML(paste0("Log",tags$sub("2"), " ", "transformed?")), 
                            choices=c("Yes","No")),
                helpText("CAUTION: Make sure that the expression data for all the biomarkers are present in your input, else 'ERROR' will result."),
                actionButton("execute1", label = "Submit"),
                hr(),
     ),  mainPanel( uiOutput("sentence1"), uiOutput("Text1"), uiOutput("sentence2"), uiOutput("Text2"), helpText(strong("Suggested interpretation of the strength of evidence:")), helpText(strong("Quantiles and fold-changes from the median value of the risk-scores provide an estimate of uncertainty in the predicted risk class.")),helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),strong("Low-risk implies quantile < 50%. Closer the quantile to zero, higher the level of confidence in the predicted class.")), helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),strong("Fold-change values range from 0 to 1, with larger values implying higher confidence in the predicted class.")), helpText(br()),helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),strong("High-risk implies quantile > 50%. Closer the quantile to 100, higher the level of confidence in the predicted class.")),helpText(HTML('&nbsp;','&nbsp;','&nbsp;','&nbsp;'),strong("Fold-change values range from 1 to infinity, with larger values implying higher confidence in the predicted class.")),width=6,
                    tags$head(
                      tags$style(
                        HTML(
                          ".form-control {
          border-radius: 4px 4px 4px 4px;
          }
         #text1 {
          font-size: 24px;
          }
          #predict1 {
          font-size: 34px;
          }
          #text2 {
          font-size: 24px;
          }
          #predict2 {
          font-size: 34px;
          }
          "
                        )))),
     ),tabPanel("About",icon= icon("house", class = NULL, lib = "font-awesome"),  mainPanel( HTML("<p>For more details and citation, please refer our manuscript:
                     <br>
                     Ashok Palaniappan*, Sangeetha Muthamilselvan, Arjun Sarathi. COADREADx: A comprehensive algorithmic dissection unravels salient biomarkers and concrete insights into the discrete progression of colorectal cancer [submitted]
                     <br> 
                      <a href=https://scbt.sastra.edu/images/sastra/Research_areas/System%20Computational%20Biology.pdf> Systems Computational Biology Lab, </a><br>Department of Bioinformatics,
                     <br>
                     School of Chemical and Biotechnology,<br>SASTRA Deemed University, Thanjavur - 613401. India
                     <br><br>
                     Academic, non-profit and non-commercial use only.
                     <br>
                     For any queries and/or commercial use please contact;
                     <br>
                     <a href=mailto:apalania@scbt.sastra.edu> Contact info </a> 
                    <br><br> 
                     For further usage details, please consult the HELP document:
                     <a href=APP_help.pdf> Help on Usage </a> 
                     <br><br> A video demo of the functionalities is also available:
                     <br> 
                     <iframe width=560, height=315, src= https://www.youtube.com/embed/T_OvhbK0Bnc , frameborder=0, allow=accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture allowfullscreen></iframe>
                     </p>  " ))),
     ))
server <- function(input, output) {
final<-reactive({W<-input$Samples
return(W)})
x<-reactive({
  req(input$csv_input)
  df_uploaded <- read.csv(input$csv_input$datapath)
  a<-data.frame(df_uploaded)
  return(a)
})
read_csv("final_prob.csv")->final_prob
read_csv("cancer.csv")->cancer
read_csv("control.csv")->control
read_csv("quantile.csv")->quantile
quantile$quantile->qx
#read_csv("test_untrans.csv")->Batch_untransformed
RF<-readRDS("model_rf_whole.rds")
Z<-reactive({y<-input$cancertype
if(y=="COADREAD")
  {z<-RF[["coefnames"]]}
  z<-as.vector(z)
  return(z)
})
Data<- reactive({b<-select(x(),Z())
b <- droplevels(b)
rownames(b)<-x()[,1]
if(input$Transformation== "No"){
    b <- log2(b+1)
}
else{
  b
}
return(b)})
pl<-reactive({if(final()=="Single")
{ 
  C<-reactive({
  c<-predict(RF,Data())
  c<- as.numeric(c)
  for(i in 1)
  {if(c[i]==1){
    c[i]<-"Cancer"}
    else
    {c[i]<-"Control"}}
  return(c)
})
text<-C()
}
else if(final()=="Batch")
{
  Out<-reactive({
    Class<-predict(RF,Data())
    Class<- as.numeric(Class)
    for (i in 1:length(Class))
    { if(Class[i]==1)
    {Class[i]<-"Cancer"}
      else
      {Class[i]<-"Control"}}
    Sample_id<-rownames(Data())
    Prediction<-cbind(Sample_id,Class)
    pred_prob<-predict(RF,Data(), type = "prob")
    score<-NULL
    for (i in 1:length(Class))
    {
      score[i]<-max(pred_prob[i,])
    }
    Prediction<-cbind(Prediction,signif(score,2))
    colnames(Prediction)[3]<-"Probability_score"
    rownames(Prediction)<-NULL
    return(Prediction)
  })
  out<-Out()
}
  })
prob<-reactive({
  if(final()=="Single"){
    C4<-reactive({
      prob<-predict(RF,Data(), type="prob")
      if(pl()=="Cancer"){
        prob_pred<-prob[,"Cancer"]
      } else
      {
        prob_pred<-prob[,"control"]
      }
      return(signif(prob_pred,2))
    })
    text4<-C4()
  }
})
val<-reactive({
  x<-as.numeric(input$HOTAIR)
  y<-as.numeric(input$GABRD)
  z<-as.numeric(input$DKK1)
  if(input$transformation== "No"){
    a<-0.14872*log2(x)+0.4432*log2(y)-0.10877*log2(z)
  }
  else{
    a<-0.14872*x+0.4423*y-0.10877*z}
  return(a)
})
risk<-reactive({if(val()>2.74022910 )
{text1<-"High-risk"} 
  else 
    text1<-"Low-risk"
  return(text1)})
names<-reactive({
  sum(val()>=qx)->z
  quantile$...1[z+1]->b
  return(b)})
diff<-reactive({
  signif((quantile$quantile[11]-abs(val()))/quantile$quantile[11],2)->c
  return(abs(c))})
output$console<-renderDataTable({pl()})
observeEvent(input$execute,output$Plotorprint <- renderUI({
  if (final()=="Batch") {  
  dataTableOutput("console")
  }
}))
output$text <- renderText({"The sample is predicted as"})
observeEvent(input$execute,output$sentence <- renderUI({
  if (final()=="Single") { 
    textOutput("text")
  }
}))
output$predict<-renderText({paste0(pl(),":"," with probability ",prob())})
observeEvent(input$execute,output$Text <- renderUI({
  if (final()=="Single") { 
    verbatimTextOutput("predict")
      }
}))
output$text1 <- renderText({"PREDICTED RISK CLASS"})
observeEvent(input$execute1,output$sentence1 <- renderUI({
  textOutput({ "text1"})
}))
output$predict1<-renderText({risk()})
observeEvent(input$execute1,output$Text1 <- renderUI({
  verbatimTextOutput("predict1")
}))
output$text2 <- renderText({"The RISK-SCORE is in "})
observeEvent(input$execute1,output$sentence2 <- renderUI({
  textOutput({ "text2"})
}))
output$predict2<-renderText({paste0(names()," quantile with a ", diff()," fold-change from the median value.")})
observeEvent(input$execute1,output$Text2 <- renderUI({
  verbatimTextOutput("predict2")
}))
output$download <- renderUI({
  if(input$Samples=="Batch" & !is.null(input$csv_input)) 
    {downloadButton('OutputFile', 'Download Output File')}
  else if (input$SampleDatasets=="Single1"&is.null(input$csv_input))
  {downloadButton('Cancer', 'Sample File')}
  else if (input$SampleDatasets=="Batch"&is.null(input$csv_input))
  {downloadButton('Batch', 'Sample File')}
  else if (input$SampleDatasets=="Single2"&is.null(input$csv_input))
  {downloadButton('Control', 'Sample File')}
})
output$OutputFile <- downloadHandler(
  filename = function () {
    paste("MyData.csv", sep = "")
    },
  content = function(file) {
          write.csv(pl(), file)
  })
output$Batch <- downloadHandler(
  filename = function () {
    paste("Batch_file.csv", sep = "")
  },
  content = function(file) {
    write.csv(final_prob, file, row.names = FALSE)
  }
)
output$Cancer <- downloadHandler(
  filename = function () {
    paste("Cancer.csv", sep = "")
  },
  content = function(file) {
    write.csv(cancer, file, row.names = FALSE)
  }
)
output$Control <- downloadHandler(
  filename = function () {
    paste("Control.csv", sep = "")
  },
  content = function(file) {
    write.csv(control, file,row.names = FALSE)
  }
)

output$counter <- 
  renderText({
    sheet_id <- drive_get("coadread")$id
    read_sheet(sheet_id)->x
    x$counter<-x$counter+1
    range_write(sheet_id, data = x, range = "A2",col_names = FALSE)
    paste("Number of Visitors since August 25, 2023: ", x$counter)
  })
}
options(shiny.sanitize.errors = TRUE)

shinyApp(ui = ui, server = server)


