let check = rootDirPath => {
  Interfaces.getPathsToPackageJsons(Yarn, rootDirPath)->Belt.Result.flatMap(
    Dependencies.getWorkspaceDependencies,
  )
}

check(Node.Process.cwd())->Js.log
