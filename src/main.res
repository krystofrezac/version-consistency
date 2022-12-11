Js.log("Hello, World!")

let check = rootDirPath => {
  switch Interfaces.getPathsToPackageJsons(Yarn, rootDirPath) {
  | Ok(paths) => paths
  | Error(msg) => {
      Js.Console.error(`Error: ${msg}`)
      Node.Process.exit(1)
    }
  }
}

check(Node.Process.cwd())->Js.log
