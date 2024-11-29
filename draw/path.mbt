/// Path represents an open or closed path that can be stroked as an outline
/// or filled. A 'clear' path is sub-path of a CompoundPath that defines
/// regions of the filled path where no fill is added, for example in the
/// center of the letter 'O'.
pub(all) struct Path {
  mut anchors : Array[Anchor]
  mut closed : Bool
  mut clear : Bool
  mut stroke : Stroke?
  mut fill : Fill?
}
