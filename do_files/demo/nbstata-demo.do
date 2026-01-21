* docs: https://hugetim.github.io/nbstata/user_guide.html#stata-implementation-details
* "Using vscode-stata"
* requires:
* - Stata 17+
* - nbstata python package
* - VSCode with vscode-stata extension

* Start logging
local script_name "stata_demo"
capture mkdir "../../logs"
log using "../../logs/`script_name'.log", replace text name(`script_name')

* %%
sysuse auto, clear

* %%[markdown]
* Browse the dataset: `%browse [-h] [varlist] [if] [in] [, nolabel noformat]`

* %%
%browse

* %%[markdown]
* View the first 10 observations: `%*%head [-h] [N] [varlist] [if] [, nolabel noformat]`

* %%
%head 10

* %%[markdown]
* View the last 5 observations: `%*%tail [-h] [N] [varlist] [if] [, nolabel noformat]`

* %%
%tail 5

* %%
regress price mpg

* %%
sum price mpg weight foreign

* %%
* %set graph_width = 8
* %set graph_height = 5
twoway scatter price mpg, ///
    title("Car Price vs. Fuel Economy") ///
    xtitle("Miles per Gallon") ///
    ytitle("Price (USD)") ///
    note("Data: 1978 Automobile Data")

* %%
regress price mpg weight foreign


* %%
qui regress price mpg weight foreign
estimates store model1

qui regress price mpg weight foreign length
estimates store model2

etable, estimates(model1 model2) ///
    column(estimates) ///
    showstars showstarsnote ///
    title("Regression Results: Car Price Models")

* Close log
log close `script_name'
