## Brief description

This is an **automatically generated PR**. 
The following steps are all automatically performed:

- Fetch [raw data](https://docs.google.com/spreadsheets/d/1_cBgfSjnxakLAQ9uGunDt_-Mk4L0uDx2-qv6cKCzkSk/edit#gid=1072727594) from [bullfrog managment app](https://www.appsheet.com/start/afc6e636-5022-4c6c-ba8c-bf1af26432f5)
- Summarise data per fyke, per manangement event & prepare data for dwc mapping
  - the catch per fyke & per manangement event summaries are saved in `./interim/`
  - the data for the dwc mapping is saved in `./output/`
- Get an overview of the changes

Note to the reviewer: the workflow automation is still in a development phase. Please, check the output thoroughly before merging to `main`. In case, improve the data fecthing  `data_cleaning_afvangsten.Rmd`, in  `./script/` or  the GitHub workflows  `fetch-data.yaml` in `./.github/workflows`.
