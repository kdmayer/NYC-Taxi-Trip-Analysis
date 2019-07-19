# Analyzing traffic in NYC 

Goal:

Analyze NYC's taxi trips in order to derive guidelines to improve transportation within the city

Files:

* Congestion_Areas.R:

  * Leveraging cluster analysis, this script identifies high congestion areas
  
* Travel_Time_Predictor.R:

  * Using a linear SVM, this script predicts travel times from one point to another at a given time of the day 
  
Please find more information in "Case Study - Traffic in NYC.ppt"

# Chapter 1: Dataset Description

In a first step, the given dataset of taxi trips in New York City has been filtered to one day, i.e. January 12th, 2017. In order to understand customer behavior and the local circumstances better, we have calculated how much time (in seconds) each trip actually took (new feature: trip_duration) and added another feature by computing the average miles per hour of a trip by dividing a trip’s length by its duration (new feature: mph). The numbers below show summary statistics for some preselected features in our dataset and will help us to get a better understanding of what we are looking at before starting our model-based analysis. Hence, by describing and evaluating the summary statistics, we try to understand some behavioral patterns of NYC’s residents when they hail a taxi.

* Trip Duration:

On January 12th, 2017 each trip took about 15.7 minutes on average. Since the median is lower (11.16 minutes) we can assume that the data has quite some outliers that are affecting the average significantly. It is interesting to observe that 75% of all taxi trips do not exceed 18 minutes. Yet, with a maximum trip duration of approximately 23 hours, it might be reasonable to assume that some trip duration records have occurred by error and should be discarded during the data pre-processing phase before building any models.
Diving deeper into the trip duration numbers, 11 minutes as a median trip duration seems to be quite a low number for a city like New York, especially when keeping the high traffic volume in mind. To make a reality check and gain a better understanding for our dataset, we delved into Google Maps to examine how a typical taxi trip, i.e. with a median trip length of around 1.6 miles and a median trip duration of around 11 minutes, could look like in NYC.
The following map shows a 1.5 miles trip from the Empire State Building to the Modern Museum of Art. The predicted trip duration of Google Maps is between 10 and 26 minutes, an estimate that highlights the uncertainty that passengers are affected by when using a cab in NYC. The second map shows the competing subway trip that is offered for this route. The same trip could be accomplished in 15 minutes. This means that a subway trip could be 11 minutes faster or 5 minutes longer, excluding waiting times at the platform or when calling taxi.
Thus, by building a statistical model that is capable of predicting taxi trip durations accurately, we might give people a better understanding of their transport options and could incentivize more people to use public transport options which could potentially reduce the likelihood of traffic congestions, especially during rush hour. Such models will be evaluated during Chapter 2, where we built travel time prediction models based on SVM and ANN algorithms.

* Passenger Count:

Looking at the passenger count numbers, it becomes obvious that taxi trips in NYC are typically trips with only 1 passenger. Looking at the upper quartile, we can conclude that 75% of all trips have 2 passengers at maximum. Thus, in only 25% of all cases, the cab is transporting more than 2 passengers.

* Trip distance:

The maximum trip distance on January 12th, 2017 was 80.7 miles. This is in strong contrast to the average and median trip distances recorded on that same day, amounting to 2.848 miles and 1.6 miles respectively. As in the case of trip durations, it appears to be that we have some significant outliers in our trip distance recordings that should be treated during the data pre-processing phase. Surprisingly, taking a deeper look at all trip distance records reveals that there are quite some trips that are above 20 miles. Yet, the great majority of 75% is below 2.95 miles. 50% percent of all trips are even within one mile.

* Payment Type:

There are six different options for payment types available in NY (1= Credit card, 2= Cash, 3= No charge, 4= Dispute, 5= Unknown, 6= Voided trip). Only two of them are actually payment methods. Looking at the third quartile, we could conclude that roughly 75% of all passengers pay their trips with credit card, while roughly 25% of all passengers prefer cash. Calculating the exact figures, we can observe that passengers paid by credit card (event1) in roughly 69% of all cases. 30% of the passengers used cash as their payment method and less than 0.5 % made a trip with no charge. Only 0,1377% of the drives ended up in a dispute.

* Total Amount:

The average amount a trip has cost on January 12th, 2017 was $16.08 with 75% of all trips being cheaper than $17.3, a figure that exemplifies that most taxi trips in NYC are short distance trips. Only 12.5% of all trips costed more than $25. The maximum value shows that outliers should be expected within this feature, too.

# Section 2: Evaluating NYC’s taxi trips

Before building different predictive models, we decided to start off by trying to understand the underlying structure of our dataset with the help of clustering. Algorithms for clustering are unsupervised algorithms that might help us to identify distinct subgroups in the dataset that share similarities with respect to some given features. While many clustering applications focus on continuous variables, our NYC taxi trip dataset comprises numerous categorical variables. Thus, approaches like k-means clustering that were discussed during the lecture and assignments are not viable for this dataset. As a result, we decided to implement a cluster algorithm that is capable of dealing with quantitative and qualitative variables, i.e. a clustering approach based on the Gower distance, forming partitions around medoids. The respective number of clusters was derived by calculating a decision metric called silhouette width.

* Motivation:

Before setting up the clustering model, we needed to think about what information we would like to feed into such a model. For this assignment, we decided to form partitions based on average miles per hour (mph), pick up location (PULocationID) and drop off location (DOLocationID), to identify districts where traffic is especially slow, e.g. due to heavy traffic caused by bottlenecks with respect to road capacity. Identifying such gridlock hotspots could help authorities by providing them with crucial information on where additional public transport capacity is needed.
When setting up our clustering model, we needed to think about three fundamental steps:

1. Calculating distance
2. Choosing a clustering algorithm
3. Determine the number of clusters

* Calculating Distance:

As introduced in the lecture and assignments, a common distance metric used for implementing clustering models is the Euclidean distance. Yet, such an approach is only valid for continuous variables and cannot be used when clustering qualitative variables such as pick up ID or drop off ID. Fortunately, there is another distance metric, namely the so-called Gower distance, that is able to deal with mixed data types.

As all clustering algorithms, the Gower distance establishes some notion of similarity between distinct observations in order to form partitions. The Gower distance thereby utilizes an intuitive approach. In a nutshell, every feature can have its own particular distance metric that works well for that type. Afterwards, computed distances are scaled to fall between zero and one and are eventually combined by a
