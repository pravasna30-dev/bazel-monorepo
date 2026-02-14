load("@contrib_rules_jvm//java:defs.bzl", "java_test_suite")
load("@rules_java//java:defs.bzl", "java_binary", "java_library")

# gazelle:java_module_granularity module

java_library(
    name = "low-level-1",
    srcs = ["src/main/java/com/acme/arc/dep/test/LowOneMain.java"],
    visibility = ["//visibility:public"],
)

java_binary(
    name = "LowOneMain",
    main_class = "com.acme.arc.dep.test.LowOneMain",
    visibility = ["//visibility:public"],
    runtime_deps = [":low-level-1"],
)

java_test_suite(
    name = "low-level-1-tests",
    srcs = ["src/test/java/com/acme/arc/dep/test/LowOneMainTest.java"],
    runner = "junit5",
    runtime_deps = [
        "@maven//:org_junit_jupiter_junit_jupiter_engine",
        "@maven//:org_junit_platform_junit_platform_launcher",
        "@maven//:org_junit_platform_junit_platform_reporting",
    ],
    deps = [
        ":low-level-1",  # keep
        "@maven//:org_junit_jupiter_junit_jupiter_api",
    ],
)
