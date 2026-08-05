# Copilot instructions for beyond-fitness-standalone

This file helps future Copilot sessions understand how to build, test, and reason about this repository.

---

## 1) Build, test, and lint commands (project-specific)

Notes: this repo is primarily composed of Visual Studio (.sln/.csproj) projects targeting the .NET Framework (old csproj format). There is no single top-level npm/web-tooling configuration.

- Build full solution (Windows, Visual Studio/MSBuild):
  - Open the appropriate solution in Visual Studio (recommended): beyond-fitness.sln, WebHome.sln, BF-Console.sln, front-end.sln
  - Or use MSBuild from Developer Command Prompt:
    msbuild "<path-to-sln>" /p:Configuration=Release

- Build a single project:
  - msbuild "path\to\project.csproj" /t:Build /p:Configuration=Debug

- Tests:
  - No standard test framework (NUnit/xUnit/MSTest) detected in top-level solutions. There is a TestConsole project used for manual/utility runs.
  - If a test project using the SDK style appears later, run:
    dotnet test "path\to\testproject.csproj"
  - For compiled test assemblies, use vstest.console.exe <path-to-test-assembly.dll> (Visual Studio test runner).

- Linting/Formatting:
  - No global linter configured. Some plugin folders contain package.json for editor plugins; run npm install and npm run lint there only if a lint script exists.

---

## 2) High-level architecture (big picture)

- Monorepo of multiple related .NET web and console apps:
  - WebHome solution: hosts WebHome (web app) plus shared libraries (CommonLib.Core, CommonLib.Logger, CommonLib.Utility, CommonLib.PlugInAdapter), ExternalPdfWrapper, WebBase, WebDev, TestConsole. Contains SQL artifacts (BF.sql, UserProfileStatistic.sql) as "Solution Items".
  - beyond-fitness solution: contains the core beyond-fitness web app and BF-Console console project.
  - front-end solution: holds front-end static/asset packaging project(s).
- Shared libraries: CommonLib.* projects store reusable code across web & console apps.
- Static/third-party web assets and editor plugins (CKEditor/TinyMCE/Popper) live under beyond-fitness and BF-Console plugin folders.
- Database schema and seed/migration scripts are at the repository root (BF.sql, schema.sql).

---

## 3) Key conventions and patterns (repo-specific)

- Project naming: shared code uses the CommonLib.* prefix. Keep cross-cutting utilities here.
- Solution mapping: prefer opening the solution that contains the target project (WebHome.sln for web runtime; beyond-fitness.sln for core site and console tools).
- Build target: projects use Any CPU and provide Debug/Release configurations. Use the same configuration between dependent projects to avoid runtime mismatches.
- Manual test runner: TestConsole is present and frequently used for ad-hoc testing; look there before adding small ad-hoc tests to other locations.
- Database-first artifacts: BF.sql and schema.sql are canonical for DB setup in this repo — keep them updated when schema changes.
- Minimal JS/Node tooling: there are isolated package.json files for CKEditor/TinyMCE plugins inside plugin subfolders only. Do not assume a repo-wide npm workspace.

---

## 4) Files and places Copilot should check first

- Solutions: beyond-fitness.sln, WebHome.sln, BF-Console.sln, front-end.sln
- Shared libs: CommonLib/, CommonLib.Core/, CommonLib.Utility/
- SQL and schema: BF.sql, schema.sql
- Plugins and static assets: beyond-fitness\js\plugin, BF-Console\ConsoleHome\plugins
- Test helpers: TestConsole/

---

## 5) CI / Workflows

- .github/workflows/ exists but no workflow ymls were found. If CI is added, prefer workflow names that indicate the solution they build (e.g., webhome-build.yml, beyond-fitness-build.yml).

---

## 6) How to improve this guide

- Add commands/examples for any newly introduced test frameworks (NUnit/xUnit) or Node-based front-end build steps.
- Document developer environment expectations (Visual Studio version, required SDKs, SQL Server/connection strings) in README or CONTRIBUTING so Copilot can reference them.

---

If you want, next steps Copilot can take:
- Add a lightweight GitHub Actions workflow that builds the primary solutions.
- Add an annotated CONTRIBUTING.md with local dev setup steps (Visual Studio edition, DB connection, seeds).

