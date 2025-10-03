require using "scripts/setup/stata_requirements.txt", install
github install PovertyAction/ipaplots
ssc install stata_linter
set scheme ipaplots, permanent
display as text "Stata package installation complete!"
