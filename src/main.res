let check = rootDirPath => {
  let result =
    Interfaces.getPathsToPackageJsons(Yarn, rootDirPath)
    ->Belt.Result.flatMap(Dependencies.getGroupedWorkspaceDependencies)
    ->Belt.Result.flatMap(Versions.checkDependenciesVersions)

  switch result {
  | Ok() => Js.log("OK")
  | Error(error) => Js.log(error)
  }
}

check(Node.Process.cwd())
