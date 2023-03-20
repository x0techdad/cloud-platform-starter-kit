# Platform Starter Kit

> **Note:** this documentation is a work-in-progress - if you see something that's not quite right or missing, we'd really appreciate a PR!

The Platform Starter-Kit is a Project used to bootstrap fundamental Components (resources and configuration) of an enterprise-scale public cloud platform.

---

## Requirements

### Required software

* Git
* PowerShell
* Terraform CLI
* Azure CLI

This project has been tested with the following versions of required software

    Git v2.39.2
    PowerShell 2023.2.1
    Terraform v1.4.1
    Azure CLI v2.46.0

### Required access

A user principle with the following access to cloud services. 

| Scope                                | Least Privileged Roles    |
| :----------------------------------- | ------------------------: |
| Platform IdP (Azure AD Tenant)       | Application Administrator |
| " "                                  | Groups Administrator      |
| Platform CSP (Azure Billing Account) | Subscription Contributor  |


## Setup

1. Download or clone this source code repo
2. [Build](#build)

## Build

### Run in Local CLI

1. Navigate to `./infra/build/local`
2. Authorize in Azure CLI

        az login

### Run in Docker

#### Azure Container Instance

TODO

---

## Development and Contributing

Check out the [developer guide](docs/guide-developing.md) file for a basic overview on how to build and develop the project.  

Project overview, references, and detailed guides geared towards contributors available [here](CONTRIBUTING.md).