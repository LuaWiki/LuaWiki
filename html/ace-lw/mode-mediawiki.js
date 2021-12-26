define("ace/mode/mediawiki_highlight_rules",["require","exports","module","ace/lib/oop","ace/mode/text_highlight_rules"], function(require, exports, module) {
    "use strict";
    
    var oop = require("../lib/oop");
    var TextHighlightRules = require("./text_highlight_rules").TextHighlightRules;
    
    var MediaWikiHighlightRules = function() {
        this.$rules = {
            start: [ 'comment', 'template', 'heading', 'pre', 'argument', 'link',
                'tag', 'escape', 'operator' ],
            comment: [{
                token: "punctuation.definition.comment.html",
                regex: /<!--/,
                push: [{
                    token: "punctuation.definition.comment.html",
                    regex: /-->/,
                    next: "pop"
                }, {
                    defaultToken: "comment.block.html"
                }]
            }],
            template: [{
                token: [
                    "storage.type.function",
                    "meta.template",
                    "entity.name.function",
                    "meta.template"
                ],
                regex: /({{)(\s*)([^|}]+)(\s*)/,
                push: [{
                    token: "storage.type.function",
                    regex: /}}/,
                    next: "pop"
                }, {
                    token: [
                        "storage",
                        "meta.structure.dictionary",
                        "support.type.property-name",
                        "meta.structure.dictionary",
                        "punctuation.separator.dictionary.key-value",
                        "meta.structure.dictionary"
                    ],
                    regex: /(\|)(\s*)([\w_-]*)(\s*)(=)(\s*)/,
                    push: [ 'template', 'link_internal', {
                        token: "meta.structure.dictionary",
                        regex: /(?=}}|[|])/,
                        next: "pop"
                    }, {
                        defaultToken: "meta.structure.dictionary"
                    } ]
                }, {
                    token: ["storage", "meta.template.value"],
                    regex: /(\|)(.*?)/,
                    push: [{
                        token: [],
                        regex: /(?=}}|[|])/,
                        next: "pop"
                    }, 'start', {
                        defaultToken: "meta.template.value"
                    }]
                }, {
                    defaultToken: "meta.template"
                }]
            }],
            heading: [{
                token: [
                    'punctuation.definition.heading',
                    'entity.name.section',
                    'punctuation.definition.heading'
                ],
                regex: /(={1,6})(.+?)(\1)(?!=)/
            }],
            pre: [{
                token: 'markup.raw',
                regex: '^ .*$'
            }],
            argument: [{
                stateName: 'openArg',
                token: [
                    'variable.parameter', 'text', 'variable.other',
                    'text', 'keyword.operator'
                ],
                regex: /({{{)(\s*)(\w+)(\s*)((?:\|)?)/,
                push: [{
                    token: 'variable.parameter',
                    regex: /}}}/,
                    next: 'pop'
                }, 'start']
            }],
            link_internal: [{
                token: [
                    'punctuation.definition.tag.begin',
                    'meta.tag.link.internal',
                    'entity.name.tag',
                    'meta.tag.link.internal',
                    'string.other.link.title',
                    'meta.tag.link.internal',
                    'punctuation.definition.tag'
                ],
                regex: /(\[\[)(\s*)((?:Category|Wikipedia)?)(:?)([^\]\]\|]+)(\s*)((?:\|)*)/,
                push: [{
                    token: 'punctuation.definition.tag.end',
                    regex: /\]\]/,
                    next: 'pop'
                }, 'start', {
                    defaultToken: 'meta.tag.link.internal'
                }]
            }],
            link: [ 'link_internal', {
                token: [
                    'punctuation.definition.tag.begin',
                    'meta.tag.link.external',
                    'meta.tag.link.external',
                    'string.unquoted',
                    'punctuation.definition.tag.end'
                ],
                regex: /(\[)(.*?)([\s]+)(.*?)(\])/
            }],
            tag_whitespace : [
                {token : "text.tag-whitespace.xml", regex : "\\s+"}
            ],
            attributes: [{
                include : "tag_whitespace"
            }, {
                token : "entity.other.attribute-name.xml",
                regex : "[-_a-zA-Z0-9:.]+"
            }, {
                token : "keyword.operator.attribute-equals.xml",
                regex : "=",
                push : [{
                    include: "tag_whitespace"
                }, {
                    token : "string.unquoted.attribute-value.html",
                    regex : "[^<>='\"`\\s]+",
                    next : "pop"
                }, {
                    token : "empty",
                    regex : "",
                    next : "pop"
                }]
            }],
            tag: [{
                token: function(start, tag) {
                    return ["meta.tag.punctuation." + (start == "<" ? "" : "end-") + "tag-open.xml",
                        "meta.tag.tag-name.xml"];
                },
                regex : '(</?)([-_a-zA-Z0-9:.]+)',
                next: 'tag_stuff'
            }],
            tag_stuff: [
                {include : 'attributes'},
                {token : 'meta.tag.punctuation.tag-close.xml', regex : '/?>', next : 'start'}
            ],
            escape: [{
                token : "constant.language.escape.reference.xml",
                regex : "(?:&#[0-9]+;)|(?:&#x[0-9a-fA-F]+;)|(?:&[a-zA-Z0-9_:\\.-]+;)"
            }],
            operator: [{
                token: 'keyword.operator',
                regex: /[-=|#~!']+/
            }]
        };
    
        this.normalizeRules();
    };
    
    MediaWikiHighlightRules.metaData = {
        name: "MediaWiki",
        scopeName: "text.html.mediawiki",
        fileTypes: ["mediawiki", "wiki"]
    };
    
    
    oop.inherits(MediaWikiHighlightRules, TextHighlightRules);
    
    exports.MediaWikiHighlightRules = MediaWikiHighlightRules;
    });
    
    define("ace/mode/mediawiki",["require","exports","module","ace/lib/oop","ace/mode/text","ace/mode/mediawiki_highlight_rules"], function(require, exports, module) {
    "use strict";
    
    var oop = require("../lib/oop");
    var TextMode = require("./text").Mode;
    var MediaWikiHighlightRules = require("./mediawiki_highlight_rules").MediaWikiHighlightRules;
    
    var Mode = function() {
        this.HighlightRules = MediaWikiHighlightRules;
    };
    oop.inherits(Mode, TextMode);
    
    (function() {
        this.type = "text";
        this.blockComment = {start: "<!--", end: "-->"};
        this.$id = "ace/mode/mediawiki";
    }).call(Mode.prototype);
    
    exports.Mode = Mode;
    });                (function() {
                        window.require(["ace/mode/mediawiki"], function(m) {
                            if (typeof module == "object" && typeof exports == "object" && module) {
                                module.exports = m;
                            }
                        });
                    })();
                