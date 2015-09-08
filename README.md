# PDI Startup

**PDI Startup** is a set of custom startup scripts for [Pentaho Data Integration (PDI)][pdi]'s applications: spoon, kitchen, pan etc. The goal is emulate a **Project Repository** using environment variables.

The Pentaho Data Integration, a.k.a. KETTLE, is a widely adopted open source tool for ETL (Extraction, Transformation and Load) development. It provides an engine to process data through configurable plugins. The data transformations are created by metadata definitions about arranging and configuring those plugins. The metadata can be stored both in filesystem (XML) and relational database.

The primary storage option is a standalone XML file for each data transformation definition, either a Job (.kjb) or Transformation (.ktr), in PDI vocab. However, ETL project consists of many data transformation definitions. For ETL project repository PDI provides 2 types of repositories built-in:

- **Database repositories:** All data transformation definition is stored in a relational database. Each project is one schema (Oracle, Postgres etc) or database (SQLite, MySQL etc).
- **In file (XML) repositories:** All data transformation definition is stored in a single XML file.

The first is not Source Control Management friendly at all. The second can be used over an VCS (SVN, Git etc), but is not really useful as all modifications are in a single file.

This project is a way to workaround these limitations. It adds some custom environment variables about the project in execution time. These variables can be used inside PDI  definition files. Moreover, it is possible to cross point files and definitions relatively to project root. Therefore, a project notion can be accomplished using the basic standalone XML file persistence.

The following PDI applications are supported:
- **Spoon:** The GUI to design and run Transformations and Jobs.
- **Kitchen:** The CLI application to run Jobs.
- **Pan:** The CLI application to run Transformations.

## Install

The installation is simple as possible:

1. Install vanilla PDI from [Source Forge][pdi-sf].
2. Download the specific folder for your PDI version from this repository inside PDI's installation.

For ease of use there is a `install.sh` script. You could use the following code to install the latest supported version in branch `master` into you current folder.

```shell
curl -sL https://github.com/instituto-stela/pdi-startup/raw/master/install.sh | sh
```

The installation script supports the following params:
- `--branch BRANCH_NAME`: Allows selecting which branch of git repoository to install from. Default: `master`
- `--version PDI_VERSION`: Which PDI version / series must be installed. Default: latest supported version.
- `--installation PATH`: PDI installation path. Default: `./`

For version PDI 4.2.1 installed into `/opt/pdi/4.2.1`, it could be.
```shell
curl -sL https://github.com/instituto-stela/pdi-startup/raw/master/install.sh | \
    sh -s -- --version 4.2.x --installation /opt/pdi/4.2.1
```

This will add some `.sh` and `.bat` scripts to your PDI installation folder. All scripts are prefixed with `ps-`: `ps-spoon(.sh/.bat)` and `ps-kitchen(.sh/.bat)`, for example.

None of the original files from PDI are overwritten. So the original behavior of the application is intact. Thus, for complete removal, it is only need to remove the prefixed files.

```shell
rm [PDI_PATH]/ps-*
```

For the same example above, of PDI 4.2.1:
```shell
rm /opt/pdi/4.2.1/ps-*
```

## Usage

In short, these scripts work as extended wrappers around PDI applications. They add some parameter parsing at application startup, passing to PDI applications some custom environment variables. These variables then can be used inside Jobs and Transformations as project environment variables.

This is not a perfect approach, especially because it relies in some strict constraints. However, is a option that works pretty fine for those who want to use standalone files (.kjb and .ktr) over a SCM (Source Control Management).

The custom scripts adds the following environment variables:
- `$PROJECT_HOME`:
the root path of ETL project.
- `$PROJECT_REPOSITORY`:
the root path of ETL data transformation definition files. Usually `$PROJECT_HOME/repository`.

They also setup the `$KETTLE_SHARED_OBJECTS` PDI's built-in variable. The `$KETTLE_SHARED_OBJECTS` defines a custom path to `shared.xml` file. This XML file is meant to holds shared resources definitions, database connections for instance. Moreover, it is possible to keep multiple `shared.xml` in your project. For example, to keep settings for multiple environments (development, testing, production etc).

### Project folder

The project simply consists in a flat folder that must follow a few constraints:
- `/repository` folder: it must hold all `.ktr` and `.kjb` files.
- `/repository/shared-[ENV].xml` files: the multiple shared objects definition files must be in the repository folder and follow this notation name.

There are some other folders that are suggested, but not mandatory. The following structure is proposed:

- `/bin` : helper shell scripts to run jobs and transformations
- `/data` : data files (.csv, .txt, .xls) to be used in ETL process
- `/log` : log files of executions
- `/repository` : all data transformation definitions
- `/repository/shared-dev.xml` : data connection definitions for development environment.
- `/repository/shared-prod.xml` : data connection definitions for production environment.
- `/repository/shared-test.xml` : data connection definitions for testing environment.

### Executing application

To open a project, the given application (`spoon`, `kitchen`, `pan`) must be started passing the project parameters. The accepted ones are:
- `--project [PROJECT_ROOT_PATH]`: The absolute path to the root path of the [project folder](#project-folder). **REQUIRED**.
- `--env [ENVIRONMENT]`: The selected environment for setting `SHARED_OBJECTS`. If not provided, it defaults to `shared.xml`.

Usage example:
```shell
$PDI_FOLDER/ps-spoon.sh --project /home/user/awesome-etl-project --env dev

# or

cd $PDI_FOLDER
./ps-spoon.sh --project /home/user/awesome-etl-project --env dev
```

This will start `spoon` with the following environment variables:
```
$PROJECT_HOME = /home/user/awesome-etl-project
$PROJECT_REPOSITORY = /home/user/awesome-etl-project/repository
$KETTLE_SHARED_OBJECTS = /home/user/awesome-etl-project/repository/shared-dev.xml
```

If `$KETTLE_SHARED_OBJECTS` file does not exists, it is be created when any file is saved.

## Versioning

The project follows the [Semantic Versioning][semantic-versioning] spec. The versions are increased based on usage compatibility. For instance, usage compatibility refers to which arguments are accepted and which environment variables are exported to PDI. Any new argument or environment variable supported is a backward compatible change. However, any removed or renamed ones are not backward compatible changes. Therefore, `MAJOR` version is increased (`MINOR` while under 0.MINOR.PATCH series).

To keep track of stable MAJOR versions, branches prefixed with `release-` must be maintained for each MAJOR version. The `master` branch is the stable for current MAJOR version. The `develop` branch is the *in development* code of current MAJOR version.

The PDI supported versions are folders inside the project root folder. New supported versions must be a backward compatible change. Thus, it must support all args and environment variables supported by other versions in same branch (major version).

When a non-backward compatible change is done, PDI versions must be migrated or removed from the new release branch.

[pdi]: http://community.pentaho.com/projects/data-integration/
[pdi-sf]: http://sourceforge.net/projects/pentaho/files/Data%20Integration/
[semantic-versioning]: http://semver.org
