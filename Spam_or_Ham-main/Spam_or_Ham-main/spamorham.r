# Load necessary libraries
install.packages("caret")

library(tm)

library(caret)

# Step 1: Read the dataset
data <- read.csv("C://Users//Koushik//Desktop//catalog//spam.csv", encoding = "ISO-8859-1")

# Keep only the relevant columns
data <- data[, c("v1", "v2")]
data <- data[sample(nrow(data), 100), ]

# Rename columns for clarity
colnames(data) <- c("Label", "Text")

# Convert the Label to a factor
data$Label <- as.factor(data$Label)


Sys.setlocale("LC_ALL", "C")

# Convert the text to UTF-8 encoding
data$Text <- iconv(data$Text, from = "latin1", to = "UTF-8")

# Step 2: Preprocess and split the data
corpus <- VCorpus(VectorSource(data$Text))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, stripWhitespace)

dtm <- DocumentTermMatrix(corpus)
data_matrix <- as.matrix(dtm)
data_labels <- data$Label

# Split the dataset
set.seed(123) # for reproducibility
trainIndex <- createDataPartition(data_labels, p = .8, list = FALSE)
X_train <- data_matrix[trainIndex, ]
Y_train <- data_labels[trainIndex]
X_test <- data_matrix[-trainIndex, ]
Y_test <- data_labels[-trainIndex]

# Convert the data matrix to a data frame for glm
X_train_df <- as.data.frame(X_train)
X_test_df <- as.data.frame(X_test)

# Convert factor levels to binary 0 and 1 for logistic regression
Y_train_binary <- ifelse(Y_train == "spam", 1, 0)
Y_test_binary <- ifelse(Y_test == "spam", 1, 0)

# Step 3: Train a Logistic Regression model
model <- glm(Y_train_binary ~ ., data = X_train_df, family = "binomial")

# Step 4: Create a prediction function
predict_spam <- function(new_subject) {
}
predicted_labels <- ifelse(predict(model, X_test_df, type = "response") > 0.5, "spam", "ham")

accuracy <- sum(predicted_labels == Y_test) / length(Y_test)
print(paste("Accuracy:", accuracy))

predicted_train_labels <- ifelse(predict(model, X_train_df, type = "response") > 0.5, "spam", "ham")

train_accuracy <- sum(predicted_train_labels == Y_train) / length(Y_train)

print(paste("Training Accuracy:", train_accuracy))

