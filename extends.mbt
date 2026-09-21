///|
// Explicit trait-method promotion declarations.
//
// MoonBit no longer promotes a trait's methods to direct methods on a type
// implicitly: every promoted method needs an explicit `extend` declaration.
// The primary method of each trait is promoted here plainly. The defaulted
// derivative that the `!=` operator or string interpolation already covers
// (`Eq::not_equal`, `Show::output`) is promoted as well - moonc otherwise
// warns about its implicit promotion - but deprecated and hidden, since there
// is no reason to call it directly.

///|
pub extend Font with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Font with Eq::{not_equal}

///|
pub extend Font with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Font with Show::{output}

///|
pub extend Font with Debug::{to_repr}

///|
pub extend Font with ToJson::{to_json}

///|
pub extend Font with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend FontError with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend FontError with Eq::{not_equal}

///|
pub extend FontError with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend FontError with Show::{output}

///|
pub extend Glyph with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Glyph with Eq::{not_equal}

///|
pub extend Glyph with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Glyph with Show::{output}

///|
pub extend Glyph with Debug::{to_repr}

///|
pub extend Glyph with ToJson::{to_json}

///|
pub extend Glyph with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Params with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Params with Eq::{not_equal}

///|
pub extend Params with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Params with Show::{output}

///|
pub extend Params with Debug::{to_repr}

///|
pub extend ParamPair with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend ParamPair with Eq::{not_equal}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend ParamPair with Show::{output}

///|
pub extend ParamPair with Debug::{to_repr}

///|
pub extend PathCmd with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend PathCmd with Eq::{not_equal}

///|
pub extend PathCmd with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend PathCmd with Show::{output}

///|
pub extend PathCmd with Debug::{to_repr}

///|
pub extend Cmd with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Cmd with Eq::{not_equal}

///|
pub extend Cmd with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Cmd with Show::{output}

///|
pub extend Cmd with Debug::{to_repr}

///|
pub extend SVGPath with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend SVGPath with Eq::{not_equal}

///|
pub extend SVGPath with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend SVGPath with Show::{output}

///|
pub extend AbsoluteCmd with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend AbsoluteCmd with Eq::{not_equal}

///|
pub extend AbsoluteCmd with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend AbsoluteCmd with Show::{output}

///|
pub extend AbsoluteCmd with Debug::{to_repr}

///|
pub extend GerberLP with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend GerberLP with Eq::{not_equal}

///|
pub extend GerberLP with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend GerberLP with Show::{output}

///|
pub extend GerberLP with Debug::{to_repr}
