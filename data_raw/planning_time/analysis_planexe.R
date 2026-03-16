
setwd("/Users/Ivory/Desktop/research&project/first-year project/sokoban data/data/")
sokoban<-read.table("sokoban_UndergraduateStudents.txt",header = TRUE)








################################### analysis 1 ###################################

################### descriptive stats ###############

# mean and sd for planning times (sec)
mean(sokoban$PT1/1000); sd(sokoban$PT1/1000)
mean(sokoban$PT2/1000); sd(sokoban$PT2/1000)
mean(sokoban$PT3/1000); sd(sokoban$PT3/1000)
mean(sokoban$PT4/1000); sd(sokoban$PT4/1000)
mean(sokoban$PT5/1000); sd(sokoban$PT5/1000)
mean(sokoban$PT6/1000); sd(sokoban$PT6/1000)
mean(sokoban$PT7/1000); sd(sokoban$PT7/1000)
mean(sokoban$PT8/1000); sd(sokoban$PT8/1000)
mean(sokoban$PT9/1000); sd(sokoban$PT9/1000)
mean(sokoban$PT10/1000); sd(sokoban$PT10/1000)


# mean and sd for execution times (total times - planning times)
sokoban$ET1 <- sokoban$TT1 - sokoban$PT1
sokoban$ET2 <- sokoban$TT2 - sokoban$PT2
sokoban$ET3 <- sokoban$TT3 - sokoban$PT3
sokoban$ET4 <- sokoban$TT4 - sokoban$PT4
sokoban$ET5 <- sokoban$TT5 - sokoban$PT5
sokoban$ET6 <- sokoban$TT6 - sokoban$PT6
sokoban$ET7 <- sokoban$TT7 - sokoban$PT7
sokoban$ET8 <- sokoban$TT8 - sokoban$PT8
sokoban$ET9 <- sokoban$TT9 - sokoban$PT9
sokoban$ET10 <- sokoban$TT10 - sokoban$PT10
mean(sokoban$ET1/1000); sd(sokoban$ET1/1000)
mean(sokoban$ET2/1000); sd(sokoban$ET2/1000)
mean(sokoban$ET3/1000); sd(sokoban$ET3/1000)
mean(sokoban$ET4/1000); sd(sokoban$ET4/1000)
mean(sokoban$ET5/1000); sd(sokoban$ET5/1000)
mean(sokoban$ET6/1000); sd(sokoban$ET6/1000)
mean(sokoban$ET7/1000); sd(sokoban$ET7/1000)
mean(sokoban$ET8/1000); sd(sokoban$ET8/1000)
mean(sokoban$ET9/1000); sd(sokoban$ET9/1000)
mean(sokoban$ET10/1000); sd(sokoban$ET10/1000)




######### wide data to long data #################

nsample<-nrow(sokoban)
nitem<-10
ntime<-2
Tdata<-matrix(0,nrow = nsample*nitem*ntime,ncol = 6)
colnames(Tdata)<-c("DV","ID","ITEM","Planning","Executing","Planningtime")
column_DV<-1
column_ID<-2
column_ITEM<-3
column_Planning<-4
column_Executing<-5
column_Planningtime<-6


# column of DV
for(i_sub in 1:nsample){
  for(i_item in 1:nitem) {
    tmp_planningtime = sokoban[i_sub,(3+(i_item-1)*5)]
    tmp_totaltime = sokoban[i_sub,(6+(i_item-1)*5)]
    tmp_executingtime = tmp_totaltime-tmp_planningtime
    Tdata[(((i_sub-1)*nitem*ntime+1)+(i_item-1)*ntime):((i_sub-1)*nitem*ntime+i_item*ntime),column_DV]=matrix(c(tmp_planningtime,tmp_executingtime),nrow = 2)
  }
}

# column of ID
for(i_sub in 1:nsample) {
  Tdata[(1+(i_sub-1)*nitem*ntime):(i_sub*nitem*ntime),column_ID]=matrix(i_sub,nrow = nitem*ntime)
}

# column of ITEM
item_unit<-matrix(0,nrow = nitem*ntime)

for(i_item_unit in 1:nitem){
  item_unit[(1+(i_item_unit-1)*ntime):(i_item_unit*ntime)]=matrix(i_item_unit,nrow = ntime)
}

for(i_sub in 1:nsample) {
  Tdata[(1+(i_sub-1)*nitem*ntime):(i_sub*nitem*ntime),column_ITEM]=item_unit
}

# column of Planning
planning_unit<-matrix(c(1,0),nrow = ntime)

for(i_item in 1:(nitem*nsample)){
  Tdata[(1+(i_item-1)*ntime):(i_item*ntime),column_Planning]=planning_unit
}

# column of Executing
executing_unit<-matrix(c(0,1),nrow = ntime)

for(i_item in 1:(nitem*nsample)){
  Tdata[(1+(i_item-1)*ntime):(i_item*ntime),column_Executing]=executing_unit
}

# column of Planningtime
for(i_sub in 1:nsample){
  for(i_item in 1:nitem) {
    tmp_planningtime = sokoban[i_sub,(3+(i_item-1)*5)]
    Tdata[(((i_sub-1)*nitem*ntime+1)+(i_item-1)*ntime):((i_sub-1)*nitem*ntime+i_item*ntime),column_Planningtime]=matrix(tmp_planningtime,nrow = 2)
  }
}





##################      relationship on latent variable level and direct effect     ####################
library(Matrix)
library(lme4)
library(MASS)


#### variable names ########
DV<-Tdata[,column_DV]
id<-as.factor(Tdata[,column_ID])
item<-as.factor(Tdata[,column_ITEM])
Planning<-Tdata[,column_Planning]
Executing<-Tdata[,column_Executing]
Planningtime<-Tdata[,column_Planningtime]
Dep<-Executing*log(Planningtime/1000)


# average planning time for each item
PlanningT_c = c(23017.52941,21704.13445,15407.94118,19357.18487,19880.93277,
                22779.54622,25374.76471,21101.27731,24760.56303,35574.44538)
# average execution time for each item
ExecutingT_c = c(31172.94118,9148.327731,12212.2605,13761.19328,19138.68067,
                 13262.78992,22401.53782,22514.07563,30297.53782,29125.67227)
# average steps for each item
Step_c = c(47.80672269,17.85714286,21.05882353,28.28571429,42.63865546,24.29411765,
           41.20168067,39.08403361, 46.62184874, 47.34453782)  
cor(log(PlanningT_c),Step_c) # 0.59
cor(log(ExecutingT_c),Step_c) # 0.97
# create variable "step" in longdata form
Step = rep(rep(Step_c,each=2),119)







###### no dependency model#######
two_ND<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing)
summary(two_ND)
###### general dependency #######
two_GD<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Dep)
summary(two_GD)
##### person-specific #####
two_PSD<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Dep+(-1+Dep|id))
summary(two_PSD)
##### item-specific #####
two_ISD<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Dep+(-1+Dep|item))
summary(two_ISD)


# investigate the dependencies after adding covariate "step" (route length)
two_ND_step <- lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Step)
summary(two_ND_step)
two_GD_step<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Dep+Step)
summary(two_GD_step)
two_PSD_step<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Dep+(-1+Dep|id)+Step)
summary(two_PSD_step)
two_ISD_step<-lmer(log(DV/1000)~1+(-1+Planning+Executing|id)+(-1+Planning+Executing|item)+Executing+Dep+(-1+Dep|item)+Step)
summary(two_ISD_step)


### likelihood ratio tests #######
anova(two_ND,two_GD)  #p-value=0.0004188 ***
anova(two_ND,two_PSD) #p-value=0.00195 **
anova(two_ND,two_ISD) #p-value=1.133e-05 ***
anova(two_GD,two_PSD) #p-value=0.8537
anova(two_GD,two_ISD) #p-value=0.001309 **




################################### analysis 2 ###################################
###############        create new long data for analysis 2    ########################
nsample<-nrow(sokoban)
nitem<-10
ntime<-2
T2data<-matrix(0,nrow = nsample*nitem,ncol = 4)
colnames(T2data)<-c("ID","ITEM","Planningtime","Executingtime")
column_ID2<-1
column_ITEM2<-2
column_Planningtime2<-3
column_Executingtime2<-4


# column of ID
for(i_sub in 1:nsample) {
  T2data[(1+(i_sub-1)*nitem):(i_sub*nitem),column_ID2]=matrix(i_sub,nrow = nitem)
}

# column of ITEM
item_unit<-matrix(0,nrow = nitem)

for(i_item_unit in 1:nitem){
  item_unit[(1+(i_item_unit-1)):(i_item_unit)]=matrix(i_item_unit,nrow = 1)
}

for(i_sub in 1:nsample) {
  T2data[(1+(i_sub-1)*nitem):(i_sub*nitem),column_ITEM2]=item_unit
}

# column of Planningtime
for(i_sub in 1:nsample){
  for(i_item in 1:nitem) {
    tmp_planningtime = sokoban[i_sub,(3+(i_item-1)*5)]
    T2data[(((i_sub-1)*nitem+1)+(i_item-1)):((i_sub-1)*nitem+i_item),column_Planningtime2]=matrix(tmp_planningtime,nrow = 1)
  }
}

# column of Executingtime
for(i_sub in 1:nsample){
  for(i_item in 1:nitem) {
    tmp_planningtime = sokoban[i_sub,(3+(i_item-1)*5)]
    tmp_totaltime = sokoban[i_sub,(6+(i_item-1)*5)]
    tmp_executingtime = tmp_totaltime-tmp_planningtime
    T2data[(((i_sub-1)*nitem+1)+(i_item-1)):((i_sub-1)*nitem+i_item),column_Executingtime2]=matrix(tmp_executingtime,nrow = 1)
  }
}


#############    test the normality and homoscedasticity  #####################
library(nortest)
lillie.test(T2data[,column_Planningtime2]) 
lillie.test(T2data[,column_Executingtime2]) 

PlanningT<-T2data[,column_Planningtime2]
ExecutingT<-T2data[,column_Executingtime2]

tran_Plan=log(PlanningT/1000)
tran_Exe=log(ExecutingT/1000)

lillie.test(tran_Plan) 
lillie.test(tran_Exe)


hist(tran_Plan,freq = FALSE,breaks = 80,
     main = "distribution of log planning time",xlab = "log planning time")
lines(density(tran_Plan))

hist(tran_Exe,freq = FALSE,breaks = 100,
     main = "distribution of log execution time",xlab = "log execution time")
lines(density(tran_Exe))




#### set variable names ###
id2<-as.factor(T2data[,column_ID2])
item2<-as.factor(T2data[,column_ITEM2])
PlanningT<-T2data[,column_Planningtime2]
ExecutingT<-T2data[,column_Executingtime2]


PlanRand<-lmer(log(PlanningT/1000)~1+(1|item2)+(1|id2))
summary(PlanRand)
id_effect_of_Plan_Rand=rep(unlist(ranef(PlanRand)[1]),each=10)
#the part explained by person
item_effect_of_Plan_Rand=rep(unlist(ranef(PlanRand)[2]),119)
#the part explained by item
mean_plan=2.72801
#the intercept of fixed effect from summary(PlanRand)
E_plan = mean_plan + item_effect_of_Plan_Rand + id_effect_of_Plan_Rand
# expected value of log execution time given by person p and item i
res_of_Plan_Rand=log(PlanningT/1000)-E_plan
#the residual planning time that gets rid of id effect and item effect


####### no dependency model #######
exe_ND<-lmer(log(ExecutingT/1000)~1+(1|item2)+(1|id2))
summary(exe_ND)
####### general dependency model #######
exe_GD<-lmer(log(ExecutingT/1000)~1+(1|item2)+(1|id2)+res_of_Plan_Rand)
summary(exe_GD)
####### person-specific model #######
exe_PSD<-lmer(log(ExecutingT/1000)~1+(1|item2)+(1|id2)+res_of_Plan_Rand+(-1+res_of_Plan_Rand|id2))
summary(exe_PSD)
####### item-specific model #######
exe_ISD<-lmer(log(ExecutingT/1000)~1+(1|item2)+(1|id2)+res_of_Plan_Rand+(-1+res_of_Plan_Rand|item2))
summary(exe_ISD)

#### likelihood ratio tests #####
anova(exe_ND,exe_GD)
anova(exe_ND,exe_PSD)
anova(exe_ND,exe_ISD)
anova(exe_GD,exe_PSD)
anova(exe_GD,exe_ISD)

################################### analysis 3 ###################################
#################     create data for analysis 3        ############################
nsample<-nrow(sokoban)
nitem<-10
ntime<-2
T3data<-matrix(0,nrow = nsample,ncol = nitem*ntime)

for(i_item in 1:nitem){
  T3data[,i_item]=sokoban[,3+5*(i_item-1)]
  T3data[,10+i_item]=sokoban[,6+5*(i_item-1)]-sokoban[,3+5*(i_item-1)]
}


name_column_P=c()
name_column_E=c()
for(i_item in 1:nitem){
  tmp_name_column_P=c(paste("P",as.character(i_item),sep = ""))
  name_column_P=c(name_column_P,tmp_name_column_P)
  tmp_name_column_E=c(paste("E",as.character(i_item),sep = ""))
  name_column_E=c(name_column_E,tmp_name_column_E)
}

name_column=c(name_column_P,name_column_E)

T3data=log(T3data/1000)
colnames(T3data)=name_column
T3data=as.data.frame(T3data)

##################### factor analysis ##################################
library(lavaan)
library(psych)

### correlated two-factor model without residual correlations
model_2F<-'planningF =~ P1+P2+P3+P4+P5+P6+P7+P8+P9+P10
executingF =~ E1+E2+E3+E4+E5+E6+E7+E8+E9+E10'
model_2F_result<-sem(model_2F, data = T3data,std.lv=T)
summary(model_2F_result,standardized=T,fit=T,rsquare=T)

residuals(model_2F_result,type="cor")

### correlated two-factor model with residual correlations
model_2F_cov<-'planningF=~P1+P2+P3+P4+P5+P6+P7+P8+P9+P10
executingF=~E1+E2+E3+E4+E5+E6+E7+E8+E9+E10
P1~~E1;P2~~E2;P3~~E3;P4~~E4;P5~~E5;
P6~~E6;P7~~E7;P8~~E8;P9~~E9;P10~~E10'
model_2F_cov_result<-sem(model_2F_cov, data = T3data,std.lv=T)
summary(model_2F_cov_result,standardized=T,fit=T,rsquare=T)


### correlated two-factor model with direct-effect dependencies
model_2F_direct<-'planningF=~P1+P2+P3+P4+P5+P6+P7+P8+P9+P10
executingF=~E1+E2+E3+E4+E5+E6+E7+E8+E9+E10
E1~P1;E2~P2;E3~P3;E4~P4;E5~P5;
E6~P6;E7~P7;E8~P8;E9~P9;E10~P10'
model_2F_direct_result<-sem(model_2F_direct, data = T3data,std.lv=T)
summary(model_2F_direct_result,standardized=T,fit=T,rsquare=T)



fitmeasures(model_2F_cov_result,"aic")
fitmeasures(model_2F_direct_result,"aic")

fitmeasures(model_2F_cov_result,"bic")
fitmeasures(model_2F_direct_result,"bic")

fitmeasures(model_2F_cov_result,"rmsea")
fitmeasures(model_2F_direct_result,"rmsea")

fitmeasures(model_2F_cov_result,"cfi")
fitmeasures(model_2F_direct_result,"cfi")

fitmeasures(model_2F_cov_result,"srmr")
fitmeasures(model_2F_direct_result,"srmr")

#### likelihood ratio test ####
anova(model_2F_result,model_2F_cov_result)   #68.338*** model_2F_cov is better
anova(model_2F_result,model_2F_direct_result)   #64.898*** model_2F_direct is better


#### correlations between the residual correlations from the factor model and the ωi estimates from the two GLM models
res_cor=c(-0.328,-0.390,0.086,0.152,-0.079,0.007,-0.05,-0.115,-0.483,-0.274) # estimated residual correlations from the second factor model (summary of model_2F_cov_result) 
direct_effect = c(-0.081,-0.338,0.064,0.025,-0.052,-0.041,-0.122,-0.064,-0.181,-0.044)
ranf_item=unlist(ranef(two_ISD)$item[3])  # ωi estimates from analysis 1
item_omega = unlist(ranef(exe_ISD)[2])[1:10]  # ωi estimates from analysis 2

cor(res_cor,ranf_item) # 0.64
cor(res_cor,item_omega) # 0.95

cor(direct_effect,ranf_item)
cor(direct_effect,item_omega)
