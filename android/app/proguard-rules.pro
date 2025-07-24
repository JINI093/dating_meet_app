# AWS SDK & Amplify Framework
-keep class com.amazonaws.** { *; }
-keep class com.amplifyframework.** { *; }
-keep class com.amazonaws.mobileconnectors.** { *; }
-keep class com.amazonaws.services.cognitoidentityprovider.** { *; }
-keep class com.amazonaws.services.cognitoidentity.** { *; }
-keep class com.amazonaws.services.s3.** { *; }
-keep class com.amazonaws.auth.** { *; }

# Amplify Auth Cognito
-keep class com.amplifyframework.auth.cognito.** { *; }
-keep class com.amplifyframework.auth.** { *; }
-keep class com.amplifyframework.core.** { *; }
-keep class com.amplifyframework.api.** { *; }
-keep class com.amplifyframework.storage.** { *; }

# JWT
-keep class io.jsonwebtoken.** { *; }
-dontwarn io.jsonwebtoken.**

# Jackson JSON processor
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

-keepattributes Signature,InnerClasses,EnclosingMethod,*Annotation*
-dontwarn com.amazonaws.**
-dontwarn com.amplifyframework.**

# OkHttp
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Gson
-keep class com.google.gson.** { *; }
-keepattributes Signature

# 기타
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement 