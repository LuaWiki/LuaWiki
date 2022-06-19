define("ace/theme/behave",["require","exports","module","ace/lib/dom"], function(require, exports, module) {
"use strict";

exports.isDark = false;
exports.cssClass = "ace-behave";
exports.cssText = `.ace-behave .ace_gutter {
  background: #2C333D;
  color: rgb(127,134,143)
}

.ace-behave .ace_print-margin {
  width: 1px;
  background: #e8e8e8
}

.ace-behave {
  background-color: #2C333D;
  color: #D2D8E1
}

.ace-behave .ace_cursor {
  color: #909FB5
}

.ace-behave .ace_marker-layer .ace_selection {
  background: #434D5B
}

.ace-behave.ace_multiselect .ace_selection.ace_start {
  box-shadow: 0 0 3px 0px #2C333D;
  border-radius: 2px
}

.ace-behave .ace_marker-layer .ace_step {
  background: rgb(198, 219, 174)
}

.ace-behave .ace_marker-layer .ace_bracket {
  margin: -1px 0 0 -1px;
  border: 1px solid #434D5B
}

.ace-behave .ace_marker-layer .ace_active-line {
  background: #232932
}

.ace-behave .ace_gutter-active-line {
  background-color: #232932
}

.ace-behave .ace_marker-layer .ace_selected-word {
  border: 1px solid #434D5B
}

.ace-behave .ace_fold {
  background-color: #61d29d;
  border-color: #D2D8E1
}

.ace-behave .ace_keyword {
  color: #5ab8e5
}

.ace-behave .ace_keyword.ace_operator {
  color: #7dcbc4
}

.ace-behave .ace_keyword.ace_other.ace_unit {
  color: #c9a9f9
}

.ace-behave .ace_constant.ace_language {
  color: #c9a9f9
}

.ace-behave .ace_constant.ace_numeric {
  color: #c9a9f9
}

.ace-behave .ace_constant.ace_character {
  color: #7dcbc4
}

.ace-behave .ace_constant.ace_other {
  color: #c9a9f9
}

.ace-behave .ace_support.ace_function {
  color: #61d29d
}

.ace-behave .ace_support.ace_constant {
  color: #c9a9f9
}

.ace-behave .ace_support.ace_class {
  color: #f0d879
}

.ace-behave .ace_support.ace_type {
  color: #f0d879
}

.ace-behave .ace_storage {
  color: #5ab8e5
}

.ace-behave .ace_storage.ace_type {
  color: #5ab8e5
}

.ace-behave .ace_invalid {
  color: #D2D8E1;
  background-color: #EF4D44
}

.ace-behave .ace_invalid.ace_deprecated {
  color: #CED2CF;
  background-color: #B798BF
}

.ace-behave .ace_string {
  color: #ec9076
}

.ace-behave .ace_string.ace_regexp {
  color: #cab8a3
}

.ace-behave .ace_comment {
  color: #808691
}

.ace-behave .ace_variable {
  color: #cab8a3
}

.ace-behave .ace_variable.ace_parameter {
  color: #cab8a3
}

.ace-behave .ace_meta.ace_tag {
  color: #5ab8e5
}

.ace-behave .ace_entity.ace_other.ace_attribute-name {
  color: #7dcbc4
}

.ace-behave .ace_entity.ace_name.ace_function {
  color: #61d29d
}

.ace-behave .ace_entity.ace_name.ace_tag {
  color: #5ab8e5
}

.ace-behave .ace_markup.ace_heading {
  color: #f0d879
}`;
exports.$id = "ace/theme/behave";

var dom = require("../lib/dom");
dom.importCssString(exports.cssText, exports.cssClass, false);
});                (function() {
                    window.require(["ace/theme/behave"], function(m) {
                        if (typeof module == "object" && typeof exports == "object" && module) {
                            module.exports = m;
                        }
                    });
                })();