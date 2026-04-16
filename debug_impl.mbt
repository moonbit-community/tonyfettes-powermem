///|
/// `Debug` impls for types that carry `Json?` fields, which block
/// `derive(Debug)` because `Json` itself does not implement `Debug`.
/// Each impl delegates to the type's `ToJson` rendering.

///|
impl @debug.Debug for MemoryData with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}

///|
impl @debug.Debug for SearchResult with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}

///|
impl @debug.Debug for UserProfile with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}

///|
impl @debug.Debug for SystemStatus with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}

///|
impl @debug.Debug for QualityMetrics with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}

///|
impl @debug.Debug for MemoryInput with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}

///|
impl @debug.Debug for MemoryUpdateInput with to_repr(self) {
  @debug.Repr::literal(self.to_json().stringify())
}
