# Powershell Utils

String manipulation Utilities.

## Development

* Get [Pester](https://pester.dev/docs/quick-start) for Testing.
* Get [PowerShell-Beautifier](https://github.com/DTW-DanWard/PowerShell-Beautifier) too.
* Get [PSScriptAnalyzer](https://www.powershellgallery.com/packages/PSScriptAnalyzer/1.21.0)

Run pre-commit install

Additional Quality Gate:

```ps1
pwsh -Command "& Invoke-ScriptAnalyzer -Recurse ./scripts/"
```

### On Windows

You'll need Bash

### Other OS

You'll need powershell which is available for most OSses

## Tools

### Acronymator

Suggests an Acronym based on input.
See [Tests](scripts/Acronymize.Tests.ps1) for examples.
