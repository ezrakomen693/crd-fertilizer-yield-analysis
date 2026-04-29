CRD Analysis: Fertilizer Yield Study


Overview


This project evaluates whether fertilizer type significantly affects crop yield using a Completely Randomized Design (CRD).

The workflow includes:

Data simulation

Exploratory analysis

One-way ANOVA

Effect size estimation

Assumption diagnostics

Post-hoc comparisons (LSD & Tukey)

Non-parametric robustness checks

Visualization

Reproducibility outputs



 Objective

 

To assess whether different fertilizer treatments produce statistically significant differences in crop yield.


Experimental design

Design: Completely Randomized Design (CRD)

Treatments: A, B, C, D

Replicates: 5 per treatment

Response Variable: Yield (kg per plot)


Justification



CRD is appropriate because experimental units are assumed homogeneous.
If heterogeneity (e.g., soil variation) exists, a Randomized Complete Block Design (RCBD) would be more suitable.

Bias, Confounding, External Validity

Potential Sources of Bias

Soil fertility variation

Unequal irrigation or sunlight

Measurement error


Confounding



Systematic environmental differences may distort treatment effects.

External Validity

Findings generalize only to similar controlled environments; real field variability may differ.


Data generation



The dataset is simulated:

yield <- c(12,14,11,13,10,
           18,20,17,19,16,
           15,13,16,14,12,
           22,24,21,23,20)

treatment <- factor(rep(c("A","B","C","D"), each = 5))
df <- data.frame(yield = yield, treatment = treatment)


Exploratory Data Analysis



tapply(yield, treatment, mean)
tapply(yield, treatment, sd)

Purpose:

Compare mean yield across treatments

Assess variability



Statistical Method



One-Way ANOVA Model

Y_{ij} = \mu + \tau_i + \epsilon_{ij}

Assumptions

1. Independence


2. Normality of residuals


3. Homogeneity of variances




Model fitting



model <- aov(yield ~ treatment, data = df)
summary(model)

Results are saved:

capture.output(summary(model), file = "results/anova_results.txt")


ANOVA interpretation

If p < 0.05 → Reject H₀ → Fertilizer affects yield

If p ≥ 0.05 → No significant effect

 Effect size

eta_squared(model)

Interpretation

η² = SS_treatment / SS_total

Small: 0.01

Medium: 0.06

Large: ≥ 0.14


A large effect implies practical agricultural importance, not just statistical significance.


 Assumption diagnostics

Residual plots

plot(model)

Normality Test

shapiro.test(residuals(model))

H₀: Residuals are normal

Accept if p > 0.05


Homogeneity Test



leveneTest(yield ~ treatment, data = df)

H₀: Equal variances

Accept if p > 0.05


Advanced diagnostics



check_model(model)
check_heteroscedasticity(model)
check_normality(model)

Plot saved:

png("plots/check_model.png")
plot(check_model(model))
dev.off()


Diagnostic Decisions



If assumptions hold → proceed with ANOVA

If violated:

Apply transformation (log, sqrt)

Or use non-parametric tests



Post-hoc Analysis



Fisher’s LSD (less conservative)

LSD.test(model, "treatment", p.adj = "none")

Tukey’s HSD (controls family-wise error)

TukeyHSD(model)
HSD.test(model, "treatment", group = TRUE)

Results saved:

capture.output(TukeyHSD(model), file = "results/tukey_results.txt")

Post-hoc Interpretation

Treatments sharing the same letter → not significantly different

Typically observed:

Fertilizer D → highest yield

Fertilizer A → lowest yield


Estimated difference: ~8–10 kg increase (D vs A)

Large effect size (η² > 0.14) → strong agronomic impact


Non-parametric robustness check

Kruskal-Wallis Test

kruskal.test(yield ~ treatment, data = df)

Dunn’s Test

dunnTest(yield ~ treatment, data = df, method = "bh")

Interpretation

Consistency with ANOVA strengthens inference robustness.


 Visualization

 

ggplot(df, aes(x = treatment, y = yield, fill = treatment)) +
  geom_boxplot() +
  geom_jitter()

Saved as:

plots/Yield Distribution by Fertilizer Treatment.png


Outputs generated

Results folder

anova_results.txt

tukey_results.txt

sessionInfo_results.txt


Plots folder

Diagnostic plots

Yield distribution plot



 Reproducibility

Run the script:

source("CRD Analysis.R")

Session info is saved for reproducibility:

sessionInfo()


Conclusion



Fertilizer type significantly affects yield

Fertilizer D produces the highest yield

Increase of ~8–10 kg per plot vs baseline

Effect is both statistically and practically significant


Results depend on CRD assumptions and controlled conditions.
Field validation with blocking is recommended.


 Extensions

 

Upgrade to **RCBD** for heterogeneous fields

Fit **linear mixed models**

Perform **power analysis**

Apply to real agricultural datasets


 Author
 
* GitHub: [@ezrakomen693](https://github.com/ezrakomen693)

