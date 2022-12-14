---
title: "Testing the Adaptive Market Hypothesis: Turkey Stock Market"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
 


- **Topic**: A test of adaptive market hypothesis via `time-varying AR`model



## Introduction  

The aim of the project and the research idea must be introduced. In addition, a brief Literature Survey must be given here about the research question.   
The efficient market hypothesis (EMH) is a hypothesis attributed to two different studies of Samuelson (1965) and Fama (1970) that states market prices reflect all available information completely, therefore the market is efficient. Fama (1970) categorized the empirical tests of efficiency into three forms; weak, semi-strong and strong. Market efficiency has been a subject for discussion in literature for a long time. After 30 years, Lo (2004) suggested alternative market hypothesis (AMH) as an alternative theory based on an evolutionary approach, also a great contribution to the behavioral finance field. AMH’s main aim is to take the “bounded rationality” concept into the market efficiency equation. While EMH implies stability of market efficiency, AMH implies dynamic efficiency of markets due to changing market conditions such as crises, financial bubbles. Unlike EMH, AMH indicates market transition through time from efficient period to inefficient period, or vice versa is possible. That implies time-varying market efficiency by providing a basis for this term project. The aim of this project is to examine AMH in the Borsa Istanbul Turkey stock market by using The Borsa Istanbul 100 Index (BIST100/XU100) and adopting a time-varying (TV) autoregressive (AR) model. It is expected to provide further evidence for AMH and explaining the evolution of market efficiency by measuring the degree of stock market efficiency for Turkey.

Changes in stock prices seem to have a fair game pattern. The random walk hypothesis states that stock prices are random and therefore, unpredictable. It makes the game fair. Since the random walk is associated with the efficient market hypothesis that implies the markets quickly and efficiently react to new information about stocks, so most of the fluctuations in prices can be explained by the changes in demand and supply of any given stock, causing a random walk, in prices. TVar will help to test the assumption of the random walk process. 

## Data

Data used in this paper consist of 5711 daily observations of XU100 index of the Borsa Istanbul Turkey stock market covering a 22-year period, from 01 July 1997 to 01 May 2019.


## Time Series Model  
A key assumption of standard time series models is that all parameters of the data generating model are constant(stationary) across measured time period. [Assumption of stationary]

Time-varying parameters are smooth and locally stationary.

Kernel-smoothing -> time varying parameters  by combining the estimates of several local models spanning the entire time series.
Bandwidth -> Parameter which determines how many observations close to an estimation point are used to estimate the model at the point.The smaller the "b" of the kernel function, the lower number of observations will be combined and larger sensitivity to detect changes in parameters over time. However, it means less data is used and estimates are less reliable. 
If b>1, it leads same estimates with stationary approach.


Time-varying coefficients model is:

$$ y_t  = \phi_{1t} y_{t-1}+ \phi_{2t} y_{t-2}+ \phi_{pt} y_{t-p} + a_t $$
where $$ a_t ∼ N(0,\sigma^2) $$ is white noise,
$a_t$ is an error term with $E[\epsilon_t]=0,    E[a_t^2]=\sigma^2$ and $E[a_ta_{t-m}] = 0$ for all $m≠0$



In ordinary time series analysis,$ϕ$'s assumed to be constant while in a time-varying approach it is supposed that coefficients of AR models vary over time.In ordinary AR models t component of coefficients don't exist.

If a process is strictly stationary, the distribution of yt and
all joint distributions of y random variables are the same at all time
points, and are thus time-invariant.

EMH,
$E[x_t|I_{t-1}]=0$

$$E[x_t|I_{t-1}]=0=\beta_1 u_{t-1} + \beta_2 u_{t-2} + ... $$ 

EMH holds if and only $\beta_i$ for all $i$.

$$ x_t  = \alpha_0 +  \alpha_{1} x_{t-1}+ ....+ \alpha_q x_{t-q}+ u_t $$

$$ x_t  = \alpha_{0,t} +  \alpha_{1,t} x_{t-1}+ ....+ \alpha_{q,t} x_{t-q}+ u_t $$
where $u_t$ satisfies $E[u_t]=0 E[u_t^2]=0$ and $E[u_t u_{t-m}] = 0$ for all $m=0$

Parameter dynamics restricts the parameters in estimation of TV-AR model using data.

$$ \alpha_{l,t} = \alpha_{l,t-1} + v_{l,t},  (l=1,2,...,q) $$
where $v_{l,t}$ satisfies $E[v_{l,t}]=0, E[v_{l,t} v_{l,t-m}]=0$ and $E[v_{l,t}^2] = 0$ for all $m$ and $l$.




  

## Results 
```{r} 

library(lubridate)
library(quantmod)
library(tvReg)
library(tsbox)
library(tseries)
library(PerformanceAnalytics)

##

tt <- (1:1000)/1000
beta <- cbind(0.5 * cos(2 * pi * tt), (tt - 0.5)^2)
y <- numeric(1000)
y[1] <- 0.5
y[2] <- -0.2
## y(t) = beta1(t) y(t-1) + beta2(t) y(t-2) + ut
for (t in 3:1000) {
    y[t] <- y[(t - 1):(t - 2)] %*% beta[t, ] + rnorm(1)
}
Y <- tail(y, 500)

## ar.ols & tvAR comparison 
## in a plot
model.ar.2p <- ar.ols(Y, aic = FALSE, order = 2, intercept = FALSE, demean = FALSE)
model.tvAR.2p <- tvAR(Y, p = 2, type = "none", est = "ll")

## Simulate a AR(1) process with coefficients depending on z
z <- runif(2000, -1, 1)
beta <- (z - 0.5)^2
y <- numeric(2000)
y[1] <- 0.5
error <- rnorm(2000)
## y(t) = beta1(z(t)) y(t-1) + ut
for (t in 2:2000) {
    y[t] <- y[(t - 1)] %*% beta[t] + error[t]
}

## Remove initial conditions effects
Z <- tail(z, 1500)
Y <- tail(y, 1500)

## Coefficient estimates of process Y with ar.ols and tvAR
model.ar.1p <- ar.ols(Y, aic = FALSE, order = 1, intercept = FALSE, demean = FALSE)
model.tvAR.1p.z <- tvAR(Y, p = 1, z = Z, type = "none", est = "ll")

## 80% confidence interval using normal wild bootstrap for object of the class
## attribute tvar with 200 bootstrap resamples
model.tvAR.80 <- confint(model.tvAR.1p.z, tboot = "wild2", level = 0.8, runs = 50)

## Plot coefficient estimates of objects of the class attribute tvar.
plot(model.tvAR.80)
summary(model.tvAR.80)
print(model.tvAR.80)



#Project 

XU <- getSymbols("XU100.IS", return.class="xts", from="1997-07-01", to="2019-07-01")
head(XU100.IS)

plot(as.zoo(XU100.IS))
plot(XU100.IS[,-4])

str(XU100.IS)

Clo <- XU100.IS$XU100.IS.Close
summary(Clo)
#close has 215 NA's. NAs are almost 3.7% of total data. we can't use na.omit()
#There is not a strong trend in time series. spline interpolation will be better than linear interpolation.
CXU <-na.spline(Clo)
summary(CXU)

adf.test(CXU, alternative = c("stationary", "explosive"),
        k = trunc((length(CXU)-1)^(1/3)))





plot(CXU)



ABC <- na.trim(na.approx((window(Clo))))
adf.test(ABC, alternative = c("stationary", "explosive"),
        k = trunc((length(ABC)-1)^(1/3)))

plot(ABC)

class(ABC)

head(ABC)
ABCV1 <- data.frame(ABC)

ABCV2 <- ABCV1$XU100.IS.Close


ABCTV <- tvAR(
 ABCV2,
  p=1,
  z = NULL,
  ez = NULL,
  bw = NULL,
  cv.block = 0,
  type = c("none"),
  singular.ok = TRUE
)
print(ABCTV)
plot(ABCTV)

##80% CIs, 50 replications

model.ABCTV <- confint(ABCTV, tboot = "wild2", level = 0.8, runs = 50)
plot(model.ABCTV)





ABCTV0 <- tvAR(
 ABCV2,
  p=1,
  z = NULL,
  ez = NULL,
  bw = 0.6,
  cv.block = 0,
  type = c("none"),
  singular.ok = TRUE
)
summary(ABCTV0)
print(ABCTV0)
plot(ABCTV0)


#95% CIs, 100 replications


model.ABCTV0 <- confint(ABCTV0, tboot = "wild2", level = 0.95, runs = 100)
plot(model.ABCTV0)


 ##Coefficient estimates of process Y with ar.ols and tvAR
# model.ar.2p <- ar.ols(Y, aic = FALSE, order = 2, intercept = FALSE, demean = FALSE)
# model.tvAR.2p <- tvAR(Y, p = 2, type = "none", est = "ll")

#short period & different bandwiths
XUBw <- getSymbols("XU100.IS", return.class="xts", from="2017-07-01", to="2019-07-01")

XUBw <- XU100.IS$XU100.IS.Close
XUB <- data.frame(XUBw)
# 
# X0 <- tvAR(
#  XUB,
#  p=1,
#   z = NULL,
#   ez = NULL,
#   bw = 0.6,
#   cv.block = 0,
#   type = c("none"),
#   singular.ok = TRUE
# )
# print(X0)
# plot(X0)
# 
# X1 <- tvAR(
#  XUB,
#   p=1,
#   z = NULL,
#   ez = NULL,
#   bw = 0.2,
#   cv.block = 0,
#   type = c("none"),
#   singular.ok = TRUE
# )
# print(X1)
# plot(X1)
# 
# X2 <- tvAR(
#  XUB,
#   p=1,
#   z = NULL,
#   ez = NULL,
#   bw = 0.9,
#   cv.block = 0,
#   type = c("none"),
#   singular.ok = TRUE
# )
# print(X2)
# plot(X2)
# 
# X3 <- tvAR(
#  XUB,
#   p=1,
#   z = NULL,
#   ez = NULL,
#   bw = 1.5,
#   cv.block = 0,
#   type = c("none"),
#   singular.ok = TRUE
# )
# print(X3)
# plot(X3)

#I have tried everything, but these are not working.



```




## Conclusion  
 If coefficients are at the same level, it is invariant, meaning that the autoregressive process of stock prices doesn't change with time and accordingly specific events such as bubbles, crises. If it is decreasing or increasing it means that efficiency changing over time, if coefficients have peaks and downs related to those specific events it means that we have findings that support Adaptive Market Hypothesis.
The time-varying autoregressive coefficient is slightly decreasing over time. For the first-order lag, it is possible to mention lower predictability of stock returns and market goes toward efficiency. In the TV-AR model, the deviation of coefficients is the proxy for the degree of market inefficiency. The market is generally efficient. There is no specific deviation in general. We observe a very little change in market efficiency around the 2001 crisis and low variation between 2008-2009 the Great Recession. In Turkey, stock market efficiency is both varying over time and influenced by the market conditions. Empirical results are not providing a solid support for Adaptive Market Hypothesis, however, the behavior of the market is pretty much in line with the hypothesis regarding coefficients' decreasing behaviors.


## References

 
Fama, E., (1970), “Efficient Capital Markets: A Review of Theory and Empirical Work”, The Journal of Finance, 25(2), 383-417. Lo, A. W., (2004), “The Adaptive Markets Hypothesis: Market Efficiency from an Evolutionary Perspective”, Journal of Portfolio Management. Samuelson, P. A., (1965), ”Rational Theory of Warrant Pricing”. Industrial Management Review 6 (2): 13 39.Trung, D. P. T., Quang, H. P., (2019), "Adaptive Market Hypothesis: Evidence from the Vietnamese Stock Market," Journal of Risk and Financial Management, MDPI, Open Access Journal, vol. 12(2), pages 1-16.


