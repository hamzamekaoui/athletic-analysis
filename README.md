# Athletic Analysis

## Setup

The project depends on some packages for it to fully function. Please install these in your Org before proceeding:

* https://github.com/kevinohara80/sfdc-trigger-framework
* https://github.com/jongpie/NebulaLogger

NB: Make sure to install NebulaLogger for all users

## Installation

To install the project, make sure to have an Org ready to use (Dev, Scratch, etc) and run the following in order:

```
sf project deploy start
```

(If you encounter a warning about GlobalValueSet, we need to run it again with `--ignore-conflicts` because of a bug related to CLI/Tooling API)

```
sf project deploy start --ignore-conflicts
```

```
sf org assign permset -n Athletic_Analysis_Tournament_Access
```

```
sf data import tree --files data/Team.json
```

```
sf data import tree --files data/Stadium.json
```

Finally, open the org:

```
sf open org
```

These steps should get you up and running with almost all the functionalities.

To use the Connected App, there are some additional manual steps that need to be done:

* Create a user with Saleforce Integration profile and API Only.
* Assign to this user the `Athletic_Analysis_API_Access` permission set.
* Use this user for the connected app (Connected App -> Manage -> Client Credentials Flow -> Run As).
* Copy the consumer key (client_id) and consumer secret (client_secret) and use them to access the REST resources.

### Note

The batch which generates tournaments is not included within the UI. To try it out, please run:

```
Database.executeBatch(new TournamentGeneratorBatch());
```