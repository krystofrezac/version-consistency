open Jest
open Expect

describe("yarn", () => {
  describe("getPackagesGlobPatterns", () => {
    test(
      "returns correct flat glob patterns",
      () => {
        let globPatterns = ["app", "packages/*"]

        let test = () => {
          open Interfaces.Yarn

          getRootPackageJsonAsJson(".")
          ->Belt.Option.getExn
          ->getPackagesGlobPatterns
          ->expect
          ->toEqual(Some(globPatterns))
        }

        test->MockFs.wrapTest(
          Js.Dict.fromArray([
            (
              "package.json",
              TestUtils.Yarn.createPackageJson(~name="root", ~workspaces=globPatterns, ()),
            ),
          ]),
        )
      },
    )
    test(
      "returns correct nested glob patterns",
      () => {
        let globPatterns = ["app", "packages/*"]

        let test = () => {
          open Interfaces.Yarn

          getRootPackageJsonAsJson(".")
          ->Belt.Option.getExn
          ->getPackagesGlobPatterns
          ->expect
          ->toEqual(Some(globPatterns))
        }

        test->MockFs.wrapTest(
          Js.Dict.fromArray([
            (
              "package.json",
              TestUtils.Yarn.createPackageJson(
                ~name="root",
                ~workspaces=globPatterns,
                ~nestedWorkspaces=true,
                (),
              ),
            ),
          ]),
        )
      },
    )
  })

  describe("getPackagePathsFromGlobPatterns", () => {
    let getResult = () => {
      let test = () => {
        open Interfaces.Yarn

        getPackagePathsFromGlobPatterns(["mobile-app", "packages/*"])
      }

      test->MockFs.wrapTest(
        Js.Dict.fromArray({
          open TestUtils.Yarn
          [
            ("package.json", createPackageJson(~name="root", ())),
            ("mobile-app/package.json", createPackageJson(~name="mobile-app", ())),
            ("packages/utils/package.json", createPackageJson(~name="utils", ())),
            (
              "packages/components/package.json",
              createPackageJson(~name="components", ()),
            ),
          ]
        }),
      )
    }

    test(
      "has correct length",
      () => {
        getResult()->Belt.Array.length->expect->toBe(3)
      },
    )

    testAll(
      "contains expected path",
      list{
        "mobile-app/package.json",
        "packages/utils/package.json",
        "packages/components/package.json",
      },
      expectedPath => {
        getResult()
        ->Belt.Array.getBy(
          result => {
            open Node
            result === Path.join([Process.cwd(), expectedPath])
          },
        )
        ->Belt.Option.isSome
        ->expect
        ->toBe(true)
      },
    )
  })

  describe("getPathsToPackageJsons", () => {
    testAll(
      "contains expected path",
      list{"mobile-app/package.json", "packages/utils/package.json"},
      expected => {
        let test = () => {
          open Interfaces.Yarn

          getPathsToPackageJsons(Node.Process.cwd())
          ->Belt.Option.getExn
          ->Belt.Array.getBy(
            result => {
              open Node
              result == Path.join([Process.cwd(), expected])
            },
          )
          ->Belt.Option.isSome
          ->expect
          ->toBe(true)
        }

        test->MockFs.wrapTest(
          Js.Dict.fromArray({
            open TestUtils.Yarn
            [
              (
                "package.json",
                createPackageJson(~name="root", ~workspaces=["mobile-app", "packages/*"], ()),
              ),
              ("mobile-app/package.json", createPackageJson(~name="mobile-app", ())),
              ("packages/utils/package.json", createPackageJson(~name="utils", ())),
            ]
          }),
        )
      },
    )
  })
})
