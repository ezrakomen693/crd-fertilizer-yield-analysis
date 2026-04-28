# =====================================================================
# CRD Analysis: CRD analysis - Fertilizer yield study
# Objective:
# To evaluate whether fertilizer type significantly affects
# crop yield under a Completely Randomized Design (CRD)
# Design: Completely Randomized Design is used because experimental
# units are assumed to be homogeneous . If heterogenety exists e.g 
# soil degradation, a Randomized Complete Block Design would be 
# more appropriate
# Response variable: Yield (kg per plot)
# Factor: Fertilizer type (A, B, C)
# Dataset: Simulated fertilizer trial (4 treatments * 5 replicates)
# Background:
# Optimizing fertilizer selection is critical for improving agricultural
# productivity. Controlled experiments allow estimation of casual effects
# of fertilizertreatments on yield.
# =======================================================================

# load libraries
library(effectsize)       # effect size
library(car)              # Levene's test
library(agricolae)        # Fisher's LSD
library(ggplot2)          # Visualisation
library(dplyr)            # Data wrangling
library(performance)      # Model diagnostics
library(FSA)              # Dunn's test
# Create working directory for results
dir.create("results",showWarnings = FALSE)
# Create working directory for plots
dir.create("plots",showWarnings = FALSE)

# Enter data
yield <- c(12,14,11,13,10,  # Treatment A
         18,20,17,19,16,  # Treatment B
         15,13,16,14,12,  # Treatment C
         22,24,21,23,20)  # Treatment D
treatment <- factor(rep(c("A","B","C","D"),each = 5))
set.seed(123)
df <- data.frame(yield = yield,treatment = treatment)
#===============================================================================
# This is a pure CRD so there is no blocking structure.
# Potential Sources of bias:
# - Soil fertility variation across plots
# - Unequal irrigation or sunlight exposure
# - Measurement error in yield

# Confounding:
# If plot conditions differ systematically, treatment effects may be confounded
# with environmental effects.

# External validity:
# Results generalise only to similar controlled environments. Field conditions 
# may introduce additional variability.
#===============================================================================

# Exploratory Summary
tapply(yield, treatment, mean)
tapply(yield, treatment, sd)
#===============================================================
# Statistical method:
# One way ANOVA is used to compare mean yields across >2 groups.
# Assumptions:
# 1. Independence of observations
# 2. Normality of residuals
# 3. Homogeneity of variances
#================================================================

# Fit the One-Way ANOVA Model
model <- aov(yield~treatment,data = df)
summary(model)
# Save ANOVA table
capture.output(summary(model), file = "results/anova_results.txt")
#===================================================================
# Interpretation of ANOVA results:
# If p < 0.05, we reject the null hypothesis and conclude that at 
# least one fertilizer treatment differs in mean yield. This indicates
# that fertilizer type has a statistically significant effect on 
# crop yield.
#===================================================================

# Add effect size
eta_squared(model)
#===================================================================
# Effect size interpretation:
# eta^2 = SS_treatment / SS_total
# Eta-squared quantifies the proportion of total variance explained
# by trearment.
# small = 0.01, medium = 0.06, large = 0.14+
# A large effect suggests the difference is not only statistically 
# significant but also practically meaningful in agriculture.
#==================================================================


# check assumptions
# Residual diagnostic plots (base R)
par(mfrow = c(2,2), mar = c(4, 4, 2, 1), cex = 1)
plot(model)

# Reset layout
par(mfrow = c(1, 1))

# Normality of residuals
shapiro.test(residuals(model))
# Ho: Residuals are normally distributed
# We fail to reject null hypothesis if p > 0.05

# Homogeneity of variance
leveneTest(yield~treatment,data = df)
# HO: Variance are equal across groups
# We fail to reject if p > 0.05

#  Model diagnostics (performance package)
p <- check_model(model)
png("plots/check_model.png", width = 1400, height = 1000, res = 150)
plot(check_model(model))
dev.off()
check_heteroscedasticity(model)
check_normality(model)
#=========================================================================
# Assumption diagnostics decision:
# -If normality and homogeneity hold, then proceed with ANOVA
# -If violated: 
#    1. Use transformation(log,sqrt).  
#    2. Otherwise you can switch to non-parametric e.g Kruskal-Wallis test
#=========================================================================

# Post-hoc:Fisher's LSD
lsd_result <- LSD.test(model,"treatment",p.adj = "none")
print(lsd_result)
lsd_result$groups   # Letters groupings
# It is less conservative . It is used when the number of comparison is small

# Post-hoc:Turkey's HSD
TukeyHSD(model,conf.level = 0.95)
# Generate the Tukey test with grouping letters
tukey_out <- HSD.test(model, "treatment", group = TRUE)
# Extract Tukey letters
tukey_letters <- tukey_out$groups %>%
  tibble::rownames_to_column("treatment") %>%
  select(treatment, groups)
# Print the results and the letters
# It controls family-wise error rate print(tukey_out)
print(tukey_out$groups)
plot(TukeyHSD(model))
capture.output(TukeyHSD(model), file = "results/tukey_results.txt")
#===============================================================================
#Post-hoc interpretation:
# Treatments sharing the same letter are not significantly different
# The ANOVA results show a significant effect of fertilizer type on yield 
# (p < 0.05).
# Typically:
# -Fertilizer D shows the highest yield
# -Fertilizer A shows the lowest yield
# Fertilizer D increases yield by ~8-10 kg relative to A, representing a large 
# effect (n^2>0.14), suggesting strong agronomic benefit, hence provides superior 
# performance under the tested conditions
#===============================================================================

# Non-parametric alternative
# Krustal-Wallis Test (non-parametric equivalent of one-way ANOVA)
kruskal.test(yield~treatment,data = df)

# Run Dunn's Test (non-parametric post-hoc)
dunnTest(yield~treatment,data = df,method = "bh")
#===============================================================================
# Robustness check:
# The Kruskal-Wallis and Dunn tests confirm whether results remain consistent 
# without normality assumptions.
# Agreement with ANOVA strengthens confidence in findings.
#===============================================================================

# Visualisation: Yield Distribution by Fertilizer Treatment
summary_data <- df %>%
  group_by(treatment) %>%
  summarise(
    mean = mean(yield),
    se = sd(yield)/sqrt(n()),
    .groups = "drop"
  )

p <- ggplot(df, aes(x = treatment,y = yield, fill = treatment))+
geom_boxplot(alpha = 0.7)+ 
geom_jitter(width = 0.2, size = 3, alpha = 0.7)+
labs(title = "Yield Distribution by Fertilizer Treatment",
     x = "Treatment",
     y = "Yield(kg)"
     )+  
     theme_minimal()+    
     theme(legend.position = "none")  

print(p)

# Saving the plot
png("plots/Yield Distribution by Fertilizer Treatment.png",width = 1400,height = 1000,res = 150)
plot(p)
dev.off()

#===============================================================================
# Conclusion:
# Fertilizer type significantly affects crop yield.
# Fertilizer D yields the highest production, with an estimated increase of
# 8-10kg per plot compared to baseline.
# The effect is both statistically significant and practically important, 
# supporting it's potential adoption in similar settings.
# However, results are conditional on CRD assumptions and should be validated
# under field conditions with possible blocking.

m <- sessionInfo()
m

capture.output((m), file = "results/sessionInfo_results.txt")
