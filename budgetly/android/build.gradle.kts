allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    plugins.withType(com.android.build.gradle.LibraryPlugin::class.java) {
        extensions.configure(com.android.build.gradle.LibraryExtension::class.java) {
            setCompileSdk(36)
        }
    }
    plugins.withType(com.android.build.gradle.AppPlugin::class.java) {
        extensions.configure(com.android.build.gradle.AppExtension::class.java) {
            setCompileSdk(36)
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
