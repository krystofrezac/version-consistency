module Yarn = {
  let getRootPackageJsonAsJson = rootDirPath => {
    try {
      Node.Path.join([rootDirPath, "package.json"])
      ->Node.Fs.readFileSync(#utf8)
      ->Js.Json.parseExn
      ->Some
    } catch {
    | _ => None
    }
  }

  let getPackageJsonPackages = packageJsonContent => {
    open Json.Decode
    let decoder = oneOf(
      field("workspaces", array(string)),
      [at("workspaces", ["packages"], array(string))],
    )

    switch decodeValue(packageJsonContent, decoder) {
    | Ok(packages) => Some(packages)
    | Error(_err) => None
    }
  }

  let getPathsToPackageJsons = rootDirPath =>
    switch getRootPackageJsonAsJson(rootDirPath) {
    | Some(packageJson) => getPackageJsonPackages(packageJson)->Some
    | None => None
    }
}

type packageManager = Yarn

let getPathsToPackageJsons = (packageManager, rootDirPath) => {
  let specificFun = switch packageManager {
  | Yarn => Yarn.getPathsToPackageJsons
  }

  specificFun(rootDirPath)
}
