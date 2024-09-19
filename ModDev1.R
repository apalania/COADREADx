library(caret)
library(Boruta)
library(randomForest)
train.index <- createDataPartition(Data$Type, p = .8, list = FALSE)
train <- Data[train.index,]
test <- Data[-train.index,]
boruta_output <- Boruta(train$Type ~ ., data=na.omit(train[,1:184]), doTrace=2)
boruta_signif1 <- names(boruta_output$finalDecision[boruta_output$finalDecision %in% c("Confirmed")])
print(boruta_signif)
control <- rfeControl(functions=rfFuncs, method="cv", number=10)
results <- rfe(train[,1:184], train$Type, sizes=c(1:70), rfeControl=control)
View(boruta_output)
predictors(results)->feature_selected
intersect(feature_selected,boruta_signif1)
train[,colnames(train)%in%feature_selected]->train_f
test[,colnames(test)%in%feature_selected]->test_f
cbind(train_f,train$Type)->train_f
cbind(test_f,test$Type)->test_f
train_for_rf <- train_f
control <- trainControl(method = "repeatedcv",number = 10,repeats= 3,search="grid")
mtry <- sqrt(ncol(train_for_rf))
tunegrid <- expand.grid(.mtry=mtry)
model_1 <- caret::train(Type~.,data=train_for_rf,method="rf",tuneGrid=tunegrid,trControl=control)
summary(model_1)
plot(varImp(model_1), main="Variable importance: model_1")
train_for_rf$pred <- predict(model_1,train_for_rf)
caret::confusionMatrix(data= train_for_rf$pred, reference = train_for_rf$Type)
test_for_rf <- test_f
yhat_rf <- predict(model_1,test_for_rf)
caret::confusionMatrix(data= yhat_rf, reference = test_for_rf$Type)
saveRDS(model_1,file = "model_rf.rds")
Data[,colnames(Data)%in%feature_selected]->Data_f
cbind(Data_f,Data$Type)->Data_f
Whole <- Data_f
control <- trainControl(method = "repeatedcv", number = 10,repeats= 3,search="grid")
tuneGrid <- expand.grid(mtry = 2.83, ntree = 500)
model_Whole <- caret::train(Type~.,data=Data_f,method="rf",tuneGrid=tunegrid,trControl=control)
saveRDS(model_Whole,file = "Screening_Model.rds")
