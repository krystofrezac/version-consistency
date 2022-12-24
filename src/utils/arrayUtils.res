let getLast = arr => {
  arr->Belt.Array.get(Belt.Array.length(arr) - 1)
}

let groupBy = (sortedItems, comparator) => {
  let (groupedItems, tail) = sortedItems->Belt.Array.reduce(([], []), (
    (acc, newGroup),
    current,
  ) => {
    let maybeLastItem = newGroup->getLast
    switch maybeLastItem {
    | Some(lastItem) => switch comparator(lastItem, current) {
      | true => (acc, Belt.Array.concat(newGroup, [current]))
      | false => (Belt.Array.concat(acc, [newGroup]), [current])
      }

    | None => (acc, [current])
    }
  })

  Belt.Array.concat(groupedItems, [tail])
}
