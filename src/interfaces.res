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

  let getWorkspaceField = packageJsonContent => {
    switch packageJsonContent {
    | Some(object) =>
      switch Js.Json.decodeObject(object) {
      | Some(objectContent) =>
        switch Js.Dict.get(objectContent, "name") { // TODO: Rename to workspace
        | Some(workspace) => Some(workspace)

        | None => None
        }
      | None => None
      }
    | None => None
    }
  }

  let getPathsToPackageJsons = rootDirPath => {
    let workspace = getRootPackageJsonAsJson(rootDirPath)->getWorkspaceField
    switch workspace {
    | Some(name) => Js.Json.decodeString(name)

    | None => None
    }
  }
}

type packageManager = Yarn | NPM

let getPathsToPackageJsons = (packageManager, rootDirPath) => {
  let specificFun = switch packageManager {
  | Yarn => Yarn.getPathsToPackageJsons
  | NPM => Yarn.getPathsToPackageJsons
  }

  specificFun(rootDirPath)
}
