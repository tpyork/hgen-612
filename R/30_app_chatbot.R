# CREATED: 2026-04-20
# BASIC SHINYCHAT APP POWERED BY ELLMER



# ACCESS INTRUCTIONS ----
# To run this example, you’ll first need to create an OpenAI API key, and set it in your
# environment as OPENAI_API_KEY.
# usethis::edit_r_environ()

# Note that a ChatGPT Plus membership does not grant access to the API. You will need to sign up
# for a developer account (and pay for it) at the developer platform.



# LIBRARIES ----
library(shiny)
library(shinychat)
library(ellmer)



# SHINY APP ----
# User Interface
ui <- bslib::page_fillable(
  chat_ui(id              = "chat",
          messages        = "**Hello!** How can I help you today?",
          fillable_mobile = TRUE)
)


# Server-Side
server <- function(input, output, session) {
  # Initialize the model backend
  chat <- ellmer::chat_openai(
    system_prompt = "You are a helpful assistant.",
    model = "gpt-4.1-nano"  #"gpt-4.1"
    )
  
  # Handle input and stream response
  observeEvent(input$chat_user_input, {
    stream <- chat$stream_async(input$chat_user_input)
    chat_append("chat", stream)
  })
}

shinyApp(ui, server)



# token_usage()