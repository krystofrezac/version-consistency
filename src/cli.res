type parsedCli = {positionalArguments: array<string>, help: option<bool>}

let parseCli = () => {
  open Json.Decode
  let commandArguments =
    Node.Process.argv
    ->Belt.Array.sliceToEnd(2)
    ->Minimist.parseCommandArguments
    ->Js.Json.stringifyAny
    ->Belt.Option.getExn
    ->Js.Json.parseExn

  let decoder = {
    map2(field("_", array(string)), option(field("help", bool)), ~f=(positionalArguments, help) => {
      positionalArguments,
      help,
    })
  }

  commandArguments->decodeValue(decoder)
}

type cliAction = Check | Help | Error
let evaluateCliAction = parsedCliResult => {
  switch parsedCliResult {
  | Ok(parsedCli) =>
    switch (parsedCli.positionalArguments, parsedCli.help) {
    | (_, Some(true)) => Help
    | (["check"], _) => Check
    | (_, _) => Error
    }
  | Error(_) => Error
  }
}

let getHelpString = () => {
  `
  version-consistency [command] 

  [command]   check/fix

  --help      Show help
  `
}
