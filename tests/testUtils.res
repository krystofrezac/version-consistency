module Yarn = {
  let parseWorkspacesToString = workspaces => {
    Js.Json.serializeExn(workspaces)
  }

  let createPackageJson = (~name, ~workspaces=?, ~nestedWorkspaces=false, ()) => {
    let parsedWorkspaces = parseWorkspacesToString(workspaces)

    let resultWorkspaces = switch nestedWorkspaces {
    | false => `"workspaces": ${parsedWorkspaces}`
    | true => `"workspaces": {"packages": ${parsedWorkspaces}}`
    }

    `
    {
      "name": "${name}",
      ${resultWorkspaces}
    }
    `
  }
}

module Common = {
  let getDependenciesEntry = (dependenciesType, dependencies) => {
    switch dependencies {
    | Some(dependencies) => {
        let parsedDependencies =
          dependencies
          ->Belt.Array.map(((dependency, version)) => `"${dependency}": "${version}"`)
          ->Belt.Array.joinWith(",", item => item)
        `,"${dependenciesType}": {
          ${parsedDependencies}
          }
        `
      }

    | None => ""
    }
  }

  let createPackageJson = (
    ~name,
    ~version,
    ~dependencies as passedDependencis=?,
    ~devDependencies as passedDevDependencies=?,
    ~peerDependencies as passedPeerDependencies=?,
    ~resolutions as passedResolutions=?,
    (),
  ) => {
    `
  {
    "name": "${name}",
    "version": "${version}"
    ${getDependenciesEntry("dependencies", passedDependencis)}
    ${getDependenciesEntry("devDependencies", passedDevDependencies)}
    ${getDependenciesEntry("peerDependencies", passedPeerDependencies)}
    ${getDependenciesEntry("resolutions", passedResolutions)}
  }
  `
  }
}
