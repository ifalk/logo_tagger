[#ftl]
[#list sentence as unit]
[#if unit.token.precedingRawOutput??]
${unit.token.precedingRawOutput}
[/#if]
${unit.token.index?c}	${unit.token.textForCoNLL}	${unit.tag.code}	${(unit.token.lineNumber)?c}	${(unit.token.columnNumber)?c}	
[/#list]

