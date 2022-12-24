open Jest
open Expect

describe("parsePackageJSON", () => {
  test("parse only name and version", () => {
    TestUtils.Common.createPackageJson(~name="packageName", ~version="1.0.2", ())
    ->Js.Json.parseExn
    ->Dependencies.parsePackageJson
    ->expect
    ->toEqual(
      Ok({
        name: "packageName",
        version: "1.0.2",
        dependencies: None,
        devDependencies: None,
        peerDependencies: None,
        resolutions: None,
      }),
    )
  })

  test("parse with dependencies", () => {
    TestUtils.Common.createPackageJson(
      ~name="packageName",
      ~version="1.0.2",
      ~dependencies=[("a", "4.3.2")],
      (),
    )
    ->Js.Json.parseExn
    ->Dependencies.parsePackageJson
    ->expect
    ->toEqual(
      Ok({
        name: "packageName",
        version: "1.0.2",
        dependencies: Some([("a", "4.3.2")]),
        devDependencies: None,
        peerDependencies: None,
        resolutions: None,
      }),
    )
  })

  test("parse with all fields", () => {
    TestUtils.Common.createPackageJson(
      ~name="packageName",
      ~version="1.0.2",
      ~dependencies=[("a", "4.3.2")],
      ~devDependencies=[("b", "0.2.0")],
      ~peerDependencies=[("c", "1.1.2"), ("d", "2.3.2")],
      ~resolutions=[],
      (),
    )
    ->Js.Json.parseExn
    ->Dependencies.parsePackageJson
    ->expect
    ->toEqual(
      Ok({
        name: "packageName",
        version: "1.0.2",
        dependencies: Some([("a", "4.3.2")]),
        devDependencies: Some([("b", "0.2.0")]),
        peerDependencies: Some([("c", "1.1.2"), ("d", "2.3.2")]),
        resolutions: None,
      }),
    )
  })
})

describe("processPackageJsonDependencies", () => {
  test("returns correctly joined dependencies", () => {
    let parsedPackageJson: Dependencies.packageJson = {
      name: "packageName",
      version: "0.0.1",
      dependencies: [("a", "0.0.0"), ("b", "0.0.0")]->Some,
      devDependencies: [("c", "1.0.0"), ("a", "0.0.0")]->Some,
      peerDependencies: [("b", "2.0.0"), ("c", "0.0.0")]->Some,
      resolutions: [("a", "3.0.0"), ("b", "0.0.0")]->Some,
    }

    Dependencies.processPackageJsonDependencies(parsedPackageJson)
    ->expect
    ->toEqual([
      {
        dependencyName: "packageName",
        dependencyVersion: "0.0.1",
        packageName: "packageName",
        dependencyType: WorkspacePackage,
      },
      {
        dependencyName: "a",
        dependencyVersion: "0.0.0",
        packageName: "packageName",
        dependencyType: Dependency,
      },
      {
        dependencyName: "b",
        dependencyVersion: "0.0.0",
        packageName: "packageName",
        dependencyType: Dependency,
      },
      {
        dependencyName: "c",
        dependencyVersion: "1.0.0",
        packageName: "packageName",
        dependencyType: DevDependency,
      },
      {
        dependencyName: "a",
        dependencyVersion: "0.0.0",
        packageName: "packageName",
        dependencyType: DevDependency,
      },
      {
        dependencyName: "b",
        dependencyVersion: "2.0.0",
        packageName: "packageName",
        dependencyType: PeerDependency,
      },
      {
        dependencyName: "c",
        dependencyVersion: "0.0.0",
        packageName: "packageName",
        dependencyType: PeerDependency,
      },
      {
        dependencyName: "a",
        dependencyVersion: "3.0.0",
        packageName: "packageName",
        dependencyType: Resolution,
      },
      {
        dependencyName: "b",
        dependencyVersion: "0.0.0",
        packageName: "packageName",
        dependencyType: Resolution,
      },
    ])
  })
})

describe("joinPackagesDependencies", () => {
  test("joins correctly when no error", () => {
    let firstDependency: Dependencies.dependency = {
      dependencyName: "a",
      dependencyVersion: "0.0.0",
      packageName: "packageA",
      dependencyType: Dependency,
    }
    let secondDependency: Dependencies.dependency = {
      dependencyName: "a",
      dependencyVersion: "0.0.0",
      packageName: "packageB",
      dependencyType: Dependency,
    }

    [Ok([firstDependency]), Ok([secondDependency])]
    ->Dependencies.joinPackagesDependencies
    ->expect
    ->toEqual(Ok([firstDependency, secondDependency]))
  })

  test("joins correctly when one error", () => {
    let secondDependency: Dependencies.dependency = {
      dependencyName: "a",
      dependencyVersion: "0.0.0",
      packageName: "packageB",
      dependencyType: Dependency,
    }

    [Error("error1"), Ok([secondDependency])]
    ->Dependencies.joinPackagesDependencies
    ->expect
    ->toEqual(Error("error1"))
  })

  test("joins correctly when multiple error", () => {
    let firstDependency: Dependencies.dependency = {
      dependencyName: "a",
      dependencyVersion: "0.0.0",
      packageName: "packageA",
      dependencyType: Dependency,
    }
    let thirdDependency: Dependencies.dependency = {
      dependencyName: "a",
      dependencyVersion: "0.0.0",
      packageName: "packageB",
      dependencyType: Dependency,
    }

    [Ok([firstDependency]), Error("error1"), Ok([thirdDependency]), Error("error2")]
    ->Dependencies.joinPackagesDependencies
    ->expect
    ->toEqual(Error("error1"))
  })
})

describe("groupDependencies", () => {
  test("returns correctly grouped dependencies", () => {
    [
      {
        dependencyName: "a",
        dependencyVersion: "0.0.0",
        packageName: "packageA",
        dependencyType: Dependency,
      },
      {
        dependencyName: "b",
        dependencyVersion: "0.0.0",
        packageName: "packageA",
        dependencyType: Dependency,
      },
      {
        dependencyName: "a",
        dependencyVersion: "0.0.0",
        packageName: "packageB",
        dependencyType: Dependency,
      },
      {
        dependencyName: "c",
        dependencyVersion: "0.0.0",
        packageName: "packageA",
        dependencyType: Dependency,
      },
      {
        dependencyName: "c",
        dependencyVersion: "0.0.0",
        packageName: "packageB",
        dependencyType: Dependency,
      },
    ]
    ->Dependencies.groupDependencies
    ->expect
    ->toEqual([
      [
        {
          dependencyName: "a",
          dependencyVersion: "0.0.0",
          packageName: "packageA",
          dependencyType: Dependency,
        },
        {
          dependencyName: "a",
          dependencyVersion: "0.0.0",
          packageName: "packageB",
          dependencyType: Dependency,
        },
      ],
      [
        {
          dependencyName: "b",
          dependencyVersion: "0.0.0",
          packageName: "packageA",
          dependencyType: Dependency,
        },
      ],
      [
        {
          dependencyName: "c",
          dependencyVersion: "0.0.0",
          packageName: "packageA",
          dependencyType: Dependency,
        },
        {
          dependencyName: "c",
          dependencyVersion: "0.0.0",
          packageName: "packageB",
          dependencyType: Dependency,
        },
      ],
    ])
  })
})
