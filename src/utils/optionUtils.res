let resultToOption = result => {
  switch result {
  | Ok(value) => Some(value)
  | Error(_) => None
  }
}