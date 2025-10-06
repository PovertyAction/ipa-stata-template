* docs: https://hugetim.github.io/nbstata/user_guide.html#stata-implementation-details
* "Using vscode-stata"
* requires:
* - Stata 17+
* - nbstata python package
* - VSCode with vscode-stata extension

* %%
sysuse auto, clear


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
