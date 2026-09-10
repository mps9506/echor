# Introduction to echor

## echor introduction

`echor` is an R package to search and download data from the US
Environmental Protection Agency (EPA) Environmental Compliance and
History Online (ECHO). `echor` uses the [ECHO
API](https://echo.epa.gov/) to download data directly to the R as
dataframes or simple features. ECHO provides information about
facilities permitted to emitted air pollutants or discharge into water
bodies. ECHO also provides data reported by permitted facilities as
volume or concentration of pollutants during reporting time periods
(typically annually for air emissions and monthly or quarterly for water
discharges).

ECHO provides data for:

- Stationary sources permitted under the Clean Air Act, including data
  from the National Emissions Inventory, Greenhouse Gas Reporting
  Program, Toxics Release Inventory, and Clean Air Markets Division Acid
  Rain Program and Clean Air Interstate Rule.
- Public drinking water systems permitted under the Safe Drinking Water
  Act, including data from the Safe Drinking Water Information System.
- Hazardous Waste Handlers permitted under the Resource Conservation and
  Recovery Act, with data drawn from the RCRAInfo data system.
- Facilities permitted under the Clean Water Act and the National
  Pollutant Discharge Elimination Systems (NPDES) program, including
  data from EPA’s ICIS-NPDES system and possibly water body information
  from EPA’s ATTAINS data system.

`echor` currently provides functions to retrieve information about
permitted air dischargers, water dischargers, and public drinking water
supply systems. It also provides functions to download discharge reports
for permitted air and water dischargers. `echor` does not currently
provide functionality to retrieve RCRA data.

See <https://echo.epa.gov/tools/web-services> for information about ECHO
web services and API functions.

## Getting started

This vignette documents a few key functions to get started.

There are three types of functions:

### Metadata

Retrieve metadata from ECHO to narrow the specify data returned or
lookup parameter codes.

- [`echoAirGetMeta()`](https://mps9506.github.io/echor/reference/echoAirGetMeta.md) -
  Returns variable name and descriptions for parameters returned in air
  facility queries.

- [`echoSDWGetMeta()`](https://mps9506.github.io/echor/reference/echoSDWGetMeta.md) -
  Returns variable name and descriptions for parameters returned in
  public water system queries.

- [`echoWaterGetMeta()`](https://mps9506.github.io/echor/reference/echoWaterGetMeta.md) -
  Returns variable name and descriptions for parameters returned in
  water discharge facility queries (e.g. facilities with an NPDES
  permit).

- [`echoWaterGetParams()`](https://mps9506.github.io/echor/reference/echoWaterGetParams.md) -
  Search parameter codes for constituent pollutants regulated under
  NPDES permits.

### Query Facilities

Search and return facility information based on lookup parameters.

- [`echoAirGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoAirGetFacilityInfo.md) -
  Returns a dataframe of permitted air discharge facilities and
  associated information based on lookup parameters specified by the
  user.

- [`echoSDWGetSystems()`](https://mps9506.github.io/echor/reference/echoSDWGetSystems.md) -
  Returns a dataframe of permitted air discharge facilities and
  associated information based on lookup parameters specified by the
  user.

- [`echoWaterGetFacilityInfo()`](https://mps9506.github.io/echor/reference/echoWaterGetFacilityInfo.md) -
  Returns a dataframe of permitted water discharge facilities and
  associated information based on lookup parameters specified by the
  user.

### Reports

Search and return discharge and emissions reports for specified
facilities.

- [`echoGetCAAPR()`](https://mps9506.github.io/echor/reference/echoGetCAAPR.md) -
  Returns a dataframe with reported annual air emissions from permitted
  facilities.

- [`echoGetEffluent()`](https://mps9506.github.io/echor/reference/echoGetEffluent.md) -
  Returns a dataframe with reported water effluent discharges from
  permitted facilities.

## Sample workflows

### Air

Suppose we want to find facilities permitted under the Clean Air Act
requirements.

Step 1 - Identify the information we need returned from the query:

``` r

library(echor)
meta <- echoAirGetMeta()
meta
#> # A tibble: 376 × 6
#>    ColumnName                DataType DataLength ColumnID ObjectName Description
#>    <chr>                     <chr>    <chr>      <chr>    <chr>      <chr>      
#>  1 AIR_NAME                  VARCHAR2 200        1        AIRName    NA         
#>  2 SOURCE_ID                 VARCHAR2 30         2        SourceID   Unique Ide…
#>  3 AIR_STREET                VARCHAR2 200        3        AIRStreet  NA         
#>  4 AIR_CITY                  VARCHAR2 100        4        AIRCity    NA         
#>  5 AIR_STATE                 CHAR     2          5        AIRState   NA         
#>  6 LOCAL_CONTROL_REGION_CODE CHAR     3          6        LocalCont… NA         
#>  7 AIR_ZIP                   VARCHAR2 10         7        AIRZip     NA         
#>  8 REGISTRY_ID               VARCHAR2 50         8        RegistryID An interna…
#>  9 AIR_COUNTY                VARCHAR2 100        9        AIRCounty  NA         
#> 10 AIR_EPA_REGION            CHAR     2          10       AIREPAReg… NA         
#> # ℹ 366 more rows
```

The dataframe includes ColumnID, which can be included as an argument
that specifies what information you want returned:
`qcolumns = "1,2,3,22,23"`

Step 2 - Create the query. The ECHO API provides numerous arguments to
search by that are not documented in this package. I recommend exploring
the documentation here:
<https://echo.epa.gov/tools/web-services/facility-search-air#!/Facilities/get_air_rest_services_get_facility_info>.
In this example, we will search by a geographic bounding box and specify
the returned information with the `qcolumns` argument. Each argument
should be passed to ECHO as
`echoAirGetFacilityInfo(parameter = "value")`. `echor` will URL encode
strings automatically. Please note that any date argument needs to be
entered as “mm/dd/yyyy”.

``` r

library(echor)

## Retrieve information about facilities within a geographic location
df <- echoAirGetFacilityInfo(output = "df",
                             p_c1lon = '-96.387509',
                             p_c1lat = '30.583572',
                             p_c2lon = '-96.281422',
                             p_c2lat = '30.640008',
                             qcolumns = "1,2,3,22,23")
```

| AIRName | SourceID | AIRStreet | FacLat | FacLong |
|:---|:---|:---|---:|---:|
| AGGIE CLEANERS | 06000000480416E020 | 111 COLLEGE MAIN | 30.61869 | -96.34588 |
| ALL SEASONS 1 HR CLEANERS | 06000000480416E015 | 2501 TEXAS AVENUE SOUTH \#D100 | 30.60704 | -96.30875 |
| BLUEBONNET PAVING | TX0000004877700147 | HWY. 60, WEST OF | 30.61337 | -96.32098 |
| BRYAN CLEANERS & LAUNDRY | 06000000480416E012 | 1803 HOLLEMAN DRIVE | 30.61225 | -96.31750 |
| CITY OF BRYAN | TX0000004804100026 | 1.5 MI W OF @FM 1687 & FM 2818 | 30.63760 | -96.36235 |
| COMET 1 HR CLEANERS | 06000000480416E013 | 1712 SOUTHWEST PARKWAY \#101 | 30.60616 | -96.31034 |

Some example arguments are listed below:

    p_fn  string  Facility Name Filter.
                  One or more case-insesitive facility names.
                  Provide multiple values as comma-delimited list
                  ex:
                  p_fn = "Aggie Cleaners, City of Bryan, TEXAS A&M UNIVERSITY COLLEGE STATION CAMPUS"
                  
    p_sa  string  Facility Street Address
                  ex:
                  p_sa = "WELLBORN ROAD & UNIVERSITY DR"
                  
    p_ct  string  Facility City
                  Provide a single case-insensitive city name
                  ex:
                  p_ct = "College Station"
                  
    p_co  string  Facility County
                  Provide a single county name, in combination with a state value
                  provided through p_st
                  ex:
                  p_co = "Brazos", p_st = "Texas"
                  
    p_fips  string  FIPS Code
                    Single 5-character Federal Information Processing Standards (FIPS) 
                    state+county value
                    
    p_st  string  Facility State or State Equivalent Filter
                  Provide one or more USPS postal abbreviations
                  ex:
                  p_st = "TX, NC"
                  
    p_zip string  Facility 5-Digit Zip Code
                  Provide one or more 5-digit postal zip codes
                  ex:
                  p_zip = "77843, 77845"
                  
    p_c1lon  string  Minimum longitude value in decimal degrees

    p_c1lat  string  Minimum latitude value in decimal degrees

    p_c2lon  string  Maximum longitude value in decimal degrees

    p_c2lat  string  Maximum latitude value in decimal degrees

Step 3 - Download the emission inventory report for a permitted
facility:

``` r

df <- echoGetCAAPR(p_id = '110000350174')
```

| Name | SourceID | Street | City | State | Zip | County | Region | Latitude | Longitude | Pollutant | UnitsOfMeasure | Program | Year | Discharge |
|:---|:---|:---|:---|:---|:---|:---|:---|---:|---:|:---|:---|:---|---:|---:|
| DUKE ENERGY PROGRESS, LLC - L.V. SUTTON ELECTRIC PLANT | 110000350174 | 801 SUTTON STEAM PLANT ROAD | WILMINGTON | NC | 28401 | NEW HANOVER | 04 | 34.28332 | -77.98523 | Nitrogen oxides | Pounds | CAMD | 2013 | 7361054 |
| DUKE ENERGY PROGRESS, LLC - L.V. SUTTON ELECTRIC PLANT | 110000350174 | 801 SUTTON STEAM PLANT ROAD | WILMINGTON | NC | 28401 | NEW HANOVER | 04 | 34.28332 | -77.98523 | Nitrogen oxides | Pounds | CAMD | 2014 | 1153192 |
| DUKE ENERGY PROGRESS, LLC - L.V. SUTTON ELECTRIC PLANT | 110000350174 | 801 SUTTON STEAM PLANT ROAD | WILMINGTON | NC | 28401 | NEW HANOVER | 04 | 34.28332 | -77.98523 | Nitrogen oxides | Pounds | CAMD | 2015 | 1094548 |
| DUKE ENERGY PROGRESS, LLC - L.V. SUTTON ELECTRIC PLANT | 110000350174 | 801 SUTTON STEAM PLANT ROAD | WILMINGTON | NC | 28401 | NEW HANOVER | 04 | 34.28332 | -77.98523 | Nitrogen oxides | Pounds | CAMD | 2016 | 1137062 |
| DUKE ENERGY PROGRESS, LLC - L.V. SUTTON ELECTRIC PLANT | 110000350174 | 801 SUTTON STEAM PLANT ROAD | WILMINGTON | NC | 28401 | NEW HANOVER | 04 | 34.28332 | -77.98523 | Nitrogen oxides | Pounds | CAMD | 2017 | 1237818 |
| DUKE ENERGY PROGRESS, LLC - L.V. SUTTON ELECTRIC PLANT | 110000350174 | 801 SUTTON STEAM PLANT ROAD | WILMINGTON | NC | 28401 | NEW HANOVER | 04 | 34.28332 | -77.98523 | Nitrogen oxides | Pounds | CAMD | 2018 | 1102918 |

There are only two valid arguments for `echoGetCAAPR`.

    p_id    string  EPA Facility Registry Service's REGISTRY_ID.

    p_units string  Units of measurement. Defaults is 'lbs'.
                    Enter "TPWE" for toxic weighted pounds equivalents.

### Water facility and discharge searches

Find facilities with NPDES permits to discharge wastewater:

``` r

df <- echoWaterGetFacilityInfo(p_c1lon = '-96.407563', p_c1lat = '30.554395', 
                               p_c2lon = '-96.25947',  p_c2lat = '30.751984', 
                               output = 'df', qcolumns = "1,2,3,4,5,6,7")
```

| CWPName | SourceID | CWPStreet | CWPCity | CWPState | CWPStateDistrict | CWPZip |
|:---|:---|:---|:---|:---|:---|:---|
| 066-3344 BORLAUG CENTER RENOVATION ADDITION | TXR1579LK | 600 JOHN KIMBROUGH BLVD | COLLEGE STATION | TX | 9 | 77843-0001 |
| 1407 CONNOR STREET | TXR1539NY | 1407 CONNOR STREET | BRYAN | TX | 9 | 77808 |
| 2900 SPECTOR DRIVE | TXR1571JJ | 2900 SPECTOR DRIVE | BRYAN | TX | NA | 77802 |
| 2901 SPECTOR DRIVE | TXR1531KC | 2901 SPECTOR DRIVE | BRYAN | TX | NA | 77802 |
| 2921 SPECTOR DRIVE | TXR1587NL | 2921 SPECTOR DR | BRYAN | TX | NA | 77802 |
| 3444 MAHOGANY DRIVE | TXR1509EW | SOUTHWEST OF THE INTERSECTION OF MAHOGANY DRIVE AN | BRYAN | TX | NA | 77807 |

Again, there are a ton of possible arguments to query ECHO with. All
arguments are described here:
<https://echo.epa.gov/tools/web-services/facility-search-water#!/Facility_Information/get_cwa_rest_services_get_facility_info>

Commonly used arguments are provided below:

    p_fn  string  Facility Name Filter.
                  One or more case-insesitive facility names.
                  Provide multiple values as comma-delimited list
                  ex:
                  p_fn = "Aggie Cleaners, City of Bryan, TEXAS A&M UNIVERSITY COLLEGE STATION CAMPUS"
                  
    p_sa  string  Facility Street Address
                  ex:
                  p_sa = "WELLBORN ROAD & UNIVERSITY DR"
                  
    p_ct  string  Facility City
                  Provide a single case-insensitive city name
                  ex:
                  p_ct = "College Station"
                  
    p_co  string  Facility County
                  Provide a single county name, in combination with a state value
                  provided through p_st
                  ex:
                  p_co = "Brazos", p_st = "Texas"
                  
    p_fips  string  FIPS Code
                    Single 5-character Federal Information Processing Standards (FIPS) 
                    state+county value
                    
    p_st  string  Facility State or State Equivalent Filter
                  Provide one or more USPS postal abbreviations
                  ex:
                  p_st = "TX, NC"
                  
    p_zip string  Facility 5-Digit Zip Code
                  Provide one or more 5-digit postal zip codes
                  ex:
                  p_zip = "77843, 77845"
                  
    p_c1lon  string  Minimum longitude value in decimal degrees

    p_c1lat  string  Minimum latitude value in decimal degrees

    p_c2lon  string  Maximum longitude value in decimal degrees

    p_c1lat  string  Maximum latitude value in decimal degrees

    p_huc string  2-,4,6-,or 8-digit watershed code.
                  May contain comma-seperated values
                  

Download discharge monitoring reports from ECHO from specified
facilities:

``` r

df <- echoGetEffluent(p_id = 'tx0119407', parameter_code = '50050')
```

| activity_id | npdes_id | version_nmbr | perm_feature_id | perm_feature_nmbr | perm_feature_type_code | perm_feature_type_desc | limit_set_id | limit_set_schedule_id | limit_id | limit_season_id | limit_type_code | limit_begin_date | limit_end_date | nmbr_of_submission | parameter_code | parameter_desc | monitoring_location_code | monitoring_location_desc | stay_type_code | stay_type_desc | limit_value_id | limit_value_type_code | limit_value_type_desc | limit_value_nmbr | limit_unit_code | limit_unit_desc | standard_unit_code | standard_unit_desc | limit_value_standard_units | statistical_base_code | statistical_base_short_desc | statistical_base_type_code | statistical_base_type_desc | limit_value_qualifier_code | stay_value_nmbr | dmr_event_id | monitoring_period_end_date | dmr_form_value_id | value_type_code | value_type_desc | dmr_value_id | dmr_value_nmbr | dmr_unit_code | dmr_unit_desc | dmr_value_standard_units | dmr_value_qualifier_code | value_received_date | days_late | nodi_code | nodi_desc | exceedence_pct | npdes_violation_id | violation_code | violation_desc | rnc_detection_code | rnc_detection_desc | rnc_detection_date | rnc_resolution_code | rnc_resolution_desc | rnc_resolution_date | violation_severity | dmr_due_date | dmr_limit_type_code_desc | dmr_limit_type_desc |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 3602064155 | TX0119407 | 0 | 3600435311 | 001 | EXO | External Outfall | 3600478276 | 3600684408 | 3604917390 | 0 | ENF | 01/01/2020 | 12/06/2024 | 1 | 50050 | Flow, in conduit or thru treatment plant | 1 | Effluent Gross |  |  | 3608344140 | Q2 | Quantity2 |  | 03 | MGD | 03 | MGD |  | DD | DAILY MX | MAX | Maximum |  |  | 3612968295 | 01/31/2021 | 3788199991 | Q2 | Quantity2 | 3732924938 | .0849 | 03 | MGD | .0849 | = | 02/10/2021 |  |  |  |  |  |  |  |  |  |  |  |  |  | No Violation Identified | 02/20/2021 | Enforcement | Base Permit |
| 3602064155 | TX0119407 | 0 | 3600435311 | 001 | EXO | External Outfall | 3600478276 | 3600684408 | 3604917390 | 0 | ENF | 01/01/2020 | 12/06/2024 | 1 | 50050 | Flow, in conduit or thru treatment plant | 1 | Effluent Gross |  |  | 3608344141 | Q1 | Quantity1 | .131 | 03 | MGD | 03 | MGD | .131 | DB | DAILY AV | AVG | Average | \<= |  | 3612968295 | 01/31/2021 | 3788199987 | Q1 | Quantity1 | 3732924937 | .0604 | 03 | MGD | .0604 | = | 02/10/2021 |  |  |  |  |  |  |  |  |  |  |  |  |  | No Violation Identified | 02/20/2021 | Enforcement | Base Permit |
| 3602064155 | TX0119407 | 0 | 3600435311 | 001 | EXO | External Outfall | 3600478276 | 3600684408 | 3604917390 | 0 | ENF | 01/01/2020 | 12/06/2024 | 1 | 50050 | Flow, in conduit or thru treatment plant | 1 | Effluent Gross |  |  | 3608344141 | Q1 | Quantity1 | .131 | 03 | MGD | 03 | MGD | .131 | DB | DAILY AV | AVG | Average | \<= |  | 3612968298 | 02/28/2021 | 3788200098 | Q1 | Quantity1 | 3735355399 | .0569 | 03 | MGD | .0569 | = | 03/09/2021 |  |  |  |  |  |  |  |  |  |  |  |  |  | No Violation Identified | 03/20/2021 | Enforcement | Base Permit |
| 3602064155 | TX0119407 | 0 | 3600435311 | 001 | EXO | External Outfall | 3600478276 | 3600684408 | 3604917390 | 0 | ENF | 01/01/2020 | 12/06/2024 | 1 | 50050 | Flow, in conduit or thru treatment plant | 1 | Effluent Gross |  |  | 3608344140 | Q2 | Quantity2 |  | 03 | MGD | 03 | MGD |  | DD | DAILY MX | MAX | Maximum |  |  | 3612968298 | 02/28/2021 | 3788200099 | Q2 | Quantity2 | 3735355400 | .1109 | 03 | MGD | .1109 | = | 03/09/2021 |  |  |  |  |  |  |  |  |  |  |  |  |  | No Violation Identified | 03/20/2021 | Enforcement | Base Permit |
| 3602064155 | TX0119407 | 0 | 3600435311 | 001 | EXO | External Outfall | 3600478276 | 3600684408 | 3604917390 | 0 | ENF | 01/01/2020 | 12/06/2024 | 1 | 50050 | Flow, in conduit or thru treatment plant | 1 | Effluent Gross |  |  | 3608344140 | Q2 | Quantity2 |  | 03 | MGD | 03 | MGD |  | DD | DAILY MX | MAX | Maximum |  |  | 3612968306 | 03/31/2021 | 3788200195 | Q2 | Quantity2 | 3736849014 | .0809 | 03 | MGD | .0809 | = | 04/13/2021 |  |  |  |  |  |  |  |  |  |  |  |  |  | No Violation Identified | 04/20/2021 | Enforcement | Base Permit |
| 3602064155 | TX0119407 | 0 | 3600435311 | 001 | EXO | External Outfall | 3600478276 | 3600684408 | 3604917390 | 0 | ENF | 01/01/2020 | 12/06/2024 | 1 | 50050 | Flow, in conduit or thru treatment plant | 1 | Effluent Gross |  |  | 3608344141 | Q1 | Quantity1 | .131 | 03 | MGD | 03 | MGD | .131 | DB | DAILY AV | AVG | Average | \<= |  | 3612968306 | 03/31/2021 | 3788200189 | Q1 | Quantity1 | 3736849013 | .0581 | 03 | MGD | .0581 | = | 04/13/2021 |  |  |  |  |  |  |  |  |  |  |  |  |  | No Violation Identified | 04/20/2021 | Enforcement | Base Permit |

This function only retrieves from a single facility per call. The
following arguments are available from ECHO:

    p_id            string  EPA Facility Registry Service's REGISTRY_ID.

    outfall         string  Three-character code identifying the point of discharge.

    parameter_code  string  Five-digit numeric code identifying the parameter.

    start_date      string  Start date of interest. Must be entered as "mm/dd/yyyy"

    end_date        string  End date of interest. Must be entered as "mm/dd/yyyy"

Parameters codes can be searched using `echoWaterGetParams`.

``` r

echoWaterGetParams(term = "Oxygen, dissolved")
#> # A tibble: 5 × 2
#>   ValueCode ValueDescription                     
#>   <chr>     <chr>                                
#> 1 00300     Oxygen, dissolved [DO]               
#> 2 51646     Oxygen, dissolved [DO] maximum       
#> 3 51645     Oxygen, dissolved [DO] minimum       
#> 4 00301     Oxygen, dissolved percent saturation 
#> 5 00399     Oxygen, dissolved, % of time violated
```

Multiple DMRs can be downloaded using a helper function: `downloadDMRs`:

``` r

df <- tibble::tibble(permit = c('TX0119407', 'TX0062677'))
df <- downloadDMRs(df, idColumn = permit)
df <- df %>%
  tidyr::unnest(dmr)
tibble::glimpse(df)
#> Rows: 2,479
#> Columns: 66
#> $ permit                      <chr> "TX0119407", "TX0119407", "TX0119407", "TX…
#> $ activity_id                 <chr> "3602064155", "3602064155", "3602064155", …
#> $ npdes_id                    <chr> "TX0119407", "TX0119407", "TX0119407", "TX…
#> $ version_nmbr                <chr> "0", "0", "0", "0", "0", "0", "0", "0", "0…
#> $ perm_feature_id             <chr> "3600435311", "3600435311", "3600435311", …
#> $ perm_feature_nmbr           <chr> "001", "001", "001", "001", "001", "001", …
#> $ perm_feature_type_code      <chr> "EXO", "EXO", "EXO", "EXO", "EXO", "EXO", …
#> $ perm_feature_type_desc      <chr> "External Outfall", "External Outfall", "E…
#> $ limit_set_id                <chr> "3600478276", "3600478276", "3600478276", …
#> $ limit_set_schedule_id       <chr> "3600684408", "3600684408", "3600684408", …
#> $ limit_id                    <chr> "3604917385", "3604917385", "3604917385", …
#> $ limit_season_id             <chr> "0", "0", "0", "0", "0", "0", "0", "0", "0…
#> $ limit_type_code             <chr> "ENF", "ENF", "ENF", "ENF", "ENF", "ENF", …
#> $ limit_begin_date            <chr> "01/01/2020", "01/01/2020", "01/01/2020", …
#> $ limit_end_date              <chr> "12/06/2024", "12/06/2024", "12/06/2024", …
#> $ nmbr_of_submission          <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1…
#> $ parameter_code              <chr> "00300", "00300", "00300", "00300", "00300…
#> $ parameter_desc              <chr> "Oxygen, dissolved [DO]", "Oxygen, dissolv…
#> $ monitoring_location_code    <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1…
#> $ monitoring_location_desc    <chr> "Effluent Gross", "Effluent Gross", "Efflu…
#> $ stay_type_code              <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ stay_type_desc              <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ limit_value_id              <chr> "3608344130", "3608344130", "3608344130", …
#> $ limit_value_type_code       <chr> "C1", "C1", "C1", "C1", "C1", "C1", "C1", …
#> $ limit_value_type_desc       <chr> "Concentration1", "Concentration1", "Conce…
#> $ limit_value_nmbr            <chr> "4", "4", "4", "4", "4", "4", "4", "4", "4…
#> $ limit_unit_code             <chr> "19", "19", "19", "19", "19", "19", "19", …
#> $ limit_unit_desc             <chr> "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", "m…
#> $ standard_unit_code          <chr> "19", "19", "19", "19", "19", "19", "19", …
#> $ standard_unit_desc          <chr> "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", "m…
#> $ limit_value_standard_units  <chr> "4", "4", "4", "4", "4", "4", "4", "4", "4…
#> $ statistical_base_code       <chr> "MO", "MO", "MO", "MO", "MO", "MO", "MO", …
#> $ statistical_base_short_desc <chr> "MO MIN", "MO MIN", "MO MIN", "MO MIN", "M…
#> $ statistical_base_type_code  <chr> "MIN", "MIN", "MIN", "MIN", "MIN", "MIN", …
#> $ statistical_base_type_desc  <chr> "Minimum", "Minimum", "Minimum", "Minimum"…
#> $ limit_value_qualifier_code  <chr> ">=", ">=", ">=", ">=", ">=", ">=", ">=", …
#> $ stay_value_nmbr             <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ dmr_event_id                <chr> "3612968295", "3612968298", "3612968306", …
#> $ monitoring_period_end_date  <chr> "01/31/2021", "02/28/2021", "03/31/2021", …
#> $ dmr_form_value_id           <chr> "3788199942", "3788200055", "3788200133", …
#> $ value_type_code             <chr> "C1", "C1", "C1", "C1", "C1", "C1", "C1", …
#> $ value_type_desc             <chr> "Concentration1", "Concentration1", "Conce…
#> $ dmr_value_id                <chr> "3732924936", "3735355411", "3736849023", …
#> $ dmr_value_nmbr              <chr> "5.9", "5.73", "5.6", "4.7", "5.52", "5.79…
#> $ dmr_unit_code               <chr> "19", "19", "19", "19", "19", "19", "19", …
#> $ dmr_unit_desc               <chr> "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", "m…
#> $ dmr_value_standard_units    <chr> "5.9", "5.73", "5.6", "4.7", "5.52", "5.79…
#> $ dmr_value_qualifier_code    <chr> "=", "=", "=", "=", "=", "=", "=", "=", "=…
#> $ value_received_date         <chr> "02/10/2021", "03/09/2021", "04/13/2021", …
#> $ days_late                   <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ nodi_code                   <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ nodi_desc                   <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ exceedence_pct              <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ npdes_violation_id          <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ violation_code              <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ violation_desc              <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ rnc_detection_code          <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ rnc_detection_desc          <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ rnc_detection_date          <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ rnc_resolution_code         <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ rnc_resolution_desc         <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ rnc_resolution_date         <chr> "", "", "", "", "", "", "", "", "", "", ""…
#> $ violation_severity          <chr> "No Violation Identified", "No Violation I…
#> $ dmr_due_date                <chr> "02/20/2021", "03/20/2021", "04/20/2021", …
#> $ dmr_limit_type_code_desc    <chr> "Enforcement", "Enforcement", "Enforcement…
#> $ dmr_limit_type_desc         <chr> "Base Permit", "Base Permit", "Base Permit…
```
