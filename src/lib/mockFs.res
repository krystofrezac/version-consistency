@module external mock: Js.Dict.t<string> => unit = "mock-fs"
@module("mock-fs") external restore: unit => unit = "restore"

let wrapTest = (test, mockOptions) => {
  mock(mockOptions)
  let result = test()
  restore()
  result
}
