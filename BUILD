# Root BUILD file for the monorepo

load("@gazelle//:def.bzl", "DEFAULT_LANGUAGES", "gazelle", "gazelle_binary")

# gazelle:java_extension enabled
# gazelle:java_maven_install_file rules_jvm_external++maven+maven_install.json
# gazelle:resolve java org.junit.jupiter.api @maven//:org_junit_jupiter_junit_jupiter_api

gazelle(
    name = "gazelle",
    gazelle = ":gazelle_bin",
)

gazelle_binary(
    name = "gazelle_bin",
    languages = DEFAULT_LANGUAGES + [
        "@contrib_rules_jvm//java/gazelle",
    ],
)
