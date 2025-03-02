// buildscript 블록 내에 Google Services 및 Firebase BoM 설정 추가
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")  // Firebase plugin
        // Firebase BoM (Bill of Materials) 설정
        classpath("com.google.firebase:firebase-crashlytics-gradle:2.9.0") // 필요한 경우 다른 Firebase Gradle plugin 추가
    }
}

// root 프로젝트에서 Firebase 및 기타 종속성 설정
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// clean 작업 정의
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// app/module-level build.gradle.kts 파일
// app 모듈의 build.gradle.kts 파일에서는 Firebase 관련 종속성을 정의합니다.
dependencies {
    // Firebase BoM을 통해 Firebase 라이브러리 관리
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    
    // Firebase 제품 추가
    implementation("com.google.firebase:firebase-analytics")  // Firebase Analytics 예시

    // 필요에 따라 다른 Firebase 서비스도 추가
    // 예: Firebase Authentication, Firestore, 등등
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
}

// app 모듈의 build.gradle.kts에서 Firebase 플러그인 추가
apply plugin: 'com.google.gms.google-services'  // Firebase 서비스 플러그인 적용
