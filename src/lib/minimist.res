@module
external parseCommandArguments: array<string> => unknown = "minimist"

let a = parseCommandArguments([])
