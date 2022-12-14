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
