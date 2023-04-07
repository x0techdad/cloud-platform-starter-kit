# Project overview

Please follow the defined structure and naming guidelines to keep code organized and usable.

---

## Top-level directory layout

    .
    └── cloud-platform-dev-ux
        ├── .vscode                 # IDE workspace config files
        ├── docs                    # Documentation files
        ├── modules                 # Infra modules
        ├── live                    # Infra live        
        ├── scripts                 # Scripted workflows
        ├── tests                   # Automated tests
        ├── CONTRIBUTING      
        ├── LICENSE
        └── README.md

## Naming conventions

### Files and folders

* Use `kebab-case`
* Short but descriptive (<25 characters)
* Avoid special characters and spaces
* If using date, use date format ISO 8601: YYYYMMDD
* Include a version number if applicable