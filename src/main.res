let check = () => {
  let rootDirPath = Node.Process.cwd()

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

let runCommand = (action: Cli.cliAction) => {
  switch action {
  | Check => check()
  | Help => Cli.getHelpString()->Js.log
  | Error => {
      Cli.getHelpString()->Js.log
      Node.Process.exit(1)
    }
  }
}

let main = () => {
  Cli.parseCli()->Cli.evaluateCliAction->runCommand
}

main()
