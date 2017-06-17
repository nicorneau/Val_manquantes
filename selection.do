log using selectcode

//Simulation de regressions
clear all
cd "/Users/nicot/Dropbox (CEDIA)/ULaval/Travail/SLIM/Selection"

set obs 1000
set seed 123

*creation du modele
gen expo=rnormal(0,1)
gen x=rnormal(0,1)
gen inter=expo*x

gen error=rnormal(0,1)

gen y=1+expo+x+inter+error

sum y expo x inter

regress y expo x inter

*outtex, detail level legend title(R\'{e}gression : mod\`{e}le de base) key(modele)

*selection aleatoire
gen toto = runiform()
sort toto
generate random = _n <= 750

bysort random: summarize x

regress y expo x inter if random==1

*outtex, detail level legend title(R\'{e}gression : s\'{e}lection al\'{e}atoire (MCAR))


*selection sur x, avec x et expo correles
sort x
gen n1=_n
gen selectx=n1 <= 750

bysort selectx: summarize x

regress y expo x inter if selectx==1

*outtex, detail level legend title(R\'{e}gression : s\'{e}lection sur x (MAR))

*selection sur y
sort y
gen n2=_n
gen selecty=n2 <= 750

bysort selecty: summarize y

regress y expo x inter if selecty==1

*outtex, detail level legend title(R\'{e}gression : s\'{e}lection sur y (NMAR))


//Simulation MC
*modele
clear all
capture program drop model
program define model, rclass

drop _all
set obs 1000

generate expo = rnormal(0,1)
generate x = rnormal(0,1)
generate inter=expo*x
generate error = rnormal(0,1)
generate y = 1 + expo + x + inter + error

regress y expo x inter

return scalar bcons = _b[_cons]
return scalar bexpo = _b[expo]
return scalar bx = _b[x]
return scalar binter = _b[inter]
end

simulate b_cons=r(bcons) b_expo=r(bexpo) b_x=r(bx) b_inter=r(binter), reps(1000) nodots: model

program drop _all
sum
hist b_expo, xtitle(exposition) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_expo, replace
hist b_inter, xtitle(interaction) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_inter, replace
graph combine hist_b_expo.gph hist_b_inter.gph, title("Paramètres pour exposition et interaction:" "Modèle de base", color(black)) graphregion(fcolor(white))

gr export "model.eps", as(eps) preview(off) replace


*selection aleatoire
clear all
capture program drop random
program define random, rclass

drop _all
set obs 1000

generate expo = rnormal(0,1)
generate x = rnormal(0,1)
generate inter=expo*x
generate error = rnormal(0,1)
generate y = 1 + expo + x + inter + error

gen toto = runiform()
sort toto
generate random = _n <= 750

regress y expo x inter if random==1

return scalar bcons = _b[_cons]
return scalar bexpo = _b[expo]
return scalar bx = _b[x]
return scalar binter = _b[inter]
end

simulate b_cons=r(bcons) b_expo=r(bexpo) b_x=r(bx) b_inter=r(binter), reps(1000) nodots: random

program drop _all
sum
hist b_expo, xtitle(exposition) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_expo, replace
hist b_inter, xtitle(interaction) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_inter, replace
graph combine hist_b_expo.gph hist_b_inter.gph, title("Paramètres pour exposition et interaction:" "Sélection aléatoire (MCAR)", color(black)) graphregion(fcolor(white))

gr export "random.eps", as(eps) preview(off) replace


*selection sur x
clear all
capture program drop selectx
program define selectx, rclass

drop _all
set obs 1000

generate expo = rnormal(0,1)
generate x = rnormal(0,1)
generate inter=expo*x
generate error = rnormal(0,1)
generate y = 1 + expo + x + inter + error

sort x
gen n1=_n
gen selectx=n1 <= 750

regress y expo x inter if selectx==1

return scalar bcons = _b[_cons]
return scalar bexpo = _b[expo]
return scalar bx = _b[x]
return scalar binter = _b[inter]
end

simulate b_cons=r(bcons) b_expo=r(bexpo) b_x=r(bx) b_inter=r(binter), reps(1000) nodots: selectx

program drop _all
sum
hist b_expo, xtitle(exposition) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_expo, replace
hist b_inter, xtitle(interaction) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_inter, replace
graph combine hist_b_expo.gph hist_b_inter.gph, title("Paramètres pour exposition et interaction:" "Sélection sur x (MAR)", color(black)) graphregion(fcolor(white))

gr export "selectx.eps", as(eps) preview(off) replace


*selection sur y
clear all
capture program drop selecty
program define selecty, rclass

drop _all
set obs 1000

generate expo = rnormal(0,1)
generate x = rnormal(0,1)
generate inter=expo*x
generate error = rnormal(0,1)
generate y = 1 + expo + x + inter + error

sort y
gen n2=_n
gen selecty=n2 <= 750

regress y expo x inter if selecty==1

return scalar bcons = _b[_cons]
return scalar bexpo = _b[expo]
return scalar bx = _b[x]
return scalar binter = _b[inter]
end

simulate b_cons=r(bcons) b_expo=r(bexpo) b_x=r(bx) b_inter=r(binter), reps(1000) nodots: selecty

program drop _all
sum
hist b_expo, xtitle(exposition) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_expo, replace
hist b_inter, xtitle(interaction) ytitle(densité) graphregion(fcolor(white))
graph save hist_b_inter, replace
graph combine hist_b_expo.gph hist_b_inter.gph, title("Paramètres pour exposition et interaction:" "Sélection sur y (NMAR)", color(black)) graphregion(fcolor(white))

gr export "selecty.eps", as(eps) preview(off) replace

log close

translate selectcode.smcl selectcode.pdf


