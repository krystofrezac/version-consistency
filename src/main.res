let check = rootDirPath => {
  let result =
    Interfaces.getPathsToPackageJsons(Yarn, rootDirPath)
    ->Belt.Result.flatMap(Dependencies.getGroupedWorkspaceDependencies)
    ->Belt.Result.flatMap(Versions.checkDependenciesVersions)

  switch result {
  | Ok() => ()
  | Error(error) => {
      Js.log(error)
      Node.Process.exit(1)
    }
  }
}

check(Node.Process.cwd())
