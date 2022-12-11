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
