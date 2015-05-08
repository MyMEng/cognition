# Building activity recognition model: #
## learning Prolog rules and extracting features from spatio-temporal data ##

This project researches **Prolog**'s *Inductive Logic Programming* approach to learn parametrised rules describing *Activities of Daily Life* based on data acquired form smart-houses: residences equipped with variety of sensors.

To this end, a highly customisable smart-house data generator is constructed and capabilities of **Aleph** inductive logic programming framework are assessed on various spatio-temporal datasets. Subsequently, an *Activity Recognition Model* is constructed based on data collected from simulations and Washington State University CASAS smart-house installations. Both single and multiple occupiers models are considered.

To achieve the aforementioned goals, signal issues such as noise and incompleteness among others are addressed. Furthermore, a method for the raw data transformation into logical facts is proposed and evaluated. Difficulties such as real-valued sensor output and time representation in first-order logic are described.

The second objective of this work is to examine the structure of used spatio-temporal data with a view to discover and form new features. To this end, the dependencies between sensors are identified and assessed in order to construct more informative features. Hence by extending the dataset with new features performance of any classification algorithm can be significantly boosted.

Finally, this work opens up possibility of *Narrative Analytics*: an extension of the Activity Recognition Model transforming generated rules into *natural language*. The proposed data visualisation technique produces a plain English description of monitored residence, hence house situation can be examined without time consuming data interpretation.

The main utilisation of proposed here techniques is house monitoring for healthcare applications. SPHERE Project hosted at the University of Bristol addresses increasing healthcare costs and decreasing quality of life by designing tools and techniques allowing patients to live at home regardless of their medical conditions.  
The activity recognition approach described here aims at improving the classification results and presenting smart-house data in a more transparent way. To the best of my knowledge, presented here methods are first of their kind and has not been yet described in any scientific publication.

## Keywords ##
**Inductive Logic Programming**, **Prolog**, **Activity Recognition**, **Data Generation**, **SPHERE**



