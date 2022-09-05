setwd("D:/R route/life-16")
#install CARBayes package to run combine.data.shapefile function
devtools::install_github("duncanplee/CARBayes")#从github上下载包
devtools::install_github("verasls/lvmisc")#从github上下载包，画森林图的包
library(shapefiles)
library(CARBayes)
library(spdep)
library(stats)
library(lvmisc)
library(tidyverse)
library(forestplot)
library(DALEX)
library(ingredients)##可视化包
library(MASS)
library(modelr)
library(GWmodel)
library(rgdal)
library(spgwr)
library(broom)
library(dplyr)
library(tibble)
library(pROC)
library(ggplot2)
library(GGally)
library(RColorBrewer)

#####read data读取数据#####
#read .shp file
shp <-read.shp(shp.name = "D:/R route/life-16/life-16.shp")
#read .dbf file
dbf <-read.dbf(dbf.name = "D:/R route/life-16/life-16.dbf")
dbf$dbf <- dbf$dbf[,c(2, 1, 3:31)]# to get the area names as the first col
#read .csv file
balt_data <-read.csv("balt-life-exp.csv", row.names = 1)

#combine balt_data and shp, dbf file
balt_shp <-combine.data.shapefile(data = balt_data, shp = shp, dbf = dbf)


#plot the data
spplot(balt_shp,c("LifeExp"),as.table=TRUE, scales=list(draw = TRUE),col.regions=terrain.colors(n=16))
plot(balt_data)#多元数据散点图
balt_dataplot <- tibble::rownames_to_column(balt_data, "Name")#将行名变为第一列
cor(balt_data)#多元数据相关系数矩阵
ggpairs(log2(balt_data+1))
#LifeExp分City条形图
balt_dataplot %>% 
  ggplot(aes(Name, LifeExp, fill = Name)) + 
  geom_col() + 
  theme(legend.position = "bottom") +
  labs(y="LifeExp")#LifeExp条形图

#箱线图
par(mfrow = c(3,5))
boxplot(balt_data$LifeExp,
        xlab = "LifeExp",
        ylab = "Value")
boxplot(balt_data$RDI,
        xlab = "RDI",
        ylab = "Value")
boxplot(balt_data$AvgHHSize,
        xlab = "AvgHHSize",
        ylab = "Value")
boxplot(balt_data$MedIncome,
        xlab = "MedIncome",
        ylab = "Value")
boxplot(balt_data$PercBelowPovLine,
        xlab = "PercBelowPovLine",
        ylab = "Value")
boxplot(balt_data$MedHousePrice,
        xlab = "MedHousePrice",
        ylab = "Value")
boxplot(balt_data$CrimeRate,
        xlab = "CrimeRate",
        ylab = "Value")
boxplot(balt_data$HSDropOut,
        xlab = "HSDropOut",
        ylab = "Value")
boxplot(balt_data$PercTANF,
        xlab = "PercTANF",
        ylab = "Value")
boxplot(balt_data$InfMort,
        xlab = "InfMort",
        ylab = "Value")
boxplot(balt_data$UnempRate,
        xlab = "UnempRate",
        ylab = "Value")
boxplot(balt_data$PercBatchDeg,
        xlab = "PercBatchDeg",
        ylab = "Value")
boxplot(balt_data$NonLabour,
        xlab = "NonLabour",
        ylab = "Value")
boxplot(balt_data$PercNoVeh,
        xlab = "PercNoVeh",
        ylab = "Value")

#####multi regression model回归模型#####
balt_lm <- balt_data
#LifeExp与各变量的一元回归图
temp <- balt_lm
temp$CrimeRate <- log(temp$CrimeRate)
balt_lmplot1 <- reshape2::melt(temp, id = 'LifeExp')
ggplot(balt_lmplot1, aes(value, LifeExp)) +
  geom_point() +
  facet_wrap(~variable, ncol = 3, scale = 'free') +
  geom_smooth(method = 'lm')


#多元回归
model_lm <- lm(LifeExp ~ RDI + AvgHHSize + MedIncome + PercBelowPovLine +
                 CrimeRate + HSDropOut + PercTANF + InfMort + UnempRate + 
                 PercBatchDeg + NonLabour + PercNoVeh, data = balt_lm)
summary(model_lm)#回归方程的显著性检验（t检验）
anova(model_lm)#回归方程的显著性检验（F检验）
exp(cbind(OR = coef(model_lm), confint(model_lm)))

#重要性可视化图
explain_lm <- explain(model_lm, data = balt_lm[,2:14], y = balt_lm[,1])
fig<- feature_importance(explain_lm, B = 1)
plot(fig)

#多元回归画图
plot_model_residual_fitted(model_lm) #plots the model residuals versus the fitted values
plot_model_scale_location(model_lm) #plots the square root of absolute value of the model residuals versus the fitted values
plot_model_qq(model_lm) #plots a QQ plot of the model standardized residuals
plot_model_cooks_distance(model_lm) #plots a bat chart of each observation Cook's distance value. 
plot_model_multicollinearity(model_lm) #plots a bar chart of the variance inflation factor (VIF) for each of the model terms.
plot_model(model_lm) #returns a plot grid with all the applicable plot diagnostics to a given model

#预测值
balt_lm$pred <- predict(model_lm)
balt_predplot <- tibble::rownames_to_column(balt_lm, "Name")#将行名变为第一列
#预测值画条形图
balt_dataplot %>% 
  ggplot(aes(Name, LifeExp, fill = Name)) + 
  geom_col() + 
  theme(legend.position = "bottom") +
  labs(y="LifeExp")#LifeExp条形图

#计算预测精度
lm_error <- tibble(train_rsquare = rsquare(model_lm,balt_lm),
                   train_mae = mae(model_lm,balt_lm),
                   train_mape = mape(model_lm,balt_lm),
                   train_rmse = rmse(model_lm,balt_lm),
                   train_mse = mse(model_lm,balt_lm))
print(lm_error)

#模型优化
step.fit<-stepAIC(model_lm,direction = "both")
summary(step.fit) 
drop1(step.fit)

#多元回归
model_lm2 <- lm(LifeExp ~ RDI + AvgHHSize + CrimeRate + HSDropOut + 
                  PercTANF + InfMort + PercBatchDeg + NonLabour, data = balt_lm)
summary(model_lm2)#回归方程的显著性检验（t检验）
anova(model_lm2)#回归方程的显著性检验（F检验）
exp(cbind(OR = coef(model_lm2), confint(model_lm2)))

#画图
plot_model_residual_fitted(model_lm2) #plots the model residuals versus the fitted values
plot_model_scale_location(model_lm2) #plots the square root of absolute value of the model residuals versus the fitted values
plot_model_qq(model_lm2) #plots a QQ plot of the model standardized residuals
plot_model_cooks_distance(model_lm2) #plots a bat chart of each observation Cook's distance value. 
plot_model_multicollinearity(model_lm2) #plots a bar chart of the variance inflation factor (VIF) for each of the model terms.
plot_model(model_lm2) #returns a plot grid with all the applicable plot diagnostics to a given model

#####地理加权回归模型（GWR）#####
par(mfrow = c(1,1))
balt_sp <- balt_shp

#Calculate a distance vector(matrix) between any GW model calibration point(s) and the data points
DM<-gw.dist(dp.locat=coordinates(balt_sp))
DeVar<-"LifeExp"#目标变量
InDeVars<-c("RDI", "AvgHHSize", "MedIncome", "PercBelowPovLine",
            "CrimeRate", "HSDropOut", "PercTANF", "InfMort", "UnempRate", 
            "PercBatchDeg", "NonLabour", "PercNoVeh")#独立变量
#selects one GWR model from many alternatives based on the AICc values
model.sel<-gwr.model.selection(DeVar,InDeVars, data=balt_sp,
                               kernel = "gaussian", dMat=DM,bw=5000)
#Sort the results from the GWR model selection function gwr.model.selection
sorted.models <- gwr.model.sort(model.sel, numVars = length(InDeVars),
                                ruler.vector = model.sel[[2]][,2])
model.list<-sorted.models[[1]]#gwr模型列表

#visualises the GWR models
X11(width = 10, height = 8)#画图宽高参数
gwr.model.view(DeVar, InDeVars, model.list=model.list)
#本图中心位置代表因变量LifeExp，其余不同颜色和形状的点代表自变量，
#每一条线代表由不同自变量构成的GWR模型，末端编号与下图中横轴的Model NO.对应
X11(width = 10, height = 8)
plot(sorted.models[[2]][,2], col = "black", pch = 20,
     lty = 5, main = "Alternative view of GWR model selection procedure",
     ylab = "AICc", xlab = "Model number", type = "b")
#观察上面两幅图，找出模型选择的结果，并进行选择后的模型解算和分析。AICc越小拟合模型越好。
#AICC值变化小于30时，模型解算结果被认为不再有显著变化。

#输出AIC, AICc, RSS
sp_aic <- sorted.models[[2]]
colnames(sp_aic) <- c("bandwidth", "AIC", "AICc", "RSS")
print(sp_aic)

#根据上面两幅图确定关系式中的自变量
form <- LifeExp ~ RDI + AvgHHSize + MedIncome + PercBelowPovLine +
  CrimeRate + HSDropOut + PercTANF + InfMort + UnempRate + 
  PercBatchDeg + NonLabour + PercNoVeh#这里把自变量全选了，可以根据需要改

#select bandwidth automaticly to calibrate a basic GWR model
bw.gwr.1 <- bw.gwr(form, approach = "AICc",
                   adaptive = TRUE, data = balt_sp, kernel = "gaussian")
#implements basic GWR
gwr.res <- gwr.basic(form, data = balt_sp,
                     bw = bw.gwr.1, adaptive = TRUE, kernel = "gaussian")
gwr.res

spplot(gwr.res$SDF, "yhat")#lifeExp预测值画图

#各自变量系数画图
spplot(gwr.res$SDF, c("RDI", "AvgHHSize", "MedIncome", "PercBelowPovLine",
                    "CrimeRate", "HSDropOut", "PercTANF", "InfMort", "UnempRate", 
                    "PercBatchDeg", "NonLabour", "PercNoVeh"), col.regions=grey.colors(20))
#残差分析
mypalette <- brewer.pal(6,"Spectral")
map.na = list("SpatialPolygonsRescale", layout.north.arrow(),
              offset = c(556000,195000),scale = 4000,col = 1)
map.scale.1 = list("SpatialPolygonsRescale", layout.scale.bar(),
              offset = c(511000,158000),scale = 5000, col =1,
              fill = c("transparent", "green"))
map.scale.2 = list("sp.text",c(511000,157000),"0",cex = 0.9, col = 1)
map.scale.3 = list("sp.text",c(511000,157000),"5km",cex = 0.9, col = 1)
map.layout <- list(map.na, map.scale.1,map.scale.2,map.scale.3)
spplot(gwr.res$SDF, "residual", key.space = "right",
       col.regions = mypalette, at = c(-8, -6, -4,-2, 0, 2, 4), main = 'Residuals',
       sp.layout = map.layout)#残差图
#输出各地区残差表
residual <- cbind(row.names(balt_sp), gwr.res$SDF$residual)
colnames(residual) <- c("City", "Residual")
print(residual)

#新代码
#### Create the spatial list information for constructing Moran's I
library(spdep)
W.nb <- poly2nb(balt_sp, row.names = rownames(balt_sp@data))
W.list <- nb2listw(W.nb, style = "B")
model1 <- lagsarlm(form, data = balt_sp, 
                                 W.list,
                                 method = "eigen")
#### Check the residuals for correlation
moran.mc(x = residuals(model1), listw = W.list, nsim = 10000)
