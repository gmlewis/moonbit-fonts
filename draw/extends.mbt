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
pub extend Anchor with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Anchor with Eq::{not_equal}

///|
pub extend Anchor with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Anchor with Show::{output}

///|
pub extend Anchor with Debug::{to_repr}

///|
pub extend Anchor with ToJson::{to_json}

///|
pub extend Anchor with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Color with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Color with Eq::{not_equal}

///|
pub extend Color with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Color with Show::{output}

///|
pub extend Color with Debug::{to_repr}

///|
pub extend Color with ToJson::{to_json}

///|
pub extend Color with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend CompoundPath with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend CompoundPath with Show::{output}

///|
pub extend CompoundPath with Debug::{to_repr}

///|
pub extend CompoundPath with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend DrawError with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend DrawError with Eq::{not_equal}

///|
pub extend DrawError with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend DrawError with Show::{output}

///|
pub extend DrawError with Debug::{to_repr}

///|
pub extend Fill with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Fill with Eq::{not_equal}

///|
pub extend Fill with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Fill with Show::{output}

///|
pub extend Fill with Debug::{to_repr}

///|
pub extend Fill with ToJson::{to_json}

///|
pub extend Fill with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Fill with Clonable::{clone}

///|
pub extend Graphic with Add::{add}

///|
pub extend Graphic with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Graphic with Show::{output}

///|
pub extend Graphic with Debug::{to_repr}

///|
pub extend Graphic with ToJson::{to_json}

///|
pub extend Graphic with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Group with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Group with Show::{output}

///|
pub extend Group with Debug::{to_repr}

///|
pub extend Group with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Path with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Path with Show::{output}

///|
pub extend Path with Debug::{to_repr}

///|
pub extend Path with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Stroke with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend Stroke with Eq::{not_equal}

///|
pub extend Stroke with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend Stroke with Show::{output}

///|
pub extend Stroke with Debug::{to_repr}

///|
pub extend Stroke with ToJson::{to_json}

///|
pub extend Stroke with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Stroke with Clonable::{clone}

///|
pub extend StrokeAlignment with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend StrokeAlignment with Eq::{not_equal}

///|
pub extend StrokeAlignment with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend StrokeAlignment with Show::{output}

///|
pub extend StrokeAlignment with Debug::{to_repr}

///|
pub extend StrokeAlignment with ToJson::{to_json}

///|
pub extend StrokeAlignment with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend StrokeCap with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend StrokeCap with Eq::{not_equal}

///|
pub extend StrokeCap with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend StrokeCap with Show::{output}

///|
pub extend StrokeCap with Debug::{to_repr}

///|
pub extend StrokeCap with ToJson::{to_json}

///|
pub extend StrokeCap with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend StrokeJoin with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend StrokeJoin with Eq::{not_equal}

///|
pub extend StrokeJoin with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend StrokeJoin with Show::{output}

///|
pub extend StrokeJoin with Debug::{to_repr}

///|
pub extend StrokeJoin with ToJson::{to_json}

///|
pub extend StrokeJoin with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend TextAlign with Eq::{equal}

///|
#deprecated("Use `!=` instead", skip_current_package=true)
#doc(hidden)
pub extend TextAlign with Eq::{not_equal}

///|
pub extend TextAlign with Show::{to_string}

///|
#deprecated("Use `Show::output` via the trait or `to_string` instead", skip_current_package=true)
#doc(hidden)
pub extend TextAlign with Show::{output}

///|
pub extend TextAlign with Debug::{to_repr}
