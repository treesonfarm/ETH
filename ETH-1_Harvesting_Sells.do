*-------------------------------------------------------------*
*-------------------------------------------------------------*
*                     Trees on Farm:                          *
*    Prevalence, Economic Contribution, and                   *
*   Determinants of Trees on Farms across Sub-Saharan Africa  *
*                                                             *
*             https://treesonfarm.github.io                   *
*-------------------------------------------------------------*
*   Miller, D.; Muñoz-Mora, J.C. and Christiaense, L.         *
*                                                             *
*                     Nov 2016                                *
*                                                             *
*             World Bank and PROFOR                           *
*-------------------------------------------------------------*
*                   Replication Codes                         *
*-------------------------------------------------------------*
*-------------------------------------------------------------*


* ------------------------------------------------------------ *
* --- PART II: Sells data data   ---- *
* ------------------------------------------------------------ *

    *--- 1 - Open DataSet - Permanent Crops 

        use "$path_data/ETH/2011-12/sect11_ph_w1.dta", clear
        gen x=1

        rename ph_s11q04_a value_sold
        rename ph_s11q22_a share_q_selfcosumption
        rename ph_s11q22_b share_q_seed
        rename ph_s11q22_c share_q_sold
        rename ph_s11q22_d share_q_kind
        rename ph_s11q22_e share_q_animal
        rename ph_s11q22_f share_q_other

        keep household_id crop_code value_sold share_q_* x

    *---3. Append Trees/Roots

      	append using "$path_data/ETH/2011-12/sect12_ph_w1.dta"
        replace value_sold=ph_s12q08 if x==.
        replace share_q_selfcosumption=ph_s12q19_a if x==.
        replace share_q_sold=ph_s12q19_c if x==.
        replace share_q_seed=ph_s12q19_b if x==.

        replace share_q_selfcosumption=ph_s12q19_a if x==.
        replace share_q_seed=ph_s12q19_b if x==.
        replace share_q_sold=ph_s12q19_c if x==.
        replace share_q_kind=ph_s12q19_d if x==.
        replace share_q_animal=ph_s12q19_e if x==.
        replace share_q_other=ph_s12q19_f if x==.


        keep household_id crop_code value_sold share_q_* 


    *-- Cleaning the data set 
     drop if crop_code==.
     replace value_sold=0 if value_sold==.

     foreach i in share_q_selfcosumption share_q_seed share_q_sold share_q_kind share_q_animal share_q_other {
      replace `i'=0 if `i'==. 
      replace `i'=`i'/100
     }
     gen total=share_q_selfcosumption+share_q_sold+share_q_seed 

     gen x=(total>1)
     drop if x==1


   *---  4 - Include our crop classification
      include "$path_work/do-files/ETH-CropClassification.do"

    *---  6 - Collapse information

    collapse (sum) value_sold (mean) share_q_*, by(household_id tree_type)

    *-- 8. Merge from the HH

  merge n:1 household_id using "$path_data/ETH/2011-12/sect_cover_hh_w1.dta", keepusing(ea_id pw saq01) nogenerate

    save "$path_work/ETH/0_CropsSells.dta", replace



