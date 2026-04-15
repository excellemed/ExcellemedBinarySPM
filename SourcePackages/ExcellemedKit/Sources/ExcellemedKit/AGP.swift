public func agp(data: [(Int, Double)], start: Int, step: Int) -> AGP {
  let dateList = Algorithm.RustVec<Int>()
  let valueList = Algorithm.RustVec<Double>()
  for it in data {
    dateList.push(value: it.0)
    valueList.push(value: it.1)
  }
  return Algorithm.agp(dateList, valueList, start, step)
}
