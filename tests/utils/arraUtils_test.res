open Jest
open Expect

describe("groupBy", () => {
  test("returns correct value", () => {
    ["a", "b", "b", "b", "c", "d", "d", "e"]
    ->ArrayUtils.groupBy((a, b) => a == b)
    ->expect
    ->toEqual([["a"], ["b", "b", "b"], ["c"], ["d", "d"], ["e"]])
  })
})
