# Project 2

## Data Science 2

## HGEN 612

<br>

### Assignment Summary

Create a data product that incorporates reactive Shiny components to provide users a dynamic experience with a classification-based machine learning model. Imagine that the purpose of this application is to allow your colleagues to inspect for themselves how a range of parameter and data adjustments might influence prediction results. A draft of dashboard will be presented to the class to provide a summary of the modeling objective, the modeling strategy, and a brief overview of the data.


### Qualifying Datasets

Use any single dataset that contains:  

- A binary outcome (or variable that can be reasonably coerced to binary).
- A minimum of 100 observations (rows).
- At least 10 reasonable predictors (columns).
- At least one predictor with a numeric attribute.
- At least one predictor with a factor attribute.
- You *cannot* use any dataset presented as an example during a lecture.
- Avoid massive datasets that require long loading and model estimation times.
- Requests for exceptions can be made to `@tpyork` on Slack.


### Shiny Components

- Use a at least 2 Shiny components.
- At least 1 Shiny component should be reactive with a model parameter.
- At least 1 Shiny component should be reactive with the data supplied to the model.
- Do not confuse Shiny components with HTML widgets (but you can use HTML widgets).


### Presentation

- You will have 5 minutes to provide a brief overview of your draft dashboard along with 5 minutes to respond to questions/comments from the class.
- The class may provide additional feedback on the `#general` Slack channel (not Zoom chat). Use `@user` to specify project.
- Use no slides. You will be expected to share your draft dashboard on Zoom.
- Be thoughtful about where you need feedback.
- Practice your 5 minute presentation. Dr. York will cut you off exactly at 5 minutes for class feedback :)
- You are allowed to incorporate any suggestions provided by the class.
- Incorporate at least one reactive element (even if not successful).


### Grading

Your data product should include the following [100 total points]:

-   [05] The app should be a designed as a flexdashboard and rendered as a Shiny app. 
-   [15] Include at least 2 Shiny components.
-   [05] Include 6-10 display items.
-   [05] Apply at least one machine learning classification method.
-   [05] Demonstrate the proper use of training / testing data.
-   [05] Model specification should be done in the tidymodels framework.
-   [05] Feature engineer the data as applicable using `step_x` functions.
-   [05] Use a recipe.
-   [05] Use a tidymodels workflow.
-   [05] Provide an evaluation of your model(s).
-   [05] Include the confusion matrix.
-   [05] At least 1 display item should showcase the data.
-   [05] At least 1 display item should showcase the predictors used in the model.
-   [05] At least 1 display item should showcase model results.
-   [05] Embed the code or link out to source code within the app.
-   [05] Aesthetics (i.e., start with a good theme).
-   [05] Creativity.
-   [05] Publish the app to shinyapps.io and send link to Dr. York and the TA as a direct message in Slack.

<br>

Your presentation should observe the following [15 points]:

-   [01] Efficient use of allotted time.
-   [02] Explain the modeling objective/problem. 
-   [03] Showcase the outcome and predictors.
-   [03] Describe how you plan to utilize Shiny.
-   [01] Solicit feedback, be evocative.
-   [05] Test drive your reactive element.


### Notes

-   Late assignments will not be accepted.
-   I suggest reviewing all code and presentations before beginning assignment. Don't forget all the great resources at https://rmarkdown.rstudio.com/flexdashboard/index.html
-   All work should be done independently. You can use web resources (e.g., Stack Overflow).
-   You can ask coding questions to the class on the #hgen-612 channel (e.g., "can anyone help debug this code snippet.." ).
-   Limit the amount of textual descriptions so that they do not overcrowd the display.
-   Text related to model output (e.g., from `broom`) is not considered a textual description, though it should be appropriately tidied.
-   Each display item should include a title and/or subtitle that indicates its purpose and, as applicable, the take-home message.
-   Be creative but remember your audience. i.e., do not use extraneous colors in graphs.
-   Feel free to explore all that Shiny components and HTML widgets have to offer (e.g., Plotly).


