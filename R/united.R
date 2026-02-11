#' @name gecco
#' @title GECCO Challenge 2018 – Water Quality Time Series
#' @description Benchmark time series for water quality monitoring composed of
#'     multiple sensors and an associated binary event label. This dataset
#'     supports research in anomaly and event detection for environmental data
#'     streams. See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for usage guidance and links to the preprocessing steps used to build the
#'     package-ready object. Labels available: Yes.
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(gecco)
#' @format A list of time series.
#' @keywords datasets
#' @references Genetic and Evolutionary Computation Conference (GECCO), Association for Computing Machinery (ACM).
#'     See also: Chandola, V., Banerjee, A., & Kumar, V. (2009). Anomaly detection:
#'     A survey. ACM Computing Surveys, 41(3), 1–58.
#' @source GECCO Challenge 2018 (legacy challenge page unavailable)
#' @examples
#' data(gecco)
#' # Select the first univariate series and inspect
#' series <- gecco[[1]]
#' summary(series$value)
#' # Plot values with event markers
#' plot(ts(series$value), main = names(gecco)[1], ylab = "value")
"gecco"


#' @name A1Benchmark
#' @title Yahoo Webscope S5 – A1 Benchmark (Real)
#' @description Part of the Yahoo Webscope S5 labeled anomaly detection dataset.
#'     A1 contains real-world time series with binary anomaly labels. Useful for
#'     evaluating anomaly detection methods on real traffic-like data. Labels
#'     available: Yes.
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(A1Benchmark)
#' @format A list of time series.
#' @keywords datasets
#' @references Yoshihara K, Takahashi K (2022) A simple method for unsupervised anomaly detection: An application to Web time series data. PLoS ONE 17(1).
#' @source \doi{10.1371/journal.pone.0262463}
#' @references Chandola, V., Banerjee, A., & Kumar, V. (2009). Anomaly detection: A survey. ACM Computing Surveys, 41(3), 1–58.
#' @examples
#' data(A1Benchmark)
#' # Access the first series and visualize
#' s <- A1Benchmark[[1]]
#' plot(ts(s$value), main = names(A1Benchmark)[1], ylab = "value")
#' mean(s$event)  # proportion of labeled anomalies
"A1Benchmark"

#' @name A2Benchmark
#' @title Yahoo Webscope S5 – A2 Benchmark (Synthetic)
#' @description Part of the Yahoo Webscope S5 dataset. A2 contains synthetic
#'     time series with labeled anomalies designed to stress-test algorithms.
#'     Labels available: Yes.
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(A2Benchmark)
#' @format A list of time series.
#' @keywords datasets
#' @references Yoshihara K, Takahashi K (2022) A simple method for unsupervised anomaly detection: An application to Web time series data. PLoS ONE 17(1).
#' @source \doi{10.1371/journal.pone.0262463}
#' @references Chandola, V., Banerjee, A., & Kumar, V. (2009). Anomaly detection: A survey. ACM Computing Surveys, 41(3), 1–58.
#' @examples
#' data(A2Benchmark)
#' s <- A2Benchmark[[1]]
#' summary(s$value)
"A2Benchmark"

#' @name A3Benchmark
#' @title Yahoo Webscope S5 – A3 Benchmark (Synthetic with Outliers)
#' @description Part of the Yahoo Webscope S5 dataset. A3 contains synthetic
#'     time series with labeled outliers/anomalies. Labels available: Yes.
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(A3Benchmark)
#' @format A list of time series.
#' @keywords datasets
#' @references Yoshihara K, Takahashi K (2022) A simple method for unsupervised anomaly detection: An application to Web time series data. PLoS ONE 17(1).
#' @source \doi{10.1371/journal.pone.0262463}
#' @import harbinger
#' @examples
#' library(harbinger)
#' data(A3Benchmark)
#' s <- A3Benchmark[[1]]
#' # Quick visualization with harbinger
#' har_plot(harbinger(), s$value)
"A3Benchmark"

#' @name A4Benchmark
#' @title Yahoo Webscope S5 – A4 Benchmark (Synthetic with Anomalies and CPs)
#' @description Part of the Yahoo Webscope S5 dataset. A4 contains synthetic
#'     time series with labeled anomalies and change points. Labels available: Yes.
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(A4Benchmark)
#' @format A list of time series.
#' @keywords datasets
#' @references Yoshihara K, Takahashi K (2022) A simple method for unsupervised anomaly detection: An application to Web time series data. PLoS ONE 17(1).
#' @source \doi{10.1371/journal.pone.0262463}
#' @references Truong, C., Oudre, L., & Vayatis, N. (2020). Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @examples
#' data(A4Benchmark)
#' s <- A4Benchmark[[1]]
#' mean(s$event)  # proportion of anomalous or change-point timestamps
"A4Benchmark"

#' @name oil_3w_Type_1
#' @title Oil Wells Dataset – Type 1
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Type 0 removed from this version due to file size.
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_1)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_1)
#' s <- oil_3w_Type_1[[1]]
#' plot(ts(s$p_tpt), main = names(oil_3w_Type_1)[1], ylab = "value")
"oil_3w_Type_1"

#' @name oil_3w_Type_2
#' @title Oil Wells Dataset – Type 2
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_2)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_2)
#' s <- oil_3w_Type_2[[1]]
#' mean(s$event)  # proportion of change points
"oil_3w_Type_2"

#' @name oil_3w_Type_4
#' @title Oil Wells Dataset – Type 4
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_4)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_4)
#' serie <- oil_3w_Type_4[[1]]
"oil_3w_Type_4"

#' @name oil_3w_Type_5
#' @title Oil Wells Dataset – Type 5
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_5)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_5)
#' serie <- oil_3w_Type_5[[1]]
"oil_3w_Type_5"

#' @name oil_3w_Type_6
#' @title Oil Wells Dataset – Type 6
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_6)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_6)
#' serie <- oil_3w_Type_6[[1]]
"oil_3w_Type_6"

#' @name oil_3w_Type_7
#' @title Oil Wells Dataset – Type 7
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_7)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_7)
#' serie <- oil_3w_Type_7[[1]]
"oil_3w_Type_7"

#' @name oil_3w_Type_8
#' @title Oil Wells Dataset – Type 8
#' @description
#' First realistic dataset with real events in oil well drilling. The data available
#'     in this package consist of time series already analyzed and applied in
#'     research experiments by the DAL group (Data Analytics Lab). The series are
#'     divided into 7 groups (Type_0, Type_1, Type_2, Type_4, Type_5, Type_6, Type_7 and Type_8).
#'     Creation date: 2019.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(oil_3w_Type_8)
#' @format A list of time series.
#' @keywords datasets
#' @references 3W dataset (UCI repository). See also: Truong, C., Oudre, L., & Vayatis, N. (2020).
#'     Selective review of change point detection methods. Signal Processing, 167, 107299.
#' @source \href{https://archive.ics.uci.edu/ml/datasets/3W+dataset}{UCI Machine Learning Repository}
#' @examples
#' data(oil_3w_Type_8)
#' serie <- oil_3w_Type_8[[1]]
"oil_3w_Type_8"

#' @name nab_artificialWithAnomaly
#' @title Numenta Anomaly Benchmark (NAB) – artificialWithAnomaly
#' @description Synthetic time series with injected anomalies from the Numenta
#'     Anomaly Benchmark (NAB). Designed for evaluating anomaly detection
#'     algorithms under controlled conditions. Labels available: Yes.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(nab_artificialWithAnomaly)
#' @format A list of time series.
#' @keywords datasets
#' @references Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly
#'     detection algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th
#'     International Conference on Machine Learning and Applications (ICMLA).
#' @source \href{https://github.com/numenta/NAB/tree/master/data}{Numenta Anomaly Benchmark (NAB) Dataset}
#' @examples
#' data(nab_artificialWithAnomaly)
#' s <- nab_artificialWithAnomaly[[1]]
#' plot(ts(s$value), main = names(nab_artificialWithAnomaly)[1])
"nab_artificialWithAnomaly"

#' @name nab_realAdExchange
#' @title Numenta Anomaly Benchmark (NAB) – realAdExchange
#' @description Real-world time series with labeled anomalies from ad exchange
#'     data (NAB). Useful for evaluating detection methods on operational data.
#'     Labels available: Yes.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(nab_realAdExchange)
#' @format A list of time series.
#' @keywords datasets
#' @references Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly
#'     detection algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th
#'     International Conference on Machine Learning and Applications (ICMLA).
#' @source \href{https://github.com/numenta/NAB/tree/master/data}{Numenta Anomaly Benchmark (NAB) Dataset}
#' @examples
#' data(nab_realAdExchange)
#' s <- nab_realAdExchange[[1]]
#' mean(s$event)
"nab_realAdExchange"

#' @name nab_realAWSCloudwatch
#' @title Numenta Anomaly Benchmark (NAB) realAWSCloudwatch
#' @description
#' Data collection with real-world time-series.
#'     Real data from AWS Cloud with anomalies
#'     As part of the Numenta Anomaly Benchmark (NAB), this dataset contains
#'     time series with real and synthetic data. The real data comes from network
#'     monitoring and cloud computing. On the other hand, synthetic data simulate
#'     series with or without anomalies.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(nab_realAWSCloudwatch)
#' @format A list of time series.
#' @keywords datasets
#' @references Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly
#'     detection algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th
#'     International Conference on Machine Learning and Applications (ICMLA).
#' @source \href{https://github.com/numenta/NAB/tree/master/data}{Numenta Anomaly Benchmark (NAB) Dataset}
#' @examples
#' data(nab_realAWSCloudwatch)
#' nab_grp <- nab_realAWSCloudwatch[[1]]
#' serie <- nab_grp[[1]]
"nab_realAWSCloudwatch"

#' @name nab_realKnownCause
#' @title Numenta Anomaly Benchmark (NAB) realKnownCause
#' @description
#' Data collection with real-world time-series.
#'     Real data with anomalies
#'     As part of the Numenta Anomaly Benchmark (NAB), this dataset contains
#'     time series with real and synthetic data. The real data comes from network
#'     monitoring and cloud computing. On the other hand, synthetic data simulate
#'     series with or without anomalies.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(nab_realKnownCause)
#' @format A list of time series.
#' @keywords datasets
#' @references Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly
#'     detection algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th
#'     International Conference on Machine Learning and Applications (ICMLA).
#' @source \href{https://github.com/numenta/NAB/tree/master/data}{Numenta Anomaly Benchmark (NAB) Dataset}
#' @examples
#' data(nab_realKnownCause)
#' nab_grp <- nab_realKnownCause[[1]]
#' serie <- nab_grp[[1]]
"nab_realKnownCause"

#' @name nab_realTraffic
#' @title Numenta Anomaly Benchmark (NAB) realTraffic
#' @description
#' Data collection with real-world time-series.
#'     Real data from online data traffic with anomalies
#'     As part of the Numenta Anomaly Benchmark (NAB), this dataset contains
#'     time series with real and synthetic data. The real data comes from network
#'     monitoring and cloud computing. On the other hand, synthetic data simulate
#'     series with or without anomalies.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(nab_realTraffic)
#' @format A list of time series.
#' @keywords datasets
#' @references Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly
#'     detection algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th
#'     International Conference on Machine Learning and Applications (ICMLA).
#' @source \href{https://github.com/numenta/NAB/tree/master/data}{Numenta Anomaly Benchmark (NAB) Dataset}
#' @examples
#' data(nab_realTraffic)
#' nab_grp <- nab_realTraffic[[1]]
#' serie <- nab_grp[[1]]
"nab_realTraffic"

#' @name nab_realTweets
#' @title Numenta Anomaly Benchmark (NAB) realTweets
#' @description Real-world time series with labeled anomalies from Twitter
#'     volumes (NAB). Labels available: Yes.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(nab_realTweets)
#' @format A list of time series.
#' @keywords datasets
#' @references Lavin, A., & Ahmad, S. (2015). Evaluating real-time anomaly
#'     detection algorithms – the Numenta Anomaly Benchmark. 2015 IEEE 14th
#'     International Conference on Machine Learning and Applications (ICMLA).
#' @source \href{https://github.com/numenta/NAB/tree/master/data}{Numenta Anomaly Benchmark (NAB) Dataset}
#' @examples
#' data(nab_realTweets)
#' s <- nab_realTweets[[1]]
#' plot(ts(s$value), main = names(nab_realTweets)[1])
#' mean(s$event)
"nab_realTweets"

#' @name ucr_ecg
#' @title UCR Anomaly Archive – ECG
#' @description
#' Data collection with real-world time-series.
#'     Real ECG time series with labeled anomalous intervals.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(ucr_ecg)
#' @format A list of time series.
#' @keywords datasets
#' @references UCR Time Series Anomaly Archive. See also: Chandola, V., Banerjee, A., & Kumar, V. (2009).
#'     Anomaly detection: A survey. ACM Computing Surveys, 41(3), 1–58.
#' @source \href{https://paperswithcode.com/dataset/ucr-anomaly-archive/}{UCR Anomaly Archive}
#' @examples
#' data(ucr_ecg)
#' # Access and plot a series
#' s <- ucr_ecg[[1]]
#' plot(ts(s$value), main = names(ucr_ecg)[1])
"ucr_ecg"

#' @name ucr_nasa
#' @title UCR Anomaly Archive – NASA Spacecraft
#' @description
#' Data collection with real-world time-series.
#'     Real NASA spacecraft monitoring time series with labeled anomalous intervals.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(ucr_nasa)
#' @format A list of time series.
#' @keywords datasets
#' @references UCR Time Series Anomaly Archive. See also: Chandola, V., Banerjee, A., & Kumar, V. (2009).
#'     Anomaly detection: A survey. ACM Computing Surveys, 41(3), 1–58.
#' @source \href{https://paperswithcode.com/dataset/ucr-anomaly-archive/}{UCR Anomaly Archive}
#' @examples
#' data(ucr_nasa)
#' s <- ucr_nasa[[1]]
#' mean(s$event)
"ucr_nasa"

#' @name ucr_int_bleeding
#' @title UCR Anomaly Archive – Internal Bleeding
#' @description
#' Data collection with real-world time-series.
#'     Real physiological time series with labeled anomalous intervals.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(ucr_int_bleeding)
#' @format A list of time series.
#' @keywords datasets
#' @references UCR Time Series Anomaly Archive. See also: Chandola, V., Banerjee, A., & Kumar, V. (2009).
#'     Anomaly detection: A survey. ACM Computing Surveys, 41(3), 1–58.
#' @source \href{https://paperswithcode.com/dataset/ucr-anomaly-archive/}{UCR Anomaly Archive}
#' @examples
#' data(ucr_int_bleeding)
#' s <- ucr_int_bleeding[[1]]
#' plot(ts(s$value))
"ucr_int_bleeding"

#' @name ucr_power_demand
#' @title UCR Anomaly Archive – Italian Power Demand
#' @description
#' Data collection with real-world time-series.
#'     Real power demand time series with labeled anomalous intervals.
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(ucr_power_demand)
#' @format A list of time series.
#' @keywords datasets
#' @references UCR Time Series Anomaly Archive. See also: Chandola, V., Banerjee, A., & Kumar, V. (2009).
#'     Anomaly detection: A survey. ACM Computing Surveys, 41(3), 1–58.
#' @source \href{https://paperswithcode.com/dataset/ucr-anomaly-archive/}{UCR Anomaly Archive}
#' @examples
#' data(ucr_power_demand)
#' s <- ucr_power_demand[[1]]
#' summary(s$value)
"ucr_power_demand"


#' @name mit_bih_MLII
#' @title MIT-BIH Arrhythmia Database – MLII Lead
#' @description
#' Data collection with real-world time-series.
#'     MIT-BIH Arrhythmia Database (MIT-BIH).
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(mit_bih_MLII)
#' @format A list of time series from the MLII sensor of the MIT-BIH Arrhythmia Database.
#' @keywords datasets
#' @references MIT-BIH Arrhythmia Database (MIT-BIH). See also: Moody, G. B., & Mark, R. G. (2001).
#'     The impact of the MIT-BIH Arrhythmia Database. IEEE Engineering in Medicine and Biology Magazine, 20(3), 45–50.
#' @source \doi{10.1109/51.932724}
#' @examples
#' data(mit_bih_MLII)
#' data <- mit_bih_MLII[[1]]
#' series <- data$value
"mit_bih_MLII"

#' @name mit_bih_V1
#' @title MIT-BIH Arrhythmia Database – V1 Lead
#' @description
#' Data collection with real-world time-series.
#'     MIT-BIH Arrhythmia Database (MIT-BIH).
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(mit_bih_V1)
#' @format A list of time series from the V1 sensor of the MIT-BIH Arrhythmia Database.
#' @keywords datasets
#' @references MIT-BIH Arrhythmia Database (MIT-BIH). See also: Moody, G. B., & Mark, R. G. (2001).
#'     The impact of the MIT-BIH Arrhythmia Database. IEEE Engineering in Medicine and Biology Magazine, 20(3), 45–50.
#' @source \doi{10.1109/51.932724}
#' @examples
#' data(mit_bih_V1)
#' data <- mit_bih_V1[[1]]
#' series <- data$value
"mit_bih_V1"

#' @name mit_bih_V2
#' @title MIT-BIH Arrhythmia Database – V2 Lead
#' @description
#' Data collection with real-world time-series.
#'     MIT-BIH Arrhythmia Database (MIT-BIH).
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(mit_bih_V2)
#' @format A list of time series from the V2 sensor of the MIT-BIH Arrhythmia Database.
#' @keywords datasets
#' @references MIT-BIH Arrhythmia Database (MIT-BIH). See also: Moody, G. B., & Mark, R. G. (2001).
#'     The impact of the MIT-BIH Arrhythmia Database. IEEE Engineering in Medicine and Biology Magazine, 20(3), 45–50.
#' @source \doi{10.1109/51.932724}
#' @examples
#' data(mit_bih_V2)
#' data <- mit_bih_V2[[1]]
#' series <- data$value
"mit_bih_V2"

#' @name mit_bih_V5
#' @title MIT-BIH Arrhythmia Database – V5 Lead
#' @description
#' Data collection with real-world time-series.
#'     MIT-BIH Arrhythmia Database (MIT-BIH).
#'     See \href{https://github.com/cefet-rj-dal/united}{cefet-rj-dal/united}
#'     for detailed guidance on using this package and the other datasets available in it.
#'     Labels available? Yes
#' @docType data
#' @details This package ships a mini version of the dataset. Use loadfulldata() to download and load the full dataset from the URL stored in attr(url).
#' @usage data(mit_bih_V5)
#' @format A list of time series from the V5 sensor of the MIT-BIH Arrhythmia Database.
#' @keywords datasets
#' @references MIT-BIH Arrhythmia Database (MIT-BIH). See also: Moody, G. B., & Mark, R. G. (2001).
#'     The impact of the MIT-BIH Arrhythmia Database. IEEE Engineering in Medicine and Biology Magazine, 20(3), 45–50.
#' @source \doi{10.1109/51.932724}
#' @examples
#' data(mit_bih_V5)
#' data <- mit_bih_V5[[1]]
#' series <- data$value
"mit_bih_V5"


