let getPackageJsonAsJson = packageJsonPath => {
  try {
    packageJsonPath->Node.Fs.readFileSync(#utf8)->Js.Json.parseExn->Ok
  } catch {
  | _ => Error(`Couldn't read ${packageJsonPath}`)
  }
}

type packageJsonDependencies = array<(string, string)>
type packageJson = {
  name: string,
  version: string,
  dependencies: option<packageJsonDependencies>,
  devDependencies: option<packageJsonDependencies>,
  peerDependencies: option<packageJsonDependencies>,
  resolutions: option<packageJsonDependencies>,
}

let parsePackageJson = packageJsonContent => {
  open Json.Decode
  let decoder = map6(
    field("name", string),
    field("version", string),
    option(field("dependencies", keyValuePairs(string))),
    option(field("devDependencies", keyValuePairs(string))),
    option(field("peerDependencies", keyValuePairs(string))),
    option(field("resolutions", keyValuePairs(string))),
    ~f=(
      name,
      version,
      dependencies,
      devDependencies,
      peerDependencies,
      resolutions,
    ): packageJson => {
      name,
      version,
      dependencies,
      devDependencies,
      peerDependencies,
      resolutions,
    },
  )

  switch decodeValue(packageJsonContent, decoder) {
  | Ok(value) => Ok(value)
  | Error(_) => Error("Couldn't decode package.json. It's probably because of syntax error")
  }
}

type dependencyType = Dependency | DevDependency | PeerDependency | Resolution | WorkspacePackage
type dependency = {
  dependencyName: string,
  dependencyVersion: string,
  packageName: string,
  dependencyType: dependencyType,
}

let joinDependencyTypeGroups = (dependencyGroups, packageName) => {
  dependencyGroups->Belt.Array.flatMap(((dependencyGroup, dependencyGroupType)) => {
    dependencyGroup->Belt.Array.map(((dependencyName, dependencyVersion)) => {
      dependencyName,
      dependencyVersion,
      packageName,
      dependencyType: dependencyGroupType,
    })
  })
}

let processPackageJsonDependencies = ({
  name,
  version,
  dependencies,
  devDependencies,
  peerDependencies,
  resolutions,
}) => {
  let workspacePackage = {
    dependencyName: name,
    dependencyVersion: version,
    packageName: name,
    dependencyType: WorkspacePackage,
  }

  [
    (dependencies, Dependency),
    (devDependencies, DevDependency),
    (peerDependencies, PeerDependency),
    (resolutions, Resolution),
  ]
  ->Belt.Array.map(((dependencyTypeGroup, dependencyTypeGroupType)) => (
    dependencyTypeGroup->Belt.Option.getWithDefault([]),
    dependencyTypeGroupType,
  ))
  ->joinDependencyTypeGroups(name)
  ->Belt.Array.concat([workspacePackage], _)
}

let getPackageDependencies = packageJsonPath => {
  packageJsonPath
  ->getPackageJsonAsJson
  ->Belt.Result.flatMap(parsePackageJson)
  ->Belt.Result.flatMap(parsedPackageJson => processPackageJsonDependencies(parsedPackageJson)->Ok)
}

let joinPackagesDependencies = dependenciesInfo => {
  Belt.Array.reduce(dependenciesInfo, Ok([]), (acc, current) => {
    switch (acc, current) {
    | (Error(errorAcc), _) => Error(errorAcc)
    | (_, Error(errorCurrent)) => Error(errorCurrent)
    | (Ok(okAcc), Ok(okCurrent)) => Belt.Array.concat(okAcc, okCurrent)->Ok
    }
  })
}

let sortDependenciesByName = dependencies => {
  let dependencyNameComparator = (a, b) => {
    let compareResult = Js.String.localeCompare(a.dependencyName, b.dependencyName)
    switch (compareResult < 0., compareResult > 0.) {
    | (true, _) => 1
    | (_, true) => -1
    | (false, false) => 0
    }
  }

  dependencies->Belt.SortArray.stableSortBy(dependencyNameComparator)
}

let groupDependencies = dependencies => {
  dependencies
  ->sortDependenciesByName
  ->ArrayUtils.groupBy((a, b) => a.dependencyName == b.dependencyName)
}

let getGroupedWorkspaceDependencies = packageJsonPaths => {
  packageJsonPaths
  ->Belt.Array.map(packageJsonPath => getPackageDependencies(packageJsonPath))
  ->joinPackagesDependencies
  ->Belt.Result.flatMap(joinedPackagesDependencies =>
    groupDependencies(joinedPackagesDependencies)->Ok
  )
}
