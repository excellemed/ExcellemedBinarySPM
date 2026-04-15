public nonisolated struct Area: Codable, Hashable, Sendable {
  public var id: String
  public var name: String
  public var header: String
  public var children: [Area]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Area, rhs: Area) -> Bool {
    lhs.id == rhs.id
  }
}

extension Area {
  public static func convert(areas: [Area]) -> [AreaSectionModel] {
    let groupedAreas = Dictionary(grouping: areas, by: { $0.header })
    return groupedAreas.map { header, areas in
      AreaSectionModel(header: header, items: areas)
    }.sorted { $0.header < $1.header }
  }
}

public nonisolated struct AreaSectionModel: Sendable {
  public var header: String
  public var items: [Area]
}

nonisolated extension AreaSectionModel: SectionModelType {
  public typealias Item = Area

  public init(original: AreaSectionModel, items: [Item]) {
    self = original
    self.items = items
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(header)
  }

  public static func == (lhs: AreaSectionModel, rhs: AreaSectionModel) -> Bool {
    lhs.header == rhs.header
  }
}
