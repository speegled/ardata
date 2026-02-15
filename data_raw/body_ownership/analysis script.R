# Libraries and databases ----

library(readxl)
library(tidyr)
library(base)
library(stringr)
library(data.table)
library(dplyr)
library(ggplot2)
library(rstatix)
library(ggpubr)
library(writexl)
library(brms)
library(BayesFactor)

ncores <- parallel::detectCores()-5

#total database
db_total <- read_excel("db total.xlsx")
View(db_total)

#factor coding
db_total$Time <- as.factor(db_total$Time)
contrasts(db_total$Time)<-contr.treatment(2, base = 2)
T1 <- c(0.5,-0.5)
contrasts(db_total$Time)<-cbind(T1)

db_total$Illusion <- as.factor(db_total$Illusion)
FBI <- c(-0.5,0.5)
contrasts(db_total$Illusion)<-cbind(FBI)

db_total$Location <- as.factor(db_total$Location)
Dislocation <- c(-0.5,0.5)
contrasts(db_total$Location)<-cbind(Dislocation)

db_total$Group <- as.factor(db_total$Group)
Dislocation.first <- c(-0.5,0.5)
contrasts(db_total$Group)<-cbind(Dislocation.first)

# Prior ----

my_priors <- c(
  set_prior("normal(0,0.5)", class = "b"),
  set_prior("normal(0,1)", class = "sd"),
  set_prior("normal(0,0.5)", class = "Intercept", lb=-3, ub=3)
)

# Embodiment --------------------------------------------------------------

### Outliers ----------------------------------------------------------------
embo.out <- db_total %>%
  identify_outliers(Embodiment) #no outliers

ggboxplot(
  db_total,y = "Embodiment",
  labelOutliers = TRUE)

plot(density(db_total$Embodiment, na.rm = T))

### Model ----
brm_emb <- brm(
  Embodiment ~ Time * Location * Illusion +
    (1 + Time + Location + Illusion|| ID),
  data = db_total,
  family = skew_normal, #can handle skewed responses
  prior = my_priors, #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

# Posterior predictive check
pp_check(brm_emb, ndraws = 500)

#### Results ----
summary(brm_emb) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_emb)

#Population level effects
#interaction plot
conditions <- data.frame(Illusion = c("RHI","FBI"),"cond__" = c("RHI","FBI"))
conditional_effects(brm_emb, effects = "Location:Time", conditions = conditions)

#BF for interaction inclusion
brm_emb.2 <- brm(
  Embodiment ~ Location * Illusion +
    (1 + Location + Illusion|| ID),
  data = db_total,
  family = skew_normal, #can handle skewed responses
  prior = my_priors_emb, #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

bayes_factor(brm_emb, brm_emb.2)

# Group-Level effects: the Bayesian equivalent of frequentist random effects
rnd.eff <- as.data.frame(cbind(c(11:79,81:91),as.data.frame(coef(brm_emb))[,c(1,5)]))
names(rnd.eff) <- c("ID","Emb.int","Emb.time")

# Disembodiment --------------------------------------------------------------

### Outliers ----------------------------------------------------------------
disem.out <- db_total %>%
  identify_outliers(Disembodiment) #2 outliers, not extreme, we keep them

ggboxplot(
  db_total,y = "Disembodiment",
  labelOutliers = TRUE)

plot(density(db_total$Disembodiment, na.rm = T))

### Model ----
brm_disemb <- brm(
  Disembodiment ~ Time * Location * Illusion +
    (1 + Time + Location + Illusion || ID),
  data = db_total,
  family = student, #it's less influenced by outliers
  prior = my_priors, #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

# Posterior predictive check
pp_check(brm_disemb, ndraws = 500)

#### Results ----
summary(brm_disemb) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_disemb)


#Population level effects
#plot
conditions <- data.frame(Illusion = c("RHI","FBI"),"cond__" = c("RHI","FBI"))
conditional_effects(brm_disemb, effects = "Location:Time", conditions = conditions)

conditional_effects(brm_disemb, effects = "Location:Illusion")

conditional_effects(brm_disemb, effects = "Time")

#BF for interaction inclusion
brm_disemb.2 <- brm(
  Disembodiment ~ Time + Location * Illusion +
    (1 + Time + Location + Illusion || ID),
  data = db_total,
  family = student, #it's less influenced by outliers
  prior = my_priors_emb, #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

bayes_factor(brm_disemb, brm_disemb.2) #0.00041

# Group-Level effects: the Bayesian equivalent of frequentist random effects
rnd.eff <- as.data.frame(cbind(rnd.eff,as.data.frame(coef(brm_disemb))[,c(1,5)]))
names(rnd.eff) <- c("ID","Emb.int","Emb.time","Disemb.int","Disemb.time")

# Psysical sensation --------------------------------------------------------------

### Outliers ----------------------------------------------------------------
phys.out <- db_total %>%
  identify_outliers(Physic) #no outliers 

ggboxplot(
  db_total,y = "Physic",
  labelOutliers = TRUE)

plot(density(db_total$Physic, na.rm = T))

#recode the variable to use the cumulative family distribution
db_total$PhysicR <- db_total$Physic + 4
db_total$PhysicR <- as.integer(db_total$PhysicR)
plot(density(db_total$PhysicR, na.rm = T))

### Model ----
brm_phys <- brm(
  PhysicR ~ Time * Location * Illusion +
    (1 + Time + Location + Illusion || ID),
  data = db_total,
  family = cumulative, #for ordinal regression
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

# Posterior predictive check
pp_check(brm_phys, ndraws = 500)

#### Results ----
summary(brm_phys) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_phys)


#Population level effects
#interaction plot
conditions <- data.frame(Illusion = c("RHI","FBI"),"cond__" = c("RHI","FBI"))
conditional_effects(brm_phys, effects = "Location:Time", conditions = conditions)

# SCR --------------------------------------------------------------

### Outliers ----------------------------------------------------------------
SCR.out <- db_total %>%
  identify_outliers(SCR.PP)

ggboxplot(
  db_total,y = "SCR.PP",
  labelOutliers = TRUE)

plot(density(db_total$SCR.PP, na.rm = T))

### Model ----
brm_SCR <- brm(
  SCR.PP ~ Location * Illusion +
    (1 + Location + Illusion || ID),
  data = db_total,
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T), #we need it to use the bayes_factor() function
  control = list(adapt_delta = 0.9)
)

# Posterior predictive check
pp_check(brm_SCR, ndraws = 500)

#### Results ----
summary(brm_SCR) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_SCR)

#Population level effects
#interaction plot
conditional_effects(brm_SCR, effects = "Location:Illusion")

# Group-Level effects: the Bayesian equivalent of frequentist random effects
rnd.eff$SCR.int <- c(
  as.data.frame(coef(brm_SCR))[,1][1:6],
  NA,NA,NA,
  as.data.frame(coef(brm_SCR))[,1][7:12],
  NA,as.data.frame(coef(brm_SCR))[,1][13:76])

### Correlation between SCR and embodiment ----
BayesFactor::correlationBF(rnd.eff$Emb.time,rnd.eff$SCR.int) #BF01=2.56
cor.test(rnd.eff$Emb.time,rnd.eff$SCR.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=Emb.time, y=SCR.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

### Correlation between SCR and disembodiment ----
BayesFactor::correlationBF(rnd.eff$Disemb.time,rnd.eff$SCR.int) #BF01=1.67
cor.test(rnd.eff$Disemb.time,rnd.eff$SCR.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=Disemb.time, y=SCR.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

# Proprioceptive Drift --------------------------------------------------------------

# we already removed improbable pointing (<-100 or >0) and outliers, considering each
# subject and condition

#long database (each row is a pointing)
dt_propdrift <- read_excel("dt2.noout.xlsx")
View(dt_propdrift)

#factor coding
dt_propdrift$Time <- as.factor(dt_propdrift$Time)
contrasts(dt_propdrift$Time)<-contr.treatment(2, base = 2)
T1 <- c(0.5,-0.5)
contrasts(dt_propdrift$Time)<-cbind(T1)

dt_propdrift$Illusion <- as.factor(dt_propdrift$Illusion)
FBI <- c(-0.5,0.5)
contrasts(dt_propdrift$Illusion)<-cbind(FBI)

dt_propdrift$Location <- as.factor(dt_propdrift$Location)
Dislocation <- c(-0.5,0.5)
contrasts(dt_propdrift$Location)<-cbind(Dislocation)

### Model ----
brm_propD_trial <- brm(
  Prop.drift ~ Time * Location * Illusion +
    (1 + Time + Location + Illusion || ID + Trial),
  data = dt_propdrift,
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

# Posterior predictive check
pp_check(brm_propD_trial, ndraws = 500)

#### Results ----
summary(brm_propD_trial) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_propD_trial)

#Population level effects
#interaction plot
conditional_effects(brm_propD_trial, effects = "Location:Time")

conditions <- data.frame(Illusion = c("RHI","FBI"),"cond__" = c("RHI","FBI"))
conditional_effects(brm_propD_trial, effects = "Location:Time", conditions = conditions)

#BF for interaction inclusion
brm_propD_trial.2 <- brm(
  Prop.drift ~ Time + Location * Illusion +
    (1 + Time + Location + Illusion || ID + Trial),
  data = dt_propdrift,
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  sample_prior = T, #to calculate BF
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  save_pars = save_pars(all=T) #we need it to use the bayes_factor() function
)

bayes_factor(brm_propD_trial, brm_propD_trial.2) #2.293x10^22

# Correlation between explicit and implicit precision estimation----

## Models ----
#pointing ratings
plot(density(db_total$PointingRating, na.rm = T))

#recode variable to fit a cumulative distribution
db_total$PointingRatingR <- db_total$PointingRating + 4
db_total$PointingRatingR <- as.integer(db_total$PointingRatingR)

brm_point <- brm(
  PointingRatingR ~ Time * Location * Illusion +
    (1 + Time + Location + Illusion || ID),
  data = db_total,
  family = cumulative, #for ordinal regression
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
)
rnd.eff$point.int <- as.data.frame(coef(brm_point))[,1]

#virtual drift SE
plot(density(db_total$Virt.drift.se, na.rm = T))
ggboxplot(
  db_total,y = "Virt.drift.se",
  labelOutliers = TRUE)

brm_vdriftse <- brm(
  Virt.drift.se ~ Time * Location * Illusion +
    (1 + Time + Location + Illusion || ID),
  data = db_total,
  family = student, #it's less influenced by outliers
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
)
rnd.eff$virtse.int <- as.data.frame(coef(brm_vdriftse))[,1]

## Correlation ----
BayesFactor::correlationBF(rnd.eff$point.int,rnd.eff$virtse.int) #BF01=3.81
cor.test(rnd.eff$point.int,rnd.eff$virtse.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=point.int, y=virtse.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

# Virtual drift --------------------------------------------------------------

ggboxplot(
  db_total,y = "Virt.drift",
  labelOutliers = TRUE)

plot(density(db_total$Virt.drift, na.rm = T))

## Models in T1 
#(Correlation between embodiment and virtual drift)

brm_virtDT1 <- brm(
  Virt.drift ~ Location * Illusion +
    (1 + Location + Illusion || ID),
  data = db_total[db_total$Time == "T1",],
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores #Number of cores to use
)
rnd.eff$virtDT1.int <- as.data.frame(coef(brm_virtDT1))[,1]

brm_embT1 <- brm(
  Embodiment ~ Location * Illusion +
    (1 + Location + Illusion|| ID),
  data = db_total[db_total$Time == "T1",],
  family = skew_normal, #can handle skewed responses
  prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores #Number of cores to use
)
rnd.eff$brm_embT1.int <- as.data.frame(coef(brm_embT1))[,1]

#### Correlation between embodiment and virtual drift ----
BayesFactor::correlationBF(rnd.eff$brm_embT1.int,rnd.eff$virtDT1.int) #BF01=2.50
cor.test(rnd.eff$brm_embT1.int,rnd.eff$virtDT1.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=brm_embT1.int, y=virtDT1.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

## Models in T1 in co-location ----
#(Correlation between disembodiment and virtual drift in co-location)

brm_virtDT1col <- brm(
  Virt.drift ~ Illusion +
    (1 + Illusion || ID),
  data = db_total[db_total$Time == "T1" & db_total$Location == "Colocation",],
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores #Number of cores to use
) 
rnd.eff$virtDT1col.int <- as.data.frame(coef(brm_virtDT1col))[,1]

brm_disembT1col <- brm(
  Disembodiment ~ Illusion +
    (1 + Illusion|| ID),
  data = db_total[db_total$Time == "T1" & db_total$Location == "Colocation",],
  family = skew_normal, #can handle skewed responses
  prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  control = list(adapt_delta = 0.99)
)
rnd.eff$DisembT1col.int <- as.data.frame(coef(brm_disembT1col))[,1]

#### Correlation between disembodiment and virtual drift in co-location ----
BayesFactor::correlationBF(rnd.eff$DisembT1col.int,rnd.eff$virtDT1col.int) #BF01=2.23
cor.test(rnd.eff$DisembT1col.int,rnd.eff$virtDT1col.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=DisembT1col.int, y=virtDT1col.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

## Models in T1 in dislocation ----
#(Correlation between disembodiment and virtual drift in dislocation)

brm_virtDT1dis <- brm(
  Virt.drift ~ Illusion +
    (1 + Illusion || ID),
  data = db_total[db_total$Time == "T1" & db_total$Location == "Dislocation",],
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
)
rnd.eff$virtDT1dis.int <- as.data.frame(coef(brm_virtDT1dis))[,1]

brm_disembT1dis <- brm(
  Disembodiment ~ Illusion +
    (1 + Illusion|| ID),
  data = db_total[db_total$Time == "T1" & db_total$Location == "Dislocation",],
  family = skew_normal, #can handle skewed responses
  prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
  control = list(adapt_delta = 0.99)
)
rnd.eff$DisembT1dis.int <- as.data.frame(coef(brm_disembT1dis))[,1]

#### Correlation between disembodiment and virtual drift in dislocation ----
BayesFactor::correlationBF(rnd.eff$DisembT1dis.int,rnd.eff$virtDT1dis.int) #BF01=3.80
cor.test(rnd.eff$DisembT1dis.int,rnd.eff$virtDT1dis.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=DisembT1dis.int, y=virtDT1dis.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

# Virtual drift in FBI ----------------------------------------------------------------
db_fbiT1 <- db_total[db_total$Illusion == "FBI" & db_total$Time == "T1",]

#virtual drift
plot(density(db_fbiT1$Virt.drift))
ggboxplot(
  db_fbiT1,y = "Virt.drift",
  labelOutliers = TRUE)

brm_virtD.fbi.T1 <- brm(
  Virt.drift ~ Location +
    (1 || ID),
  data = db_fbiT1,
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores #Number of cores to use
)
rnd.eff$virtD.fbi.T1.int <- as.data.frame(coef(brm_virtD.fbi.T1))[,1]

#embodiment
plot(density(db_fbiT1$Embodiment))
ggboxplot(
  db_fbiT1,y = "Embodiment",
  labelOutliers = TRUE)

brm_emb.fbi.T1 <- brm(
  Embodiment ~ Location +
    (1 || ID),
  data = db_fbiT1,
  family = student,
  prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores #Number of cores to use
)
rnd.eff$emb.fbi.T1.int <- as.data.frame(coef(brm_emb.fbi.T1))[,1]

#disembodiment
plot(density(db_fbiT1$Disembodiment))
ggboxplot(
  db_fbiT1,y = "Disembodiment",
  labelOutliers = TRUE)

brm_dis.fbi.T1 <- brm(
  Disembodiment ~ Location +
    (1 || ID),
  data = db_fbiT1,
  family = student, #it's less influenced by outliers
  prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores #Number of cores to use
)
rnd.eff$dis.fbi.T1.int <- as.data.frame(coef(brm_dis.fbi.T1))[,1]

#### Correlation between virtual drift and embodiment ----
plot(density(rnd.eff$virtD.fbi.T1.int))
plot(density(rnd.eff$emb.fbi.T1.int))
plot(density(rnd.eff$dis.fbi.T1.int))

BayesFactor::correlationBF(rnd.eff$virtD.fbi.T1.int,rnd.eff$emb.fbi.T1.int) #BF01=3.80
cor.test(rnd.eff$virtD.fbi.T1.int,rnd.eff$emb.fbi.T1.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=virtD.fbi.T1.int, y=emb.fbi.T1.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)


ggboxplot(db_fbiT1,x= "Location", y="Virt.drift")
BayesFactor::correlationBF(db_fbiT1[db_fbiT1$Location == "Colocation",]$Virt.drift,
                           db_fbiT1[db_fbiT1$Location == "Colocation",]$Embodiment) #BF01=2.58
cor.test(db_fbiT1[db_fbiT1$Location == "Colocation",]$Virt.drift,
         db_fbiT1[db_fbiT1$Location == "Colocation",]$Embodiment, 
         na.rm=T)
ggplot(db_fbiT1[db_fbiT1$Location == "Colocation",], 
       aes(x=Virt.drift, y=Embodiment)) + 
  geom_point()+ 
  geom_smooth(method = lm)

BayesFactor::correlationBF(db_fbiT1[db_fbiT1$Location == "Dislocation",]$Virt.drift,
                           db_fbiT1[db_fbiT1$Location == "Dislocation",]$Embodiment) #BF10=1.66 anectdotal
cor.test(db_fbiT1[db_fbiT1$Location == "Dislocation",]$Virt.drift,
         db_fbiT1[db_fbiT1$Location == "Dislocation",]$Embodiment, 
         na.rm=T)
ggplot(db_fbiT1[db_fbiT1$Location == "Dislocation",], 
       aes(x=Virt.drift, y=Embodiment)) + 
  geom_point()+ 
  geom_smooth(method = lm)

#### Correlation between virtual drift and disembodiment----
BayesFactor::correlationBF(rnd.eff$virtD.fbi.T1.int,rnd.eff$dis.fbi.T1.int) #BF01=3.80 moderate
cor.test(rnd.eff$virtD.fbi.T1.int,rnd.eff$dis.fbi.T1.int, na.rm=T)
ggplot(rnd.eff, 
       aes(x=virtD.fbi.T1.int, y=dis.fbi.T1.int)) + 
  geom_point()+ 
  geom_smooth(method = lm)

BayesFactor::correlationBF(db_fbiT1[db_fbiT1$Location == "Colocation",]$Virt.drift,
                           db_fbiT1[db_fbiT1$Location == "Colocation",]$Disembodiment) #BF01=3.35 moderate
cor.test(db_fbiT1[db_fbiT1$Location == "Colocation",]$Virt.drift,
         db_fbiT1[db_fbiT1$Location == "Colocation",]$Disembodiment, 
         na.rm=T)
ggplot(db_fbiT1[db_fbiT1$Location == "Colocation",], 
       aes(x=Virt.drift, y=Disembodiment)) + 
  geom_point()+ 
  geom_smooth(method = lm)

BayesFactor::correlationBF(db_fbiT1[db_fbiT1$Location == "Dislocation",]$Virt.drift,
                           db_fbiT1[db_fbiT1$Location == "Dislocation",]$Disembodiment) #BF01=3.88 moderate
cor.test(db_fbiT1[db_fbiT1$Location == "Dislocation",]$Virt.drift,
         db_fbiT1[db_fbiT1$Location == "Dislocation",]$Disembodiment, 
         na.rm=T)
ggplot(db_fbiT1[db_fbiT1$Location == "Dislocation",], 
       aes(x=Virt.drift, y=Disembodiment)) + 
  geom_point()+ 
  geom_smooth(method = lm)

# Order of condition presentation ----
### Outliers ----------------------------------------------------------------
db_arm <- db_total[db_total$Illusion == "RHI",]

Q6.out <- db_arm %>%
  identify_outliers(Q6) #no outliers

ggboxplot(
  db_arm,y = "Q6",
  labelOutliers = TRUE)

plot(density(db_arm$Q6, na.rm = T))

#recode the variable to use the cumulative family distribution
db_arm$Q6r <- db_arm$Q6 + 4
db_arm$Q6r <- as.integer(db_arm$Q6r)
plot(density(db_arm$Q6r, na.rm = T))

## Q6 model ----
brm_Q6 <- brm(
  Q6r ~ Time * Location * Group +
    (1 + Time + Location || ID),
  data = db_arm,
  family = cumulative, #for ordinal regression
  #prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
)

# Posterior predictive check
pp_check(brm_Q6, ndraws = 500)

#### Results ----
summary(brm_Q6) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_Q6)

#Population level effects
#interaction plot
conditional_effects(brm_Q6, effects = "Group:Location")

## Prop drift model ----
brm_pd <- brm(
  Prop.drift.M ~ Time * Location * Group +
    (1 + Time + Location || ID),
  data = db_arm,
  family = student, #it's less influenced by outliers
  prior = c(
    set_prior("normal(0,0.5)", class = "b"),
    set_prior("normal(0,1)", class = "sd"),
    set_prior("normal(0,0.5)", class = "Intercept")
  ), #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = ncores, #Number of cores to use
)

# Posterior predictive check
pp_check(brm_pd, ndraws = 500)

#### Results ----
summary(brm_pd) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_pd)

#Population level effects
#interaction plot
conditional_effects(brm_pd, effects = "Group:Location")

## FBI Q6 check ----
#### Outliers ----------------------------------------------------------------
db_FBI <- db_total[db_total$Illusion == "FBI",]

db_FBI %>%
  identify_outliers(Q6) #no outliers

ggboxplot(
  db_FBI,y = "Q6",
  labelOutliers = TRUE)

plot(density(db_FBI$Q6, na.rm = T))

#recode the variable to use the cumulative family distribution
db_FBI$Q6r <- db_FBI$Q6 + 4
db_FBI$Q6r <- as.integer(db_FBI$Q6r)
plot(density(db_FBI$Q6r, na.rm = T))

db_FBI[db_FBI$order %in% c("A Ao L Lo","A Ao Lo L","A Ao Lo  L","L Lo A Ao","Lo L A Ao"),"Group"] <- "Colocation.first"
db_FBI[db_FBI$order %in% c("Ao A Lo L","Ao A L Lo","L Lo Ao A","Lo L Ao A"),"Group"] <- "Dislocation.first"


#### Model ----
brm_Q6.fbi <- brm(
  Q6r ~ Time * Location * Group +
    (1 + Time + Location || ID),
  data = db_FBI,
  family = cumulative, #for ordinal regression
  #prior = my_priors, #Probability distribution of the OUTCOME
  chains = 4, #Number of MCMC chains to be run
  iter = 8000, #Number of iterations per chain
  cores = 7, #Number of cores to use
)

# Posterior predictive check
pp_check(brm_Q6.fbi, ndraws = 500)

#### Results ----
summary(brm_Q6.fbi) #bulk-ESS needs to be > 100*Nchains (>400); Rhat needs to be = 1
plot(brm_Q6.fbi)

#Population level effects
#interaction plot
conditional_effects(brm_Q6.fbi, effects = "Group:Location")
