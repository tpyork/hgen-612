---
output:
  html_document: default
  pdf_document: default
---


## File Summary
`R/hgen-612_git-tutorial` is shared to students; contains all files for manipulation; copy these piecemeal to `hgen-612_temp`  


## RStudio & Git
- download `hgen-612_git-tutorial` from OSF which has all files  
- create new project `hgen-612_temp` in RStudio using wizard  
    - select 'New Directory/New Project'
    - check 'Create a git repository'
- show hidden files and inspect `.git`
- inspect `.gitignore`; will come back to it later
- add `R/1_clean-data.R` and commit all files
    - inspect commit history
    - add the following code in `1_clean-data.R`, run and commit: `fs::dir_create("app/data")`
- edit `.gitignore` to not track `data` folder
    - commit changed files
    - inspect commit history showing 2 commits
- add `gyser.R` to `app` folder and commit
- make changes in `app/geyser.R` and commit
    - change histogram fill to purple
    - commit changes
- rewind to previous version:  `git checkout SHA app/geyser.R`
- try out a new branch: 
    - `git branch`
    - `git branch test`
    - `git checkout test`
- make terrible changes to `test` branch:
    - `plot(faithful2$eruptions, faithful2$waiting.minute, type = "h")`
    - commit
- merge test back with master: 
    - `git checkout master`
    - `git merge test`
- realize mistake and rewide to original version on master
    - `git checkout SHA app/geyser.R`


## RStudio and Github
- create GitHub repo for `hgen-612_temp`
- add remote using RStudio and push an existing repository from the command line in Terminal:
    - `git remote add origin https://github.com/tpyork/hgen-612_temp.git`
    - `git push -u origin master`
- add README.md on GitHub and `pull` to local repo



