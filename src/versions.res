type dependencyWithConsistency = {
  dependencyName: string,
  dependencyVersion: string,
  dependencyType: Dependencies.dependencyType,
  packageName: string,
  /**
  * true = is ok
  * false = is outdated
  */
  isConsistent: bool,
}

let getCorrectLatestDependencyOfGroup = (dependencyGroup: array<Dependencies.dependency>) => {
  dependencyGroup
  ->Belt.SortArray.stableSortBy((
    {dependencyVersion: aVersion, dependencyType: aType},
    {dependencyVersion: bVersion, dependencyType: bType},
  ) => {
    let versionCompare = Semver.Functions.rcompare(
      Semver.Ranges.minVersion(aVersion),
      Semver.Ranges.minVersion(bVersion),
    )

    // Workspace version is always the correct latest version if present
    switch (aType == WorkspacePackage, bType == WorkspacePackage) {
    | (true, false) => -1
    | (false, true) => 1
    | (_, _) => versionCompare
    }
  })
  ->Belt.Array.get(0)
}

let getDependencyGroupsWithConsistencyCheck = (
  dependencyGroups: array<array<Dependencies.dependency>>,
) => {
  dependencyGroups->Belt.Array.map(dependencyGroup => {
    let maybeLatestDependency = getCorrectLatestDependencyOfGroup(dependencyGroup)

    switch maybeLatestDependency {
    | Some(latestDependency) =>
      dependencyGroup->Belt.Array.map(dependency => {
        dependencyName: dependency.dependencyName,
        dependencyVersion: dependency.dependencyVersion,
        dependencyType: dependency.dependencyType,
        packageName: dependency.packageName,
        isConsistent: Semver.Ranges.intersects(
          dependency.dependencyVersion,
          latestDependency.dependencyVersion,
        ),
      })
    | None => []
    }
  })
}

let isDependencyGroupConsistent = dependencyGroup => {
  dependencyGroup->Belt.Array.every(dependency => {
    dependency.isConsistent
  })
}

let formatIconsistenGroupsError = (inconsistentGroups: array<array<dependencyWithConsistency>>) => {
  inconsistentGroups
  ->Belt.Array.map(inconsistenGroup => {
    let maybeFirstDependency = Belt.Array.get(inconsistenGroup, 0)

    switch maybeFirstDependency {
    | Some(firstDependency) => {
        let dependencyList =
          inconsistenGroup
          ->Belt.Array.map(({
            dependencyName,
            dependencyVersion,
            dependencyType,
            packageName,
            isConsistent,
          }) => {
            let dependencyTypeText = switch dependencyType {
            | Dependency => "dependencies"
            | DevDependency => "devDependencies"
            | PeerDependency => "peerDependency"
            | Resolution => "resolutions"
            | WorkspacePackage => "version"
            }

            let text = `  - ${dependencyName}@${Colorette.bold(
                dependencyVersion,
              )} in ${packageName} ${Colorette.dim(dependencyTypeText)}`

            isConsistent ? Colorette.green(text) : Colorette.red(text)
          })
          ->Belt.Array.joinWith("\n", item => item)

        `${Colorette.bold(firstDependency.dependencyName)}\n${dependencyList}`
      }

    | None => ""
    }
  })
  ->Belt.Array.joinWith("\n", item => item)
}

let checkDependenciesVersions = groupedDependencies => {
  let inconsistenGroups =
    groupedDependencies
    ->getDependencyGroupsWithConsistencyCheck
    ->Belt.Array.keep(dependencyGroup => dependencyGroup->isDependencyGroupConsistent->not)

  switch Belt.Array.length(inconsistenGroups) === 0 {
  | true => Ok()
  | false => Error(inconsistenGroups->formatIconsistenGroupsError)
  }
}
