let check = rootDirPath => {
  Interfaces.getPathsToPackageJsons(Yarn, rootDirPath)->Belt.Result.flatMap(
    Dependencies.getGroupedWorkspaceDependencies,
  )
}

check(Node.Process.cwd())->Js.log
