load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")

java_library(
    name = "TopLevelOneLib",
    srcs = glob(["src/main/java/com/acme/arc/dep/test/*.java"]),
    deps = [
        "//low-level-1:LowLevelOne",
    ],
)

java_binary(
    name = "TopLevelOne",
    main_class = "com.acme.arc.dep.test.Main",
    runtime_deps = [":TopLevelOneLib"],
)

java_test(
    name = "TopLevelOneTest",
    srcs = glob(["src/test/java/com/acme/arc/dep/test/*.java"]),
    test_class = "com.acme.arc.dep.test.MainTest",
    size = "small",
    use_testrunner = False,
    main_class = "org.junit.platform.console.ConsoleLauncher",
    args = [
        "execute",
        "--select-class",
        "com.acme.arc.dep.test.MainTest",
    ],
    deps = [
        ":TopLevelOneLib",
        "//low-level-1:LowLevelOne",
        "@junit_platform_console_standalone//jar",
    ],
)
