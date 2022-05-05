# FOLIO API Client

## To run a task:
In the `tasks/` directory there are rake tasks to run specific data and/or settings loads into FOLIO:

```bash
/folio_api_client> rake -T
rake load_user_groups      # load user groups into folio
rake load_user_settings    # Load all user settings [groups, address_types, waivers, refunds]
...
```

Run a rake task using `rake`:

```bash
/folio_api_client> rake {name_of_task}
```

To load all settings and data for a new instance of FOLIO:

```bash
/folio_api_client> rake load_new_data_and_settings
```

## Configuration
In the config/settings folder, create or modify `dev.yml` to specify the connection information
 for the instance of okapi and set the login info for the FOLIO Superuser.

E.g.
```bash
okapi:
  url: https://okapi-folio-test.dev.sul.stanford.edu
  headers:
    X-Okapi-Tenant: sul
    User-Agent: FolioApiClient
  login_params:
    username: admin
    password: admin_pass

folio:
  url: https://folio-test.dev.sul.stanford.edu

tsv: tsv
```

## Environments
The `tsv` setting is to specify the directory that contains the tsv source files for loading. This is
important for running the tests where the tsv source files are mock files in the `spec/fixtures/tsv` folder.

When you run the scripts or rake tasks, the default environment is `dev`. If you want to use a different
yaml file (to connect to a different instance of folio) you can prepend a different `STAGE` environment
to the command line call. For example, if you have a `local.yml` file in `config/settings`, you can call
a script or rake task like so:

E.g.
```
STAGE=['local'] ruby bin/folio_get.rb '/users'
```
or
```
STAGE=['local'] rake load_user_settings
```

## Generic CRUD operations
In the `bin/` directory there are generic scripts to do a GET, POST, PUT, DELETE.

For example, for a GET:

```bash
/folio_api_client> ruby bin/folio_get.rb '/users'
{"users"=>
  [ ... ],
 "totalRecords"=>2,
 "resultInfo"=>{"totalRecords"=>2, "facets"=>[], "diagnostics"=>[]}}
```

For a POST:
```bash
/folio_api_client> ruby bin/folio_post.rb '/configurations/entries' 'json/email/config_smtp_server_ssl.json'
...
```

## Migrating data
### Getting data from saved files
Copy all the the contents recursively from the external Migration files `json`, `tsv`, and `xml` folders into the corresponding folders locally in this project.

### Getting data from a running FOLIO instance
- Use `bin/folio_get_json.rb` to request the endpoint and get the json data.
- Direct the stdout to the json folder as `some-data.orig.json`
- `cat` the original json data and use `jq` to filter out any keys that are not needed for re-import, e.g.
```
cat json/users/waivers.orig.json | jq '.waivers[] |= del(.metadata) | del(.totalRecords) | del(.resultInfo)' > json/users/waivers.json
```
note: the specific `jq` syntax may be different depending on the original json being filtered.

### Data Import Profiles
- Use `bin/folio_get_json.rb` to request the `data-import-profiles` endpoint and get the different profiles.
- Copy the response to the `json/data-import-profiles` folder in the project.
Example for GET jobProfiles:
```bash
/folio_api_client> ruby bin/folio_get.rb '/data-import-profiles/jobProfiles' > json/data-import-profiles/jobProfiles.json
```
- For actionProfiles, we need to get the relations in order to be able to create profileAssociations:
```bash
/folio_api_client> ruby bin/folio_get.rb '/data-import-profiles/actionProfiles?withRelations=true' > json/data-import-profiles/actionProfiles.json
```
- Run rspec tests to check the json validates
```bash
/folio_api_client> rspec spec/load_import_profiles_task_spec.rb
```
- If any file doesn't pass validation, copy the file to `filename.orig.json`, for example `actionProfiles.orig.json`.
  Edit the file `filename.json` so it passes validation and commit the changes to git to capture the versioning.

### Loading TSV Users
- To get a tsv file with headers of Symphony user records to convert to FOLIO json, run this command on the Symphony server on a collection of user keys:

E.g.
```
cat univ_id.keys | sort -u | seluser -iU -oBEDX.9023.X.9024.X.9015.X.9016.X.9005.X.9007.ge 2>/dev/null | sed '1s;^;BARCODE|UNIV_ID|NAME|ADDR_LINE1|ADDR_LINE2|CITY|STATE|ZIP|EMAIL|PRIV_GRANTED|PRIV_EXPIRED\n;' | pipe2tsv > tsv_users.tsv
```

Then copy the tsv_users.tsv file to the `tsv` folder and run the `load_tsv-users` rake task.

### Loading Permission Sets
- To get all of the permission sets (filter out the regular permissons) use the mutable==true query:
```
ruby bin/folio_get_json.rb '/perms/permissions?length=10000&query=(mutable==true)' } | jq 'del(.totalRecords) | del(.permissions[] .childOf, .permissions[] .grantedTo, .permissions[] .dummy, .permissions[] .deprecated, .permissions[] .metadata)' > json/users/permission_sets.orig.json
```

## Development notes
When a new task is created add the task definition to the `Rakefile` and also to the `load_new_data_and_settings` array
if the task is something that should be loaded into a new instance of FOLIO.
