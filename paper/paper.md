---
title: `echor: An R package to obtain environmental compliance and enforcement data`
tags:
  - R
  - API
  - environmental data
  - Environmental Protection Agency
authors:
  - name: Michael P. Schramm
    orcid: 0000-0003-1876-6592
    affiliation: 1
affiliations:
  - index: 1
    name: Texas Water Resources Institute, Texas A&M University, College Station, Texas.
date:
bibliography: paper.bib
---

# Summary

The United States Environmental Protection Agency (EPA) regulates the discharge and emission of pollutants into waterbodies and air. The owners and operators of facilities apply for permits through the EPA or deligated state authorities, who determine the appropriate disharge limits, and monitoring and reporting requirements. Information about these permitted and mandated discharge reports are publically available through EPA's Environmental Compliance and History Online (ECHO) website [@us_environmental_protection_agency_enforcement_2018].

ECHO provides a web interface to explore facility data and environmental compliance for permitted drinking water plants, facilities permitted to discharge into water bodies, and facilities with air emissions permits. ECHO also provides a web interface to generate discharge and emissions reports based on self reported data from permitted facilities. The point and click nature of the ECHO website is tedious, error-prone, and may not be fully reproducible when generating even moderate sized datasets. Implementing a script to query and automate data retieval is the first step to implementing reproducible research [@sandve_ten_2013]. 

The echor package utilizes ECHO's REST services to query the ECHO database, download the generated data, and transform the data into a tidy dataframe or simple feature dataframe with a single function. Additional functions are provided to obtain metadata and lookup pollutant parameter codes used by EPA. The package streamlines workflows and introduces reproducible data retrieval steps for two use cases. First, agencies and contractors that routinely use wastewater discharge volume and pollutant concentrations to develop total maximum daily loads for impaired waterbodies. Second, academic researchers that use permit and pollutant data for water quality assessments, water quality models, public health assessments, trend analysis, environmental justice research, and more. The software and usage examples are currently available on GitHub (https://github.com/mps9506/echor) and CRAN (https://cran.r-project.org/package=echor).

# References
