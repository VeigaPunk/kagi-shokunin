import importlib.util, sys
spec = importlib.util.spec_from_file_location("rc", sys.argv[1])
rc = importlib.util.module_from_spec(spec); spec.loader.exec_module(rc)
cases = [
 ("prerelease-names-core", "Entry titled v2.2.0, tag link /releases/tag/v2.2.0; the same feed carries sdk/v0.26.0 and v2.2.0-rc1", "2.2.0"),
 ("module-tag-names-core", "Newest stable OpenBao is v2.7.1 ... module releases (api/v2.7.1, sdk/v2.7.1) carry commit-message titles", "2.7.1"),
 ("parent-of-four-part", "tag 154.0.8037.97 (commit b510e9d7)", "154.0.8037"),
 ("prefixed-by-alnum", "observed Node26.12.0 differs from descriptive recorded24.21.0", "24.21.0"),
]
for name, anchor, ver in cases:
    print("is_named", name, "=>", rc.version_is_named(anchor, ver))
print("int_max_str_digits", sys.get_int_max_str_digits())
print("numeric 3.15.01 =>", rc.numeric_version("3.15.01"))
print("string-equal 3.15.01 vs 3.15.1 =>", rc.norm_version("3.15.01") == rc.norm_version("3.15.1"))
big = "3.15." + "1"*4301
try:
    print("numeric oversize =>", rc.numeric_version(big))
except BaseException as e:
    print("numeric oversize raised", type(e).__name__, str(e)[:90])
