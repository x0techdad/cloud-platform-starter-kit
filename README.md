# Cloud Platform DevUX Starter Kit

> **Note:** this documentation is a work-in-progress - if you see something that's not quite right or missing, we'd really appreciate a PR!

Cloud Platform DevUX Starter Kit is a project where cloud platform dev tools are maintained.

---

## Available tools

* [setup-winDevEnv.ps1](/scripts/setup-winDevEnv.ps1): installs and configures commonly used cloud platform dev tools and OS settings on a local Windows system.
    * Dependencies:
        * PowerShell
        * Winget
        * Internet connectivity
    * Required access:
        * 3rd party app installs may require local admin privilege, user will be prompted for credentials during environment build.
        * No privileged access required to develop.
    * Testing: manual functional and acceptance testing of this script was perfmored using PowerShell 5.1.19041 and 7.3.3 on Windows 10.
    * Build:
        * Download or clone this source code repo
        * Run in Local PowerShell CLI:
            * Navigate to: `.\cloud-platform-dev-ux\scripts\`
            * Invoke script: `.\setup-winDevEnv.ps1`
        * Run in Docker: TODO

---

## Development and contributing

Check out the [developer guide](docs/guide-development.md) file for a basic overview on how to build and develop the project.  

Project overview, references, and detailed guides geared towards contributors available [here](CONTRIBUTING.md).