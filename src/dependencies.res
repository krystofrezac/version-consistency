type dependencies = array<(string, string)>
type packageJson = {
  name: string,
  version: string,
  dependencies: option<dependencies>,
  devDependencies: option<dependencies>,
  peerDependencies: option<dependencies>,
  resolutions: option<dependencies>,
}

let getPackageJsonAsJson = packageJsonPath => {
  try {
    packageJsonPath->Node.Fs.readFileSync(#utf8)->Js.Json.parseExn->Ok
  } catch {
  | _ => Error(`Couldn't read ${packageJsonPath}`)
  }
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
    ~f=(name, version, dependencies, devDependencies, peerDependencies, resolutions) => {
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

let getPackageDependencies = packageJsonPath => {
  packageJsonPath->getPackageJsonAsJson->Belt.Result.flatMap(parsePackageJson)
}

let getDependenciesInfo = packageJsonPaths => {
  packageJsonPaths->Belt.Array.map(getPackageDependencies)
}
