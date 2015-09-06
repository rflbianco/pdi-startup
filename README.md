# PDI Startup

**PDI Startup** is a set of custom startup scripts to the multiple applications from [Pentaho Data Integration (PDI)][pdi]: spoon, kitchen, pan etc. The goal is emulate a **Project Repository** using environment variables.

The Pentaho Data Integration, a.k.a. KETTLE, is a widely adopted open source tool for ETL (Extraction, Transformation and Load) development. It provides an engine to process data through configurable plugins. The data transformations are created by metadata definitions about arranging and configuring those plugins. The metadata can be stored both in filesystem (XML) and relational database.

The primary storage option is a standalone XML file for each data transformation definition, either a Job (.kjb) or Transformation (.ktr), in PDI vocab. However, ETL project consists of many data transformation definitions. For the notion of projects, PDI provides 2 types of repositories built-in:

- **Database repositories:** All data transformation definition is stored in a relational database. Each project is one schema (Oracle, Postgres etc') or database (SQLite, MySQL etc).
- **In file (XML) repositories:** All data transformation definition is stored in a single XML file.

The first is not Source Control Management friendly at all. The second can be used over an VCS (SVN, Git etc), but is not really useful as all modifications are in a single file.

This project is a way to workaround these limitations. It adds some custom environment variables about the project in execution time. These variables can be used inside PDI  definition files. Moreover, it is possible to cross point files and definitions relatively to project root. Therefore, a project notion can be accomplished using the basic persistence system: a XML file per data transformation definition.

The following PDI applications are supported:
- **Spoon:** The GUI to design and run Transformations and Jobs.
- **Kitchen:** The CLI application to run Jobs.
- **Pan:** The CLI application to run Transformations.

## Install

The installation is simple as possible. After installing PDI in your system, just download the specific folder for your PDI version inside PDI installation folder.

You can download the complete project in zip file, and extract only the folder of your version inside PDI installation path. The following command can be ran inside your installation folder.

```shell
wget https://github.com/instituto-stela/pdi-startup/archive/master.zip -O /tmp/pdi-startup.zip \
&& unzip /tmp/pdi-startup.zip -d /tmp/pdi-startup \
&& cp -R /tmp/pdi-startup/pdi-startup-master/[PDI_VERSION]/* ./
```

For version 4.2.x of PDI, it would be.
```shell
wget https://github.com/instituto-stela/pdi-startup/archive/master.zip -O /tmp/pdi-startup.zip \
&& unzip /tmp/pdi-startup.zip -d /tmp/pdi-startup \
&& cp -R /tmp/pdi-startup/pdi-startup-master/4.2.x/* ./
```

This will add some `.sh` and `.bat` scripts to your PDI installation folder. All scripts are prefixed with `ps-`: `ps-spoon(.sh/.bat)` and `ps-kitchen(.sh/.bat)`, for example.

None of the original files from PDI are overwritten. So the original behavior of the application is intact. Thus, for complete removal, it is only need to remove the prefixed files.

```shell
rm ps-*.
```

## Usage

In short, these scripts work as extended wrappers around PDI applications. They add some parameter parsing at application startup, passing to PDI applications some custom environment variables. These variables then can be used inside Jobs and Transformations as project environment variables.

This is not a perfect approach, especially because it relies in some strict constraints. However, is a option that works pretty fine for those who want to use standalone files (.kjb and .ktr) over a SCM (Source Control Management).

The custom scripts adds the following environment variables:
- $PROJECT_HOME:
the root path of ETL project.
- $PROJECT_REPOSITORY:
the root path of ETL data transformation definition files. Usually `$PROJECT_HOME/repository`.

They also setup the `$KETTLE_SHARED_OBJECTS` PDI's built-in variable. The `$KETTLE_SHARED_OBJECTS` defines a custom path to `shared.xml` file. This XML file is meant to holds shared resources definitions, database connections for instance. Moreover, it is possible to keep multiple `shared.xml` in your project. For example, to keep settings for multiple environments (development, testing, production etc).

### Project

The project simply consists in a flat folder that must follow a few constraints:
* `/repository` folder: it must hold all `.ktr` and `.kjb` files.
* `/shared-[ENV].xml` files: the multiple shared objects definition files must be in the root folder and follow this notation name.

There are some other folders that are suggested, but not mandatory. The following structure is proposed:

- `/bin` : helper shell scripts to run jobs and transformations
- `/data` : data files (.csv, .txt, .xls) to be used in ETL process
- `/log` : log files of executions
- `/repository` : all data transformation definitions
- `/shared-dev.xml` : data connection definitions for development environment.
- `/shared-prod.xml` : data connection definitions for production environment.
- `/shared-test.xml` : data connection definitions for testing environment.

### Start PDI application

To open a project, the given application must be started passing the project parameters. The accepted parameters are:
- `--project [PROJECT_ROOT_PATH]`: The absolute path to the root path of the [project folder](#project-folder). **REQUIRED**.
- `--env [ENVIRONMENT]`: The selected environment for setting `SHARED_OBJECTS`. If not provided, it defaults to `NONE`.

Usage example:
```shell
$PDI_FOLDER/ps-spoon.sh --project /home/user/awesome-etl-project --env dev

# or

cd $PDI_FOLDER
./ps-spoon.sh --project /home/user/awesome-etl-project --env dev
```

This will start `spoon` with the following environment variables:
```
$PROJECT_HOM = /home/user/awesome-etl-project
$PROJECT_REPOSITORY = /home/user/awesome-etl-project/repository
$KETTLE_SHARED_OBJECTS = /home/user/awesome-etl-project/shared-dev.xml
```

If `$KETTLE_SHARED_OBJECTS` file does not exists, it is be created when any file is saved.

[pdi]: http://community.pentaho.com/projects/data-integration/
