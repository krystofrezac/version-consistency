module Yarn = {
  let getRootPackageJsonAsJson = rootDirPath => {
    try {
      Node.Path.join([rootDirPath, "package.json"])
      ->Node.Fs.readFileSync(#utf8)
      ->Js.Json.parseExn
      ->Ok
    } catch {
    | _ => Error("Couldn't read root package.json")
    }
  }

  let getWorkspacesPatterns = packageJsonContent => {
    open Json.Decode
    let decoder = oneOf(
      field("workspaces", array(string)),
      [at("workspaces", ["packages"], array(string))],
    )

    switch decodeValue(packageJsonContent, decoder) {
    | Ok(packages) => Ok(packages)
    | Error(_err) => Error("Couldn't decode package.json. It's probably missing 'workspaces' field")
    }
  }

  let getPackagePathsFromWorkspacesPatterns = workspacesPatterns =>
    workspacesPatterns
    ->Belt.Array.flatMap(globPattern => Glob.glob(globPattern ++ "/package.json"))
    ->Belt.Array.map(path => Node.Path.resolve(path, ""))

  let getPathsToPackageJsons = rootDirPath => {
    switch getRootPackageJsonAsJson(rootDirPath)->Belt.Result.flatMap(getWorkspacesPatterns) {
    | Ok(workspacesPatterns) => getPackagePathsFromWorkspacesPatterns(workspacesPatterns)->Ok
    | Error(msg) => Error(msg)
    }
  }
}

type packageManager = Yarn

let getPathsToPackageJsons = (packageManager, rootDirPath) => {
  let specificFun = switch packageManager {
  | Yarn => Yarn.getPathsToPackageJsons
  }

  specificFun(rootDirPath)
}
