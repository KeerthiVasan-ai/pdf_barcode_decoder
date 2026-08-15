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

    afterEvaluate {
        val extension = project.extensions.findByName("android")
        if (extension != null) {
            try {
                val setCompileSdk = extension.javaClass.getMethod("setCompileSdk", Int::class.javaObjectType)
                setCompileSdk.invoke(extension, 36)
            } catch (e: Exception) {
                try {
                    val compileSdkVersion = extension.javaClass.getMethod("compileSdkVersion", Int::class.java)
                    compileSdkVersion.invoke(extension, 36)
                } catch (e2: Exception) {
                    // Ignore
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
