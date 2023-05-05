# Cloud platform starter-kit contributor guides

> **Note:** this documentation is a work-in-progress - if you see something that's not quite right or missing, we'd really appreciate a PR!

Thank you for your interest in contributing to the Project! If you have questions or need help, please open a draft pull request (PR) or an issue and we'll do our best to guide you in the right direction.

When contributing to this project please follow guidance to help speed up testing and acceptance of your changes. This guide assumes you have at least a basic understanding of tools, frameworks and languages used in this project. 

Thank you for your support and contributions, happy engineering!

---

## Basics

* [Codebase standards](#codebase-standards)
* Opening a PR
* Creating an Issue

## Engineering guidance and best practices

* Cloud platform engineering
  * GCP
  * AWS
  * Azure
* [Markdown coding](/docs/guide-markdown.md)
* [Powershell coding](/docs/guide-powershell.md)
* [Terraform coding](/docs/guide-powershell.md)

## Codebase standards

Please align to the below standards to speed up acceptance of changes.

### File and folder naming convention

* Use `kebab-case`
* Short but descriptive (<25 characters)
* Avoid special characters and spaces
* If using date, use date format ISO 8601: YYYYMMDD
* Include a version number if applicable

### Structure

    .
    ├── CONTRIBUTING.md               # Project contributing guidance
    ├── README.md                     # Project overview
    ├── LICENSE                       # Project license
    ├── ...                           # Additional files
    ├── .vscode                       # VSCode workspace config files
    ├── docs                          # Documentation
    ├── examples                      # Examples
    │   └── windows-cloud-sandbox       # Example use case
    │   │   └── setup-WinSbx.ps1          # Example code
    │   ├── .../                        # Additional example use cases
    └── tests                         # Project tests 