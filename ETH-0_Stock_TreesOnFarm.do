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
* --- PART I: Production data   ---- *
* ------------------------------------------------------------ * 
* Data was collected only on one visit
 **** Fruits Trees (AG_SEC6A.dta) + Permanent Crops (AG_SEC6B.dta)

  *----------------------------
  *  All Crops together
  *----------------------------

    *--- 1 - Open DataSet - All Data Sets Together
        * Start with Fruit Crops/Permanent Crops

         * Post-Planting (Season 1)
        use "$path_data/ETH/2011-12/sect4_pp_w1.dta", clear

    *---  2 - Include our crop classification
      qui include "$path_work/do-files/ETH-CropClassification.do"
      replace tree_type="NA" if tree_type==""
      gen d_test=(crop_code==32)

    *---  4 - Collapse information
        gen x=1
        collapse (sum) n_parcels=x t_area=pp_s4q02 t_n_trees_1=pp_s4q14 t_n_trees_2=pp_s4q15 (mean) s_planted=pp_s4q03 ,by( household_id parcel_id field_id tree_type)
        gen t_n_trees=t_n_trees_1
        replace t_n_trees=t_n_trees_2 if t_n_trees==.
        drop t_n_trees_*


    *-- 6. We identify whether the Parcel has more than one crop (i.e. Inter-cropped)

            bys household_id parcel_id field_id: gen n_crops_plot=_N
            gen inter_crop=(n_crops_plot>1 & n_crops_plot!=.)
            drop n_crops_plot

    *-- 7. Reshape the data for the new crops system

            encode tree_type, gen(type_crop)
                * 1 Fruit Tree
                * 2 NA
                * 3 Plant/Herb/Grass/Roots
                * 4 Tree Cash Crops
                * 5 Trees for timber and fuel-wood
            drop tree_type
            order household_id parcel_id field_id
            reshape wide n_parcels t_area t_n_trees s_planted , i(household_id parcel_id field_id) j(type_crop)
  
    *--- 8. Rename Variables 
            global names "Tree_Fruit NA Plant Tree_Agri Tree_wood"
            local number "1 2 3 4 5"
            
            local i=1
            foreach y of global names {
                local name: word `i' of `number'
                  foreach h in n_parcels t_area t_n_trees s_planted {
                rename `h'`name' `h'_`y'
                replace `h'_`y'=0 if `h'_`y'==.
                }
                local i=`i'+1
            }
    
    *--- 9. Save the data set


		save "$path_work/ETH/0_CropsClassification.dta", replace
    




