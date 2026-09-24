allprojects {
    repositories {
        google()
        mavenCentral()
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

// Plugins that omit compileOptions (open_file_android) default to Java 8.
// Set this on the Android extension so the SDK boot classpath stays intact.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android") ?: return@withId
        val compileOptions = androidExt.javaClass.getMethod("getCompileOptions").invoke(androidExt)
        val objectType = java.lang.Object::class.java
        compileOptions.javaClass
            .getMethod("setSourceCompatibility", objectType)
            .invoke(compileOptions, JavaVersion.VERSION_17)
        compileOptions.javaClass
            .getMethod("setTargetCompatibility", objectType)
            .invoke(compileOptions, JavaVersion.VERSION_17)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
