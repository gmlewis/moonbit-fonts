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
pub extend AffineMatrix with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend AffineMatrix with Eq::{not_equal}

///|
pub extend AffineMatrix with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend AffineMatrix with Show::{output}

///|
pub extend AffineMatrix with Debug::{to_repr}

///|
pub extend Alignment with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Alignment with Eq::{not_equal}

///|
pub extend Alignment with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Alignment with Show::{output}

///|
pub extend Alignment with Debug::{to_repr}

///|
pub extend BoundingBox with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend BoundingBox with Eq::{not_equal}

///|
pub extend BoundingBox with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend BoundingBox with Show::{output}

///|
pub extend BoundingBox with Debug::{to_repr}

///|
pub extend Transform with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Transform with Eq::{not_equal}

///|
pub extend Transform with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Transform with Show::{output}

///|
pub extend Transform with Debug::{to_repr}

///|
pub extend Vec2 with Mul::{mul}

///|
pub extend Vec2 with Div::{div}

///|
pub extend Vec2 with Neg::{neg}

///|
pub extend Vec2 with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Vec2 with Eq::{not_equal}

///|
pub extend Vec2 with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Vec2 with Show::{output}

///|
pub extend Vec2 with Debug::{to_repr}

///|
pub extend Vec2 with ToJson::{to_json}

///|
pub extend Vec2 with @moonbitlang/core/json.FromJson::{from_json}
