module Ranges = {
  @module external intersects: (string, string) => bool = "semver/ranges/intersects"
  @module external minVersion: string => string = "semver/ranges/min-version"
}
module Functions = {
  @module external compare: (string, string) => int = "semver/functions/compare"
  @module external rcompare: (string, string) => int = "semver/functions/rcompare"
}
