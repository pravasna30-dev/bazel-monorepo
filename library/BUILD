load("@contrib_rules_jvm//java:defs.bzl", "java_test_suite")
load("@rules_java//java:defs.bzl", "java_library")

# gazelle:java_module_granularity module

java_library(
    name = "library",
    srcs = [
        "src/main/java/com/example/library/User.java",
        "src/main/java/com/example/library/UserService.java",
    ],
    visibility = ["//visibility:public"],
)

java_test_suite(
    name = "library-tests",
    srcs = ["src/test/java/com/example/library/UserServiceTest.java"],
    runner = "junit5",
    runtime_deps = [
        "@maven//:org_junit_jupiter_junit_jupiter_engine",
        "@maven//:org_junit_platform_junit_platform_launcher",
        "@maven//:org_junit_platform_junit_platform_reporting",
    ],
    deps = [
        ":library",  # keep
        "@maven//:org_junit_jupiter_junit_jupiter_api",
    ],
)
