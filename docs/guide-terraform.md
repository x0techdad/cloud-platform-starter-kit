# Terraform Guidance

> **Note:** this documentation is a work-in-progress - if you see something that's not quite right or missing, we'd really appreciate a PR!

---

## Naming conventions

### Files and folders

* Use `kebab-case`
* Short but descriptive (<25 characters)
* Avoid special characters and spaces

### Resources, variables and outputs

* Use `snake_case`
* Short but descriptive (<25 characters)
* Avoid special characters and spaces

## Syntax guidance

* Include a `description` in all variables and outputs created.
* Include a `default` value and validation on all variables created.

## Best practices

### 1. Community vs. custom modules - use community modules when possible and when it fits the use case, don't reinvent the wheel. 
  
* Community modules are usually high quality code as they go through testing and practice enforcements. 
* If you have to create modules, make them generic, stateless, and clean Implement practice enforcements (linters, logical checks, etc.) to maintain high code quality.
* If you have to create modules, use semantic versioning and specify full version numbers : `2.0.1`. 
  * Full version number format : `MAJOR_version.MINOR_version.PATCH_version`.
  * `major_version` : when incompatible changes are made
  * `minor_version` : when functionality is added in a backwards compatible manner
  * `patch_version` : when backwards compatible bug fixes are made
  * Add additional suffix labels to identify pre-release modules : `0.1.0-beta`

### 2. Version locks - version lock modules, providers and Terraform core, lock with the appropriate constraint.

* Module versions
  * Use the `=` constraint operator to allow one exact version, for example : `= 2.0.1`. This achieves complete control over updates, a desired feature when using 3rd party modules. 
  * Use the pessimistic constraint operator `~>` and a full version number : `2.0.1` to allow the rightmost version number to increment and patch releases within a specific minor release. This example : `~> 2.0.1` will allow installation of `2.0.2` through `2.0.10` but not `2.1.0`.  This approach is desired when maintaining your own modules.
* Terraform core and provider versions :
  * In reusable/shared modules, constrain only the minimum allowed version of Terraform core and providers using the `>=` constraint operator. Allows for upgrades to new versions of Terraform with minimal module updates.  
  * Use the pessimistic constraint operator `~>` in root modules to constrain versions for each provider used. 

### 3. Tag resources - define a set of required tags to apply to all resources. 
  
* Consistent tagging is crucial for visibility/operations and FinOps/Cost management. 
* Use default tags to apply certain tags to all resources of a provider.
* Enforce required tags via practice enforcements. 

### 4. Remote state - use remote instead of local state to enable scalability, redundancy and backup of resource state. 

* Secure, backup, and enable versioning on state storage. 
* Lock state to prevent racing conditions.  

### 5. Variables vs. locals - use variables and locals appropriately.  
  
* Locals
  * Can use dynamic expressions and resource arguments.
  * Use as constants to be relied on, values do not change between runs (plan, apply or destroy). 
  * Avoid using locals on the live side to keep code simple. 
* Variables 
  * Variables vary
* Use variables and locals to merge deployment specific values with static values between runs, commonly used to merge required tags with deployment specific tags.

### 6.  Implement a standard file structure and naming convention on Terraform projects. 

* Decompose into the following community standard file structure and naming convention for better logical arrangement, readability and cleaner code : `main.tf`, `variables.tf`, `data.tf`, `version.tf`. 
* If `main.tf` is complex, decompose into sub-modules, align sub-modules with architecture domains or service types. Sub/nested modules can and should be re-used independently of the parent main.tf. 

### 7. Apply classic coding best practices

* Source Code Management
* KISS - keep code simple
* Human-readable & Clean Code
* DRY - Do not repeat yourself
* Functional programming
* Idempotency

### 8. Structure Terraform codebase

* Terraform is a platform, structure your code base with business and general infrastructure requirements.
  * Leads to less refactoring when requirements change.
  * Makes for easier developer onboarding to code bases.
* Follow a "live" vs. "module" structure
  * Think of module code as a software class, live code is the instantiation of the referenced class. 
* Implement a code owner strategy when sharing or reusing modules.
* Implement a small state strategy to reduce blast radius and prevent undesired behavior when updating resources. 
* Use Terraform workspaces appropriately and in supported scenarios.  Not suitable for isolation between prod and other SDLC stages. A common supported scenario is to support a side branch for testing complex infrastructure changes before commiting to `main`.
* When using workspaces, use a wrapper to facilitate context switching and limit human errors.

### 9. Execute terraform remotely.

* `tf apply` with a plan file
* Set an appropriate  `tf timeout`
* Lock state when remotely executing

### 10. Implement practices enforcements via CI pipeline checks.

* Lack of enforcement leads to security risk and non-compliant configurations.