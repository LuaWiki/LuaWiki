local test = require("test/testutils")
local output = require("output")

test.start()

-- Here, you know, it's "easy" to write other tests.

test.testcase(
        "Bold",
        function()
            local actual = output.fromWikiFileWithoutTitle("wiki/Bolditalic")
            local expect = "<p>hello ' blah </p><p>hello <i> blah</i> </p><p>hello <b> blah</b> </p><p>hello l'<i>amour</i> l<b>ouest</b> blah </p><p>hello mon'<i>amour</i> blah </p><p>hello '<i>amour</i> <b>blah </b>blah </p><p>hello '<b>amour</b> now <i>italics unbalanced, but that's ok</i> </p><p>hello '<b>amour</b> now, <b>bold unbalanced, but that's ok</b> </p><p>hello '<b>amour</b> now ''<b>bold and italics unbalanced, so invoke this special case</b> </p><p>hello ''<b> blah</b> </p><p>hello '''''''<b> blah</b> </p><p>hello <b>bold </b>''''<b> blah</b> </p><p>hello ''<b> blah</b> blah </p><p>hello <b><i> blah</i> blah</b> </p>"
            return test.assert_equals(actual, expect)
        end
)
test.finish()

--print(output.fromWikiFile("Bolditalic", "wiki/Bolditalic"))
