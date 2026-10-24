# Télécommande universelle — étape 1 (architecture + UI)

Code écrit sans SDK Flutter disponible : **pas encore compilé**. Première action : les commandes ci-dessous, puis `flutter analyze` et `flutter test`.

## Installation dans un projet Flutter neuf

```bash
flutter create --org sn.tvremote --platforms android tv_remote
cd tv_remote
# Copier par-dessus le contenu de cette archive (lib/, test/, pubspec.yaml,
# android/app/src/main/AndroidManifest.xml, android/app/src/main/kotlin/...)
flutter pub get
flutter analyze
flutter test
flutter run            # sur un téléphone ou un émulateur
```

Le package Kotlin `sn.tvremote.tv_remote` doit correspondre à `--org sn.tvremote` + nom `tv_remote`.
Si vous changez l'un des deux, déplacez `MainActivity.kt` et changez sa ligne `package`.

## Modification à faire dans `android/app/build.gradle.kts` (généré)

Ne remplacez pas tout le fichier : son contenu exact (DSL Kotlin, options du compilateur) dépend
de votre version de Flutter. Modifiez seulement `compileSdk` et le bloc `defaultConfig` :

```kotlin
android {
    // ...
    compileSdk = maxOf(flutter.compileSdkVersion, 36)

    defaultConfig {
        applicationId = "sn.tvremote.tv_remote"
        // Minimum imposé par Flutter stable depuis la 3.35 : Android 7.0
        minSdk = 24
        // Android 16 : exigence Google Play actuelle. Passer à 37 (Android 17)
        // imposera la permission d'exécution ACCESS_LOCAL_NETWORK (gérée à l'étape 3).
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // ...
}
```

La configuration de signature release sera ajoutée à l'étape 5.

## Ce que fait l'étape 1

- Écran de télécommande complet, branché sur un **contrôleur de démonstration** (chaque appui est journalisé dans la console).
- Lecture des capacités du téléphone à l'exécution (émetteur IR, fréquences, Wi-Fi, version d'Android) : menu ⋮ → *Capacités du téléphone*.
- Thème clair / sombre / système, retour haptique désactivable, saisie de texte.
