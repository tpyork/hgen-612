# CREATED: 2026-04-20
# COURSE SHINYCHAT WITH CONTEXT

# ACCESS INTRUCTIONS ----
# To run this example, you’ll first need to create an OpenAI API key, and set it in your
# environment as OPENAI_API_KEY.
# usethis::edit_r_environ()

# Note that a ChatGPT Plus membership does not grant access to the API. You will need to sign up
# for a developer account (and pay for it) at the developer platform.



# LIBRARIES ----
library(dotenv)
library(shiny)
library(shinychat)
library(ellmer)
library(bslib)


# LOAD PROMPT DATA ----
doc1 <- paste(readLines("../course-info/hgen-612_syllabus.md"), collapse = "\n")
doc2 <- paste(readLines("../course-info/hgen-612_lecture-schedule.md"), collapse = "\n")
doc3 <- paste(readLines("../assignments/project-1.md"), collapse = "\n")
doc4 <- paste(readLines("../assignments/project-2.md"), collapse = "\n")
doc5 <- paste(readLines("../assignments/project-3.md"), collapse = "\n")

prompt <- paste(
  c("You are an assistant that helps students understand expectation for the graduate course, Data Science 2."),
  "\n\n---\n\n",  # Markdown horizontal rule
  doc1,
  "\n\n---\n\n", 
  doc2,
  "\n\n---\n\n",  
  doc3,
  "\n\n---\n\n",  
  doc4,
  "\n\n---\n\n", 
  doc5
)


# SHINY APP ----
ui <- page_fluid(
  class = "pt-5",
  tags$style("a:not(:hover) { text-decoration: none; }"),
  chat_ui("chat")
)

server <- function(input, output, session) {
  chat <- chat_openai(model = "gpt-4.1-nano", system_prompt = prompt)
  # chat <- chat_claude(model = "claude-3-5-sonnet-latest", system_prompt = prompt)
  observeEvent(input$chat_user_input, {
    chat_append("chat", chat$stream_async(input$chat_user_input))
  })
  chat_append("chat", "👋 Hi, I'm **DS-612 Assistant**! I'm here to answer questions about your HGEN 612 course")
}

shinyApp(ui, server)


# token_usage()
