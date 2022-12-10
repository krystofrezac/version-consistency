Js.log("Hello, World!")

let check = rootDirPath => Interfaces.getPathsToPackageJsons(Yarn, rootDirPath)

check(Node.Process.cwd())->Js.log
