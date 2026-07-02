# FOLIO Tasks

## To run a task:
In the `tasks/` directory there are rake tasks to run specific data and/or settings loads into FOLIO. You can search them by keyword using `rake -AT keyword`, e.g.:

```bash
rake -AT inventory
rake inventory:load_alt_title_types  # load alternative title types into folio
rake inventory:load_item_note_types  # load item note types into folio
rake inventory:load_material_types   # load material types into folio
```

Run a rake task using `rake`:

```bash
rake namespace:name_of_task
```

## Configuration
In the config/settings folder, create or modify `dev.yml` and `orig.yml` to specify the connection information
 for a target instance of folio (`dev` or `uat`) and optionally a source instance of folio (`orig`) and set the login info for the FOLIO Superuser.

E.g.
```bash
okapi:
  url: https://example.com
  tenant_id: sul
  user_agent: folio-tasks
  login_params:
    username: user
    password: pass

tsv: spec/fixtures/tsv

hostname: https://example.com
namespace: folio-test
configurations:
  - CHECKOUT

json: spec/fixtures/json
```

## Server Configuration
After deploying `folio-tasks` to the server, pull in the configuration from vault:
- Log in using OIDC:
```
vault login -method oidc
```
- Get the settings from vault:
```
vault kv get -field=content puppet/application/folio-tasks/config/settings/prod > config/settings/prod.yml
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
STAGE=local ruby bin/folio_get.rb '/users'
```
or
```
STAGE=local rake load_user_settings
```

### Get JSON data from a running FOLIO instance
Use the `STAGE=orig rake pull_all_json_data` to pull json from a folio instance defined in a `config/settings/orig.json` yaml file. This will include the following json files and save them to both the `json/` and `spec/fixtures/json/` folder:
- users/fee_fine_owners.json
- users/fee_fine_manual_charges.json
- users/payments.json
- users/permission_sets.json
- users/refunds.json
- users/waivers.json
- data-import-profiles/actionProfiles.json
- data-import-profiles/jobProfiles.json
- data-import-profiles/mappingProfiles.json
- circulation/circulation-rules.json
- circulation/fixed-due-date-schedules.json
- circulation/loan-policies.json
- circulation/overdue-fines-policies.json
- circulation/lost-item-fees-policies.json
- circulation/patron-notice-policies.json
- circulation/patron-notice-templates.json
- circulation/cancellation-reasons.json
- circulation/request-policies.json
- courses/terms.json
- courses/departments.json
- configurations/<MODULE>.json (not saved to `spec/fixtures/json`)

### Run tests to verify the validity of the downloaded files
- `rspec spec/users`
- `rspec spec/data_import`
- `rspec spec/circulation`
- `rspec spec/courses`

It may be necessary to replace the `spec/fixtures/support` files with new ones from the https://github.com/folio-org/ repo if the json schema tests fail.


## Generic CRUD operations
In the `bin/` directory there are generic scripts to do a GET, POST, PUT, DELETE.

For example, for a GET:

```bash
ruby bin/folio_get.rb '/users'
{"users"=>
  [ ... ],
 "totalRecords"=>2,
 "resultInfo"=>{"totalRecords"=>2, "facets"=>[], "diagnostics"=>[]}}
```

For a POST:
```bash
ruby bin/folio_post.rb '/configurations/entries' 'json/configurations/SMTP_SERVER.json'
...
```
