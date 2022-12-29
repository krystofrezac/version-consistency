open Jest
open Expect

describe("getCorrectLatestDependencyOfGroup", () => {
  test("when no workspace is present", () => {
    let latestDependency = {
      open Dependencies
      {
        dependencyName: "a",
        dependencyVersion: "^1.9.5",
        dependencyType: Dependency,
        packageName: "package",
      }
    }

    [
      latestDependency,
      {
        dependencyName: "b",
        dependencyVersion: "^0.1.0",
        dependencyType: DevDependency,
        packageName: "package",
      },
      {
        dependencyName: "b",
        dependencyVersion: "^1.9.2",
        dependencyType: Resolution,
        packageName: "package",
      },
    ]
    ->Versions.getCorrectLatestDependencyOfGroup
    ->expect
    ->toEqual(latestDependency->Some)
  })

  test("when workspace is present", () => {
    let latestDependency = {
      open Dependencies
      {
        dependencyName: "a",
        dependencyVersion: "^1.1.0",
        dependencyType: WorkspacePackage,
        packageName: "package",
      }
    }

    [
      latestDependency,
      {
        dependencyName: "b",
        dependencyVersion: "^0.1.0",
        dependencyType: Dependency,
        packageName: "package",
      },
      {
        dependencyName: "b",
        dependencyVersion: "^1.9.5",
        dependencyType: Dependency,
        packageName: "package",
      },
    ]
    ->Versions.getCorrectLatestDependencyOfGroup
    ->expect
    ->toEqual(latestDependency->Some)
  })
})

test("getDependencyGroupsWithConsistencyCheck", () => {
  {
    open Dependencies
    [
      [
        {
          dependencyName: "b",
          dependencyVersion: "^0.1.0",
          dependencyType: DevDependency,
          packageName: "package",
        },
        {
          dependencyName: "a",
          dependencyVersion: "^1.9.5",
          dependencyType: Dependency,
          packageName: "package",
        },
        {
          dependencyName: "b",
          dependencyVersion: "^1.9.2",
          dependencyType: Resolution,
          packageName: "package",
        },
      ],
    ]
  }
  ->Versions.getDependencyGroupsWithConsistencyCheck
  ->expect
  ->toEqual({
    let expected: array<array<Versions.dependencyWithConsistency>> = [
      [
        {
          dependencyName: "b",
          dependencyVersion: "^0.1.0",
          dependencyType: DevDependency,
          packageName: "package",
          isConsistent: false,
        },
        {
          dependencyName: "a",
          dependencyVersion: "^1.9.5",
          dependencyType: Dependency,
          packageName: "package",
          isConsistent: true,
        },
        {
          dependencyName: "b",
          dependencyVersion: "^1.9.2",
          dependencyType: Resolution,
          packageName: "package",
          isConsistent: true,
        },
      ],
    ]
    expected
  })
})
