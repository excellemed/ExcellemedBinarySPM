#if canImport(UIKit)

import UIKit

class CalendarFlowLayout: UICollectionViewFlowLayout {
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    super.layoutAttributesForElements(in: rect)?.map {
      // swiftlint:disable force_cast
      let attrs = $0.copy() as! UICollectionViewLayoutAttributes
      // swiftlint:enable force_cast
      layout(attrs)
      return attrs
    }
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    if let attr = super.layoutAttributesForItem(at: indexPath) {
      // swiftlint:disable force_cast
      let attribute = attr.copy() as! UICollectionViewLayoutAttributes
      // swiftlint:enable force_cast
      layout(attribute)
      return attribute
    }
    return .none
  }

  private func layout(_ attrs: UICollectionViewLayoutAttributes) {
    if attrs.representedElementKind != nil { return }
    if let v = collectionView {
      var xOffset = CGFloat(attrs.indexPath.item % 7) * itemSize.width
      let yOffset = CGFloat(attrs.indexPath.item / 7) * itemSize.height
      let offset = CGFloat(attrs.indexPath.section)
      xOffset += offset * v.frame.width
      attrs.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
    }
  }
}

#endif
