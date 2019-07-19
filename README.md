# Analyzing traffic in NYC 

Goal:

Analyze NYC's taxi trips in order to derive guidelines to improve transportation within the city

Files:

* Congestion_Areas.R:

  * Leveraging cluster analysis, this script identifies high congestion areas
  
* Travel_Time_Predictor.R:

  * Using a linear SVM, this script predicts travel times from one point to another at a given time of the day 
  
Please find more information below and in "Case Study - Traffic in NYC.ppt"

# Chapter 1: Dataset Description

In a first step, the given dataset of taxi trips in New York City was filtered to one day, i.e. January 12th, 2017, to obtain a quick overview on potential patterns in the massive dataset from a smaller sample. In order to understand customer behavior and the local circumstances better, we have calculated how much time (in seconds) each trip actually took (new feature: trip_duration) and added another feature by computing the average miles per hour of a trip by dividing a trip’s length by its duration (new feature: mph). The numbers below show summary statistics for some preselected features in our dataset and will help us to get a better understanding of what we are looking at before starting our model-based analysis. Hence, by describing and evaluating the summary statistics, we try to understand some behavioral patterns of NYC’s residents when they hail a taxi.

![Summary Statistics](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/SummaryStatistics.png)

* Trip Duration:

On January 12th, 2017 each trip took about 15.7 minutes on average. Since the median is lower (11.16 minutes) we can assume that the data has quite some outliers that are affecting the average significantly. It is interesting to observe that 75% of all taxi trips do not exceed 18 minutes. Yet, with a maximum trip duration of approximately 23 hours, it might be reasonable to assume that some trip duration records have occurred by error and should be discarded during the data pre-processing phase before building any models.
Diving deeper into the trip duration numbers, 11 minutes as a median trip duration seems to be quite a low number for a city like New York, especially when keeping the high traffic volume in mind. To make a reality check and gain a better understanding for our dataset, we delved into Google Maps to examine how a typical taxi trip, i.e. with a median trip length of around 1.6 miles and a median trip duration of around 11 minutes, could look like in NYC.
The following map shows a 1.5 miles trip from the Empire State Building to the Modern Museum of Art. The predicted trip duration of Google Maps is between 10 and 26 minutes, an estimate that highlights the uncertainty that passengers are affected by when using a cab in NYC. The second map shows the competing subway trip that is offered for this route. The same trip could be accomplished in 15 minutes. This means that a subway trip could be 11 minutes faster or 5 minutes longer, excluding waiting times at the platform or when calling taxi.
Thus, by building a statistical model that is capable of predicting taxi trip durations accurately, we might give people a better understanding of their transport options and could incentivize more people to use public transport options which could potentially reduce the likelihood of traffic congestions, especially during rush hour. Such models will be evaluated during Chapter 2, where we built travel time prediction models based on SVM and ANN algorithms.

![TripDuration_Car](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/GoogleMapsPredictionCar.png)
![TripDuration_PT](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/GoogleMapsPredictionPT.png)

* Passenger Count:

Looking at the passenger count numbers, it becomes obvious that taxi trips in NYC are typically trips with only 1 passenger. Looking at the upper quartile, we can conclude that 75% of all trips have 2 passengers at maximum. Thus, in only 25% of all cases, the cab is transporting more than 2 passengers.

* Trip distance:

The maximum trip distance on January 12th, 2017 was 80.7 miles. This is in strong contrast to the average and median trip distances recorded on that same day, amounting to 2.848 miles and 1.6 miles respectively. As in the case of trip durations, it appears to be that we have some significant outliers in our trip distance recordings that should be treated during the data pre-processing phase. Surprisingly, taking a deeper look at all trip distance records reveals that there are quite some trips that are above 20 miles. Yet, the great majority of 75% is below 2.95 miles. 50% percent of all trips are even within one mile.

* Payment Type:

There are six different options for payment types available in NY (1= Credit card, 2= Cash, 3= No charge, 4= Dispute, 5= Unknown, 6= Voided trip). Only two of them are actually payment methods. Looking at the third quartile, we could conclude that roughly 75% of all passengers pay their trips with credit card, while roughly 25% of all passengers prefer cash. Calculating the exact figures, we can observe that passengers paid by credit card (event1) in roughly 69% of all cases. 30% of the passengers used cash as their payment method and less than 0.5 % made a trip with no charge. Only 0,1377% of the drives ended up in a dispute.

* Total Amount:

The average amount a trip has cost on January 12th, 2017 was $16.08 with 75% of all trips being cheaper than $17.3, a figure that exemplifies that most taxi trips in NYC are short distance trips. Only 12.5% of all trips costed more than $25. The maximum value shows that outliers should be expected within this feature, too.

# Chapter 2: Evaluating NYC’s taxi trips

Before building different predictive models, we decided to start off by trying to understand the underlying structure of our dataset with the help of clustering. Algorithms for clustering are unsupervised algorithms that might help us to identify distinct subgroups in the dataset that share similarities with respect to some given features. While many clustering applications focus on continuous variables, our NYC taxi trip dataset comprises numerous categorical variables. Thus, approaches like k-means clustering that were discussed during the lecture and assignments are not viable for this dataset. As a result, we decided to implement a cluster algorithm that is capable of dealing with quantitative and qualitative variables, i.e. a clustering approach based on the Gower distance, forming partitions around medoids. The respective number of clusters was derived by calculating a decision metric called silhouette width.

* Motivation:

Before setting up the clustering model, we needed to think about what information we would like to feed into such a model. For this assignment, we decided to form partitions based on average miles per hour (mph), pick up location (PULocationID) and drop off location (DOLocationID), to identify districts where traffic is especially slow, e.g. due to heavy traffic caused by bottlenecks with respect to road capacity. Identifying such gridlock hotspots could help authorities by providing them with crucial information on where additional public transport capacity is needed.
When setting up our clustering model, we needed to think about three fundamental steps:

1. Calculating distance
2. Choosing a clustering algorithm
3. Determine the number of clusters

* Calculating Distance:

As introduced in the lecture and assignments, a common distance metric used for implementing clustering models is the Euclidean distance. Yet, such an approach is only valid for continuous variables and cannot be used when clustering qualitative variables such as pick up ID or drop off ID. Fortunately, there is another distance metric, namely the so-called Gower distance, that is able to deal with mixed data types.

As all clustering algorithms, the Gower distance establishes some notion of similarity between distinct observations in order to form partitions. The Gower distance thereby utilizes an intuitive approach. In a nutshell, every feature can have its own particular distance metric that works well for that type. Afterwards, computed distances are scaled to fall between zero and one and are eventually combined by a linear combination of weights, e.g. a simple average, to create the final distance matrix.

* Choosing a clustering algorithm:

Similar to the k-means clustering algorithm that we have learnt throughout the course and its assignments, we decided to use a method known as k-medoids clustering. K-medoids clustering is typically used when one’s clustering approach cannot rely on Euclidean distance metrics, e.g. because there are non-continuous features. Medoids are inherently similar to the concept of means or centroids, but generally need to be members of the data set. A medoid is thereby defined as a representative object of a cluster whose average dissimilarity to all other object in the cluster is minimal. The respective realization of k-medoid clustering is known as Partitioning Around Medoids (PAM).

* Selecting the number of clusters:

Selecting an appropriate amount of cluster centers k is more art than science. In the lecture, we spoke about two approaches on how to determine the number of cluster centers.
The first approach was to use a rule of thumb, which determines the number of clusters k by the following formula: 𝑘=𝑠𝑞𝑟𝑡(𝑛/2)

Since we deal with a large dataset containing several thousand data points, such an approach is not viable because it severely impairs our ability to infer meaningful information from the clusters, simply because the number of clusters k is too large.

The second approach we were taught in the lecture was to use the so-called elbow method, which plots a measure of homogeneity or heterogeneity against the respective number of clusters and determines an appropriate k by the so-called elbow point. In this assignment, we followed a similar route and calculated the silhouette width, a metric that describes how similar an observation in a given cluster is compared to the closest neighboring cluster. Values for silhouette width range between -1 and 1, where higher values are better. After calculating the silhouette width for clusters ranging from 2 to 10 for the partitioning around medoids (PAM) algorithm, we decided to go with 5 cluster centers.

* Cluster interpretation:

![ClusterInterpretation](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/ClusterInterpretation.PNG)

When examining our cluster partition as a whole, one observation that we can make is that Midtown Manhattan, i.e. areas south of Central Park, are very popular pick up location IDs, encompassing IDs such as 161, 162, 186, 170 and 234, while Upper Manhattan is a common drop off location ID, encompassing IDs such as 236, 237, and 239. This could be due to the fact that many people who visit or work in Midtown Manhattan commute back to their residential area or hotel by cab. However, if this pattern is mainly due to commuters, we should probably see a similar behavior in the reverse direction, which is not the case here. This might be due to the fact that we selected at random only a small sample of 1000 observations from January 12th, 2017. Thus, our distribution of selected observations might be skewed towards the evening hours, which could explain the observed pattern, as people working in Midtown Manhattan, e.g. highly paid employees in the financial industry, might return home from work by cab.

Comparing the clusters with each other, it is interesting to see that one cluster, namely cluster 1, is characterized by far higher average mph values than all the other clusters. This might indicate that for the respective pick up and drop off locations, the existing road infrastructure is able to handle the traffic volume comparatively well. When diving deeper into cluster 1, we realize that the two most common pick up locations are Midtown East Manhattan (ID 162) and LaGuardia Airport in Queens (ID 138), while the most common drop off locations are Manhattan’s Upper East and West Side (ID 236 and ID 239). As a result, we could hypothesize that the high values for average mph in cluster one might be due to a fast connection between LaGuardia Airport and Manhattan’s Upper Side. This hypothesis gains additional plausibility, if we look at a Google Maps route connecting the respective districts with LaGuardia. Apparently, LaGuardia is connected to Manhattan via the Grand Central Parkway, a highway-like route that steers traffic from Queens to the northern part of Manhattan and thereby avoids the streets in central Manhattan that are most prone to gridlocks.

![GrandCentralParkway](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/GrandCentralParkway.png)

In contrast to cluster 1, where 75% of all taxi trips achieve a speed of 17.5 mph on average, cluster 4 is characterized by the slowest traffic speed, with 75% of trips not exceeding 6.8 mph on average. Diving deeper into the cluster, we are able to obtain information with respect to the most frequented location IDs. By far the most frequented location IDs are 162, 186, 234, and 237. If we mark these areas on the map of Manhattan with red ellipses, it becomes obvious that the districts most prone to traffic congestion and gridlocks are located in Midtown Manhattan, which can also be validated by looking at the other clusters, which draw a similar picture about the traffic situation in NYC.
Based on the information provided in cluster 2,3, and 4, we can further narrow down areas that are especially affected by traffic congestion. As an example, when examining cluster 2, one of the hotspots for traffic jams can probably be found on the route from district ID 170 to 237. Such information can be vital for city planners and authorities, as it allows them to focus their infrastructure projects on areas that suffer from a lack of capacity and thereby slow down the traffic in a much wider area of the city or even lead to traffic jams in other areas, because people have to circumvent specific areas such as Midtown Manhattan.
One way to tackle such a lack of road capacity could be to give people, in particular commuters, incentives to use public transportation, e.g. by reduced ticket prices, a higher frequency of rides, or by providing shuttle services. Extending the given road infrastructure and its capacity is tough and costly, especially in areas like Manhattan where space is densely populated and occupied.

![TaxiZones](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/nycTaxiZones.PNG)

# Chapter 3: Black-box methods to predict trip duration

* Motivation:

After using a clustering algorithm to identify districts and their respective connections that are especially prone to traffic congestions, we recommended city planners and authorities to incentivize their residents, especially commuters, to use public transport options. An important tool for such an incentive-based approach could be to show commuters how much time they could save by not being trapped in the rush hour traffic. Thus, we decided to build some rudimentary models that could predict or estimate a trip’s travel time based on a given pick up ID, drop off ID, pickup date and time, and trip length. By building such models, we hope to give people a better sense of their transportation options and how long they will take respectively. Although such services already exist in the form of navigation systems or Google Maps, which integrate even real-time information, we thought that building a statistical model based on the algorithms which we have learnt in class could provide additional information, as it would allow people to estimate future travel times more accurately than many real-time based services that exist nowadays and can only give vague travel time predictions for future trips (see Chapter 1, Google’s trip estimation). If we would have more time and resources, one could vary the input variables to determine which marginal changes in location result in the steepest increase in predicted travel time. These additional hints could help to determine streets and routes that are particularly affected by traffic congestion and suffer from a lack of capacity.

* Predicting trip duration with Support Vector Machine (SVM):

In our first approach to build a model in order to predict trip duration, we used an SVM that was trained on pick up date and time (“tpep_pickup_datetime”), trip distance (“trip_distance”), pick up location (“PULocationID”), and drop off location (“DOLocationID”) to predict a trip’s duration (“trip_duration”). We started off by converting the tpep_pickup_datetime column into a column of date objects and converted the PULocationID and DOLocationID into factors since there is no inherent order in their IDs. Before training our SVM, we randomly selected 10,000 observations from January 12th, 2017 out of NYC’s taxi trip dataset. Out of these, 7,000 were used for training in order to identify patterns and 3,000 were used for testing. Selecting only a relatively small subset of the overall data helped us to run our analysis faster. When having more computational power and time, we would have tested our findings on the larger dataset and on different dates.

* First iteration:

Using black-box methods, i.e. Support Vector Machines, is typically an iterative procedure. One typically starts by cleaning up the dataset with various pre-processing techniques, such as feature scaling, and continues to build a basic model that tries to identify some first patterns in the data.

Since we did not know whether SVMs could deal with date and factor variables, we started off without any further data pre-processing to get some immediate results which would allow us to see whether an SVM approach could be a viable option or whether we should start by using a different approach without wasting much time.
Below, the figure on the left depicts the summary statistics comparing predicted travel time to observed travel time in the testing data. We observe negative values for travel_time_pred, which does not make sense. We also observe significant outliers when looking at the maximum value of travel_time_test. The magnitude of these outliers can be better understood by examining the boxplot on the right which depicts the distribution of the variable trip_duration in the randomly selected dataset of 10.000 observations It becomes clear that although most values are close together, there are some significant outliers which exceed 80,000 seconds, i.e. approximately 23 hours.
However, it appears to be that our SVM model has been able to derive some meaningful patterns from the features provided and is therefore a viable option worth pursuing. This conclusion can be validated by plotting travel time predictions against the travel times recorded in the testing data. We are able to observe a positive correlation between predicted and observed trip durations for the testing values. However, this relationship is adversely affected by the outliers in the dataset as we can see when accounting for the mean average error and the respective correlation coefficient.
Looking at the MAE and the correlation coefficient, we can conclude that our predictions for trip_duration are on average 375 seconds off. This corresponds to an estimation error of about 6 minutes. Althought we can see a clear linear relationship between predicted and observed trip durations in the plot above, the computed correlation coefficient reaches only 18.8% which is indeed a positive relationship, but a very weak one.

![MAE_1](https://github.com/kdmayer/TaxiTripAnalysis/blob/master/SVM_MAE_COR_1.png)

* Second iteration:

Encouraged by the first results, we decided to continue with our SVM approach by taking into account the effect of outliers in the data, i.e. by removing erroneous or unrealistic observations in our dataset. Looking at the boxplot of trip duration records, we decided to remove all trip_duration values that were above the upper adjacent value in the boxplot, exceeding approximately 5000 seconds.
After discarding outliers in the dataset, our model’s performance improved significantly. The MAE shrinked from 375 seconds to 239 seconds, i.e. less than 4 minutes, and the correlation coefficient increased strongly, i.e. from 18.8% to 82.4%, depicting a strong positive linear relationship between predicted and observed trip durations.

* Third iteration:

Although our predicted trip durations improved significantly after removing outliers, these predictions still had some flaws. Therefore, we proceeded by prohibiting negative time value predictions, as they do not make any sense, and replaced the linear “vanilladot” kernel with a non-linear alternative, i.e. an “rbfdot” kernel. When re-running the model, our results improved to a level of accuracy needed for real-world applications and performed notably better than Google Map’s predicted trip duration in the introductory example of existing travel time predictions. The final model achieves a mean average error (MAE) of less than 180 seconds, i.e. less than 3 minutes and exhibits a correlation coefficient greater than 0.9, indicating a very strong linear relationship between predicted and observed trip durations in the testing set. Moreover, comparing the MAE to the range of values in our testing set, i.e. 179 seconds to 4974 seconds, the SVM performance is quite on point.

# Predicting trip duration with an Artificial Neural Network (ANN)

* Data pre-processing and training:

After building a quite accurate trip duration predictor by using a SVM model, we wanted to use a different algorithm, here an ANN, as a predictor in order to determine whether even better results could be obtained.
As in the case of our SVM model, we used pick up location (“PULocationID"), drop off location ("DOLocationID"), pick up date and time ("tpep_pickup_datetime"), and a trip’s distance ("trip_distance") as features for our model and tried to come up with a reasonable prediction for our regression label “trip_duration”.
In contrast to our SVM model, we had to make some adjustments in order to be able to work with an ANN. Since artificial neural networks cannot deal with non-numerical input, we had to think about how to pre-process certain input features that cannot be interpreted as quantitative values, namely tpep_pickup_datetime, PULocationID, and DOLocationID.
With respect to the tpep_pickup_datetime variable, we needed to ask ourselves, if a timestamp value as accurate as seconds does have any predictive power for the event, i.e. trip_duration, that we are interested in. We concluded that a timestamp value as a continuous variable would not be very helpful in making predictions for two reasons.

1. First of all, when training an ANN on timestamp values as accurate as seconds, it is very unlikely that the ANN can draw any meaningful information or patterns from the training data, simply because the observed timestamp values do not appear often. It would rather make sense to boil down the timestamp values to hourly or daily information, which would be repeatable information one is likely to see many times in the training data and could thus facilitate the predictive power of our ANN.

2. Secondly, since our ANN model does not understand the concept of time, it would be tough to train our model in a way in which it would understand which time values are close to each other and which are not. Think about an example where we feed in a timestamp value of 11:59 pm and 00:01 am, where both timestamps appear on different days. They are physically close together but for an ANN, they are on completely different days. Although it would be possible to encode the timestamp feature values as a continuous variable, e.g. by transforming a given timestamp value into the number of seconds that have passed since mid-night, we discarded this approach, because late-night hours should not have a higher numerical value and therefore a higher impact on the result than timestamps in the early morning.

Thus, we continued by extracting the hours from our timestamp values and to converted them into categorical variables by using a dummy variable approach. We implemented this option by using the dummy_cols() command.
Similarly, we also converted PULocationID and DOLocationID into categorical variables, as they do not contain any quantitative information, since district ID 188 can be right next to district ID 3.
Before training our ANN, we normalized our remaining input variables, i.e. trip_length, by min-max normalization in order to mitigate for the adverse effects of outliers which we have observed in the SVM case. Finally, we trained our model, having two hidden layers with three hidden nodes each, on 700 out of 1.000 randomly picked observations from January 12th, 2017 and tested it on the remaining 300 observations by computing the MAE and the R2_Score, which describes the proportion of the variance in the dependent variable that is predictable from the independent variables.

* Results:

Examining our results, it became clear that our ANN model was not able to derive any meaningful or useful patterns from the training data that it could apply when predicting testing observations.
This was due to a logical flaw in the design for our ANN model. Converting almost all features into categorical variables led to the case where the network input for all categorical variables always amounted to 3. This means that the input value for our ANN was always the same no matter what values we observed for timestamp, PULocationID, and DOLocationID in the data. Since the network input was always the same, no meaningful patterns could be derived by our ANN. Moreover, since we converted our features into categorical variables, we also made our ANN model vulnerable to the curse of dimensionality, another factor that inhibited learning.
When trying to improve our model performance, we decided to reduce the number of input features and deleted the feature variable PULocationID. This resulted in an even worse performance.
Lastly, we decided to use only trip_length as a predictor for our travel time estimate. As before, our ANN was not able to derive meaningful patterns, resulting in poor testing performance that indicated that we should use other models, e.g. SVM, or even simpler, non-black-box approaches, such as a simple regression analysis.

# Chapter 4: Conclusion

* Throughout our analysis of NYC’s taxi trip dataset, we have achieved 3 goals:

1. Cluster analysis for average travel speed and location IDs allowed us to identify districts and routes in NYC that are especially prone to traffic congestions. Authorities can now direct their efforts to achieve a smoother traffic flow by helping these areas that are in dire need.

2. We built black-box models that allow passengers to predict their trip duration based on the given hour of the day, pick up location, drop off location, and trip distance. We thereby achieved results that (in the limited scope of this work) were more accurate than Google Maps predictions with respect to travel time. By providing these models, we hope to give passengers a more realistic overview of their respective travel options and steer commuters towards the use of public transportation, which is often not only faster but also cheaper.

3. Lastly, we built regression and decision trees to allow passengers to predict their total fare amount before hailing a cab, giving them more transparency with respect to the costs that they will be faced with. Moreover, the decision tree allowed us to better understand the business model of cab companies in NYC and how they calculate their trip fares. This knowledge could be used by authorities to build a smarter fare system which disincentivizes cab usage during rush hours or in districts that are especially prone to gridlocks.

