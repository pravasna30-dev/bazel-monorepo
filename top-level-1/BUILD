load("@contrib_rules_jvm//java:defs.bzl", "java_test_suite")
load("@rules_java//java:defs.bzl", "java_binary", "java_library")

# gazelle:java_module_granularity module

java_library(
    name = "top-level-1",
    srcs = ["src/main/java/com/acme/arc/dep/test/Main.java"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//low-level-1",  # keep
    ],
)

java_binary(
    name = "Main",
    main_class = "com.acme.arc.dep.test.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":top-level-1"],
)

java_test_suite(
    name = "top-level-1-tests",
    srcs = ["src/test/java/com/acme/arc/dep/test/MainTest.java"],
    runner = "junit5",
    runtime_deps = [
        "@maven//:org_junit_jupiter_junit_jupiter_engine",
        "@maven//:org_junit_platform_junit_platform_launcher",
        "@maven//:org_junit_platform_junit_platform_reporting",
    ],
    deps = [
        ":top-level-1",  # keep
        "//low-level-1",  # keep
        "@maven//:org_junit_jupiter_junit_jupiter_api",
    ],
)
