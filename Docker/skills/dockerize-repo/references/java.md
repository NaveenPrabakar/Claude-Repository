# Java (Spring Boot / Maven / Gradle)

## Detecting the build tool
- `pom.xml` → Maven
- `build.gradle` / `build.gradle.kts` → Gradle

Check the Java version from `pom.xml` (`<java.version>`) or `build.gradle`
(`sourceCompatibility`) — don't assume a version.

## Template (Maven, generalize for Gradle by swapping the build commands)

```dockerfile
# ---- build stage ----
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN ./mvnw dependency:go-offline
COPY src ./src
RUN ./mvnw package -DskipTests

# ---- runtime stage ----
FROM eclipse-temurin:21-jre-jammy AS runtime
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=build --chown=app:app /app/target/*.jar app.jar
USER app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

For Gradle, replace the build stage commands with:
```dockerfile
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
RUN ./gradlew dependencies --no-daemon
COPY src ./src
RUN ./gradlew bootJar --no-daemon
```
and copy `build/libs/*.jar` instead of `target/*.jar`.

## Pitfalls
- Use the `-jre` image (not `-jdk`) for the runtime stage — no compiler needed to run a jar.
- Copy `pom.xml`/`build.gradle` and run the offline dependency resolution *before*
  copying `src/`, so dependency downloads are cached across source changes.
- If Spring Boot Actuator isn't on the classpath, there's no `/actuator/health` —
  either recommend adding it or use a plain TCP/process healthcheck instead.
- `-DskipTests` is standard for a production image build; don't skip tests in CI, just
  in the Docker build step (tests should already have run in CI before this point).
