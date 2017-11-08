#######################################################################
## This R script is a sample code that demonstrate how to extract projects' data from a BIM 360 Account using Autodesk Forge APIs.
#####################################################################

# Define Forge App Client ID and Secret and BIM 360 Account ID 
App_Client_ID <- "Input Autodesk Forge App Client ID here"
App_Client_Secret <- "Input Autodesk Forge App Secret ID here"
BIM360_Account_ID <- "Input Autodesk BIM 360 Account ID here"

#Load libraries required for the R script
library(httr)
library(jsonlite)

#Use Forge Authentication API to get access token
App_Authenticate <- POST("https://developer.api.autodesk.com/authentication/v1/authenticate",
                 add_headers("Content-Type" = "application/x-www-form-urlencoded"),
                 body=I(list(client_id = App_Client_ID,
                             client_secret = App_Client_Secret,
                             grant_type = "client_credentials",
                             "scope" = "account:read")),
                 encode = "form")
Access_Token <- paste("Bearer", content(App_Authenticate)$access_token,  sep=" ")

#Use Forge BIM 360 API to get BIM 360 Project Data
Get_Projects_URL <- paste("https://developer.api.autodesk.com/hq/v1/accounts/",
                          BIM360_Account_ID,
                          "/projects?limit=100", sep="")
Get_Projects_Request <- GET(Get_Projects_URL, add_headers("Authorization" = Access_Token))
Get_Projects_Data <- jsonlite::fromJSON(content(Get_Projects_Request, "text", "application/json", "UTF-8"))
i <- 0
while (is.integer(nrow(Get_Projects_Data)) != FALSE) {
  i <- i + 100
  Get_Projects_URL <- paste("https://developer.api.autodesk.com/hq/v1/accounts/",
                            BIM360_Account_ID,
                            "/projects?limit=100&offset=",
                            toString(i), sep="")
  Get_Projects_Request <- GET(Get_Projects_URL, add_headers("Authorization" = Access_Token))
  if (i > 100) {Get_Projects_Data <- BIM360_Project_Data}
  Get_Projects_Next <- jsonlite::fromJSON(content(Get_Projects_Request, "text", "application/json", "UTF-8"))
  BIM360_Project_Data <- rbind(Get_Projects_Data, Get_Projects_Next)
  Get_Projects_Data <- Get_Projects_Next
}

# Clear Variables
rm(i, Access_Token,
   App_Client_ID,
   App_Client_Secret,
   App_Authenticate,
   BIM360_Account_ID,
   Get_Projects_Data, 
   Get_Projects_Next,
   Get_Projects_URL,
   Get_Projects_Request
   )