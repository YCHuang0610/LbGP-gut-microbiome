#Package download mirror site
local({r <- getOption("repos")  
r["CRAN"] <- "http://mirrors.tuna.tsinghua.edu.cn/CRAN/"   
options(repos=r)}) 

# package list
package_list <- c("ggplot2","RColorBrewer","randomForest","caret", "pROC","dplyr","ggrepel")

# install
for(p in package_list){
  if(!suppressWarnings(suppressMessages(require(p, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)))){
    install.packages(p,  warn.conflicts = FALSE)
    suppressWarnings(suppressMessages(library(p, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)))
  }
}
# use norm data
otu<-read.table("OTU_rare.xls",sep="\t",header = TRUE,check.names=FALSE,comment.char="",row.names= 1)
# pick data
otutable <- otu
otutable <- otutable[,c(2:36,42:46)]
colnames(otutable) <- substr(colnames(otutable),1,nchar(colnames(otutable))-5)
#40samples, 3 categories：CLT(n=15)、DSS(n=15)、LbGP(n=10)
design <- read.table("RFdesign.txt", header=T, row.names=1, sep="\t") 
otutable.t<-t(otutable)   #transformation
otutable.t<-as.data.frame(otutable.t)   #dataframe
design$Group = factor(design$Group,order=T,levels=unique(design$Group))
otutable.t$type <- design$Group
#################################
#RandomForest
set.seed(0)
rf.train <- randomForest(type~., # group
                         data=otutable.t, # use dataset
                         ntree = 1000, # number of trees
                         importance = TRUE,
                         proximity = TRUE) 
rf.train  
plot(rf.train)  
#importance
imp= as.data.frame(rf.train$importance)
imp = imp[order(imp$MeanDecreaseAccuracy,decreasing = T),]
write.table(imp,file = "importance_feature.txt",quote = F,sep = '\t', row.names = T, col.names = T)  #输出重要性
head(imp)
varImpPlot(rf.train)  #重要性绘图
###########################
#pick top 20
imp_sub=imp[1:20,]
imp_sub$taxa<-rownames(imp_sub)
imp_sub$taxa=factor(imp_sub$taxa,order=T,levels = rev(imp_sub$taxa))
p=ggplot(data = imp_sub, mapping = aes(x=taxa,y=MeanDecreaseAccuracy)) + 
  geom_bar(stat="identity")+coord_flip()+theme_bw()+
  theme(panel.grid=element_blank(), 
        axis.text.x=element_text(colour="black"),
        axis.text.y=element_text(colour="black"),
        panel.border=element_rect(colour = "black"),
        legend.key = element_blank(),plot.title = element_text(hjust = 0.5))
p

######################################
#10-fold cross validation
result= replicate(5, rfcv(otutable.t[,-ncol(otutable.t)], otutable.t$type, cv.fold=10), simplify=FALSE)    
error.cv= sapply(result, "[[", "error.cv")
matplot(result[[1]]$n.var, cbind(rowMeans(error.cv), error.cv), type="l",
        lwd=c(2, rep(1, ncol(error.cv))), col=1, lty=1, log="x",
        xlab="Number of variables", ylab="CV Error",xlim=c(1,10))
#output results
cv.result=cbind(result[[1]]$n.var, rowMeans(error.cv), error.cv)
#write.table(cv.result,file ="rfcv_result.txt",quote = F,sep = '\t', row.names = T, col.names = T)
cv.result
#####################################
#Parameters optimization
#choose mtry
rf.formula=as.formula(paste0("type ~",paste(row.names(imp)[1:10],collapse="+")))
rf.formula

train.res=train(rf.formula, 
                data = otutable.t, # Use the train data frame as the training data
                method = 'rf',# Use the 'random forest' algorithm
                trControl = trainControl(method='cv', 
                                         number=10, 
                                         repeats=5, 
                                         search='grid')) # Use 10 folds for cross-validation 重复5次
train.res
######################################
#training
#pick mtry
model <- randomForest(rf.formula, # new model
                      data=otutable.t,
                      ntree = 500, # number of decision tree
                      mtry = 2,
                      importance = TRUE,
                      proximity = TRUE)

model
#taxonomy of variation
otu$taxa <- rownames(otu)
tax <- otu[otu$taxa %in% imp_sub$taxa[1:10],c(92:98)]
View(tax)

#########################################
#Accuracy Assessment
pred1 <- predict(model, newdata = otutable.t,type="response")
#predict
confusionMatrix(pred1, otutable.t$type)
#ROC curve
pred2 <- predict(model, newdata = otutable.t,type="vote")
roc.info<-roc(factor(otutable.t$type[21:30],ordered = T,levels = unique(otutable.t$type[21:30])),
              pred2[21:30,5],
              plot=TRUE, 
              legacy.axes=TRUE, 
              percent=FALSE, 
              xlab="False positive percentage", 
              ylab="True postive percentage",
              col="#4daf4a", 
              lwd=4, 
              print.auc=TRUE)
#multiclass ROC curve
roc.all <- multiclass.roc(otutable.t$type,
                          pred2, 
                          plot=TRUE, 
                          legacy.axes=TRUE, 
                          percent=FALSE, 
                          xlab="False positive percentage", 
                          ylab="True postive percentage",
                          col="#4daf4a", 
                          lwd=4, 
                          print.auc=TRUE)




