load("@rules_java//java:defs.bzl", "java_library", "java_test")

java_library(
    name = "LowLevelOne",
    srcs = glob(["src/main/java/com/acme/arc/dep/test/*.java"]),
    visibility = ["//visibility:public"],
)

java_test(
    name = "LowLevelOneTest",
    srcs = glob(["src/test/java/com/acme/arc/dep/test/*.java"]),
    test_class = "com.acme.arc.dep.test.LowOneMainTest",
    size = "small",
    use_testrunner = False,
    main_class = "org.junit.platform.console.ConsoleLauncher",
    args = [
        "execute",
        "--select-class",
        "com.acme.arc.dep.test.LowOneMainTest",
    ],
    deps = [
        ":LowLevelOne",
        "@junit_platform_console_standalone//jar",
    ],
)
