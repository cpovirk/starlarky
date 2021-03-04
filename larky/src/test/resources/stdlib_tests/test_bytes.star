"""Unit tests for re.star"""

load("@stdlib/asserts", "asserts")
load("@stdlib/unittest", "unittest")
load("@stdlib/builtins", "builtins")


def _test_escape():
    asserts.assert_that(re.escape(r"1243*&[]_dsfAd")).is_equal_to(
        r"1243\*\&\[\]_dsfAd")


# search
def _test_search():
    m = re.search(r"a+", "caaab")
    asserts.assert_that(m.group(0)).is_equal_to("aaa")
    asserts.assert_that(m.group()).is_equal_to("aaa")


# Tests of 'bytes' (immutable byte strings).

# bytes(string) -- UTF-k to UTF-8 transcoding with U+FFFD replacement
hello = builtins.bytes("hello, 世界")
goodbye = builtins.bytes("goodbye")
empty = builtins.bytes("")
nonprinting = builtins.bytes("\t\n\x7F\u200D")  # TAB, NEWLINE, DEL, ZERO_WIDTH_JOINER
asserts.assert_that(builtins.bytes("hello, 世界"[:-1])).is_equal_to(b"hello, 世��")

# bytes(iterable of int) -- construct from numeric byte values
asserts.assert_that(bytes([65, 66, 67])).is_equal_to(b"ABC")
asserts.assert_that(bytes((65, 66, 67))).is_equal_to(b"ABC")
asserts.assert_that(bytes([0xf0, 0x9f, 0x98, 0xbf])).is_equal_to(b"😿")
assert.fails(lambda: bytes([300]),
             "at index 0, 300 out of range .want value in unsigned 8-bit range")
assert.fails(lambda: bytes([b"a"]),
             "at index 0, got bytes, want int")
assert.fails(lambda: bytes(1), "want string, bytes, or iterable of ints")

# literals
asserts.assert_that(b"hello, 世界").is_equal_to(hello)
asserts.assert_that(b"goodbye").is_equal_to(goodbye)
asserts.assert_that(b"").is_equal_to(empty)
asserts.assert_that(b"\t\n\x7F\u200D").is_equal_to(nonprinting)
asserts.assert_that("abc").is_not_equal_to(b"abc")
asserts.assert_that(b"\012\xff\u0400\U0001F63F").is_equal_to(b"\n\xffЀ😿") # see scanner tests for more
asserts.assert_that(rb"\r\n\t").is_equal_to(b"\\r\\n\\t") # raw

# type
asserts.assert_that(type(hello)).is_equal_to("bytes")

# len
asserts.assert_that(len(hello)).is_equal_to(13)
asserts.assert_that(len(goodbye)).is_equal_to(7)
asserts.assert_that(len(empty)).is_equal_to(0)
asserts.assert_that(len(b"A")).is_equal_to(1)
asserts.assert_that(len(b"Ѐ")).is_equal_to(2)
asserts.assert_that(len(b"世")).is_equal_to(3)
asserts.assert_that(len(b"😿")).is_equal_to(4)

# truth
assert.true(hello)
assert.true(goodbye)
assert.true(not empty)

# str(bytes) does UTF-8 to UTF-k transcoding.
# TODO(adonovan): specify.
asserts.assert_that(str(hello)).is_equal_to("hello, 世界")
asserts.assert_that(str(hello[:-1])).is_equal_to("hello, 世��")  # incomplete UTF-8 encoding => U+FFFD
asserts.assert_that(str(goodbye)).is_equal_to("goodbye")
asserts.assert_that(str(empty)).is_equal_to("")
asserts.assert_that(str(nonprinting)).is_equal_to("\t\n\x7f\u200d")
asserts.assert_that(str(b"\xED\xB0\x80")).is_equal_to("���") # UTF-8 encoding of unpaired surrogate => U+FFFD x 3

# repr
asserts.assert_that(repr(hello)).is_equal_to(r'b"hello, 世界"')
asserts.assert_that(repr(hello[:-1])).is_equal_to(r'b"hello, 世\xe7\x95"')  # (incomplete UTF-8 encoding )
asserts.assert_that(repr(goodbye)).is_equal_to('b"goodbye"')
asserts.assert_that(repr(empty)).is_equal_to('b""')
asserts.assert_that(repr(nonprinting)).is_equal_to('b"\\t\\n\\x7f\\u200d"')

# equality
asserts.assert_that(hello).is_equal_to(hello)
asserts.assert_that(hello).is_not_equal_to(goodbye)
asserts.assert_that(b"goodbye").is_equal_to(goodbye)

# ordered comparison
assert.lt(b"abc", b"abd")
assert.lt(b"abc", b"abcd")
assert.lt(b"\x7f", b"\x80") # bytes compare as uint8, not int8

# bytes are dict-hashable
dict = {hello: 1, goodbye: 2}
dict[b"goodbye"] = 3
asserts.assert_that(len(dict)).is_equal_to(2)
asserts.assert_that(dict[goodbye]).is_equal_to(3)

# hash(bytes) is 32-bit FNV-1a.
asserts.assert_that(hash(b"")).is_equal_to(0x811c9dc5)
asserts.assert_that(hash(b"a")).is_equal_to(0xe40c292c)
asserts.assert_that(hash(b"ab")).is_equal_to(0x4d2505ca)
asserts.assert_that(hash(b"abc")).is_equal_to(0x1a47e90b)

# indexing
asserts.assert_that(goodbye[0]).is_equal_to(b"g")
asserts.assert_that(goodbye[-1]).is_equal_to(b"e")
assert.fails(lambda: goodbye[100], "out of range")

# slicing
asserts.assert_that(goodbye[:4]).is_equal_to(b"good")
asserts.assert_that(goodbye[4:]).is_equal_to(b"bye")
asserts.assert_that(goodbye[::2]).is_equal_to(b"gobe")
asserts.assert_that(goodbye[3:4]).is_equal_to(b"d")  # special case: len=1
asserts.assert_that(goodbye[4:4]).is_equal_to(b"")  # special case: len=0

# bytes in bytes
asserts.assert_that(b"bc" in b"abcd").is_equal_to(True)
asserts.assert_that(b"bc" in b"dcab").is_equal_to(False)
assert.fails(lambda: "bc" in b"dcab", "requires bytes or int as left operand, not string")

# int in bytes
asserts.assert_that(97 in b"abc").is_equal_to(True)  # 97='a'
asserts.assert_that(100 in b"abc").is_equal_to(False) # 100='d'
assert.fails(lambda: 256 in b"abc", "int in bytes: 256 out of range")
assert.fails(lambda: -1 in b"abc", "int in bytes: -1 out of range")

# ord   TODO(adonovan): specify
asserts.assert_that(ord(b"a")).is_equal_to(97)
assert.fails(lambda: ord(b"ab"), "ord: bytes has length 2, want 1")
assert.fails(lambda: ord(b""), "ord: bytes has length 0, want 1")

# repeat (bytes * int)
asserts.assert_that(goodbye * 3).is_equal_to(b"goodbyegoodbyegoodbye")
asserts.assert_that(3 * goodbye).is_equal_to(b"goodbyegoodbyegoodbye")

# elems() returns an iterable value over 1-byte substrings.
asserts.assert_that(type(hello.elems())).is_equal_to("bytes.elems")
asserts.assert_that(str(hello.elems())).is_equal_to("b\"hello, 世界\".elems()")
asserts.assert_that(list(hello.elems()), [104, 101, 108, 108, 111, 44, 32, 228, 184, 150, 231, 149).is_equal_to(140])
asserts.assert_that(bytes([104, 101, 108, 108, 111, 44, 32, 228, 184, 150, 231, 149, 140])).is_equal_to(hello)
asserts.assert_that(list(goodbye.elems()), [103, 111, 111, 100, 98, 121).is_equal_to(101])
asserts.assert_that(list(empty.elems())).is_equal_to([])
asserts.assert_that(bytes(hello.elems())).is_equal_to(hello) # bytes(iterable) is dual to bytes.elems()

# x[i] = ...
def f():
    b"abc"[1] = b"B"

assert.fails(f, "bytes.*does not support.*assignment")

# TODO(adonovan): the specification is not finalized in many areas:
# - chr, ord functions
# - encoding/decoding bytes to string.
# - methods: find, index, split, etc.
#
# Summary of string operations (put this in spec).
#
# string to number:
# - bytes[i]  returns numeric value of ith byte.
# - ord(string)  returns numeric value of sole code point in string.
# - ord(string[i])  is not a useful operation: fails on non-ASCII; see below.
#   Q. Perhaps ord should return the first (not sole) code point? Then it becomes a UTF-8 decoder.
#      Perhaps ord(string, index=int) should apply the index and relax the len=1 check.
# - string.codepoint()  iterates over 1-codepoint substrings.
# - string.codepoint_ords()  iterates over numeric values of code points in string.
# - string.elems()  iterates over 1-element (UTF-k code) substrings.
# - string.elem_ords()  iterates over numeric UTF-k code values.
# - string.elem_ords()[i]  returns numeric value of ith element (UTF-k code).
# - string.elems()[i]  returns substring of a single element (UTF-k code).
# - int(string)  parses string as decimal (or other) numeric literal.
#
# number to string:
# - chr(int) returns string, UTF-k encoding of Unicode code point (like Python).
#   Redundant with '%c' % int (which Python2 calls 'unichr'.)
# - bytes(chr(int)) returns byte string containing UTF-8 encoding of one code point.
# - bytes([int]) returns 1-byte string (with regrettable list allocation).
# - str(int) - format number as decimal.



def _suite():
    _suite = unittest.TestSuite()
    _suite.addTest(unittest.FunctionTestCase(_test_escape))
    _suite.addTest(unittest.FunctionTestCase(_test_search))
    _suite.addTest(unittest.FunctionTestCase(_test_match))
    _suite.addTest(unittest.FunctionTestCase(_test_groups))
    _suite.addTest(unittest.FunctionTestCase(_test_sub))
    _suite.addTest(unittest.FunctionTestCase(_test_subn))
    # currently not supported!
    # _suite.addTest(unittest.FunctionTestCase(_test_zero_length_matches))
    _suite.addTest(unittest.FunctionTestCase(_test_split))
    _suite.addTest(unittest.FunctionTestCase(_test_findall))
    _suite.addTest(unittest.FunctionTestCase(_test_finditer))
    return _suite


_runner = unittest.TextTestRunner()
_runner.run(_suite())
