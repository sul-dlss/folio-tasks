# FOLIO API Client

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
  url: https://okapi-folio-test.dev.sul.stanford.edu
  headers:
    X-Okapi-Tenant: sul
    User-Agent: FolioApiClient
  login_params:
    username: admin
    password: admin_pass

tsv: tsv
tsv_orders: tsv/acquisitions/orders
json: json
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
- Upload the config as part of the capistrano deployment:
```
cap prod deploy deploy:config
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

## Migrating data
### Get TSV and XML data from saved files
Copy all the the contents recursively from the external Migration files `tsv`, and `xml` folders into the corresponding folders locally in this project.

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

### Loading TSV Users
- To get a tsv file with headers of Symphony user records to convert to FOLIO json, run this command on the Symphony server on a collection of user keys:

E.g.
```
cat univ_id.keys | sort -u | seluser -iU -oBEDX.9023.X.9024.X.9015.X.9016.X.9005.X.9007.ge 2>/dev/null | sed '1s;^;BARCODE|UNIV_ID|NAME|ADDR_LINE1|ADDR_LINE2|CITY|STATE|ZIP|EMAIL|PRIV_GRANTED|PRIV_EXPIRED\n;' | pipe2tsv > tsv_users.tsv
```

Then copy the tsv_users.tsv file to the `tsv` folder and run the `load_tsv-users` rake task.

### Loading Permission Sets
- To get all of the permission sets (filter out the regular permissions) use the mutable==true query:
```
ruby bin/folio_get_json.rb '/perms/permissions?length=10000&query=(mutable==true)' } | jq 'del(.totalRecords) | del(.permissions[] .childOf, .permissions[] .grantedTo, .permissions[] .dummy, .permissions[] .deprecated, .permissions[] .metadata)' > json/users/permission_sets.orig.json
```
- To sort the permission sets pulled from an orig version (because there are nested permission dependencies):
```
cat json/users/permission_sets.json | jq '[.["permissions"][] | {permissionName: .permissionName, displayName: .displayName, id: .id, tags: .tags, subPermissions: .subPermissions, mutable: .mutable, visible: .visible}] | sort_by(.displayName)' | sed '1s;^;{"permissions": ;' | sed '$s;$;};' > json/users/permission_sets_sorted.json

mv json/users/permission_sets_sorted.json json/users/permission_sets.json
```

### Manually adding permissions for a user
Get the user's id by doing:
  ```
  result=$(ruby bin/folio_cql_json.rb 'users' 'username==edge_conn' | jq -r '.["users"][0].id')
  ```
  ...and then search for the user permissions id:
  ```
  ID=$(ruby bin/folio_cql_json.rb 'perms/users' "userId==${result}" | jq -r '.["permissionUsers"][0].id')
  ```
  then do a folio POST with json containing one or more permissions, e.g.:
  ```
  ruby bin/folio_post.rb "perms/users/${ID}/permissions" json/users/one_permission.json
  ```
  with
  ```
  {
    "permissionName": "someperms.get"
  }
  ```
  or
  ```
  ruby bin/folio_post_array.rb "perms/users/${ID}/permissions" json/users/array_of_permissions.json
  ```

### Loading Orders
The `prepare_orders` and `load_orders_and_tags` rake tasks should be run from the Symphony server since the tasks need tsv, yaml, and json files that are generated there.
1. Run `/s/SUL/Bin/folio_symphony_extract/acquisitions/orders/run_reports.ksh` to get current order data for migration from Symphony.
1. Copy the `order_type_map.tsv` and `sym_hldg_code_location_map.tsv` files from the [FOLIO Ops shared drive](https://drive.google.com/drive/folders/1-FWsDUcc3DRa3sw6jzh4Puvbn-LRcQ-4?usp=sharing) to the `Settings.tsv_orders` directory.
1. Delete the yaml and json files in the `Settings.yaml.*` and `Settings.json_orders.*` directories, using the tasks `orders:delete_*_order_yaml` and `orders:delete_*_order_json`.
1. Process the Symphony order tsv data and transform to FOLIO order json by running `STAGE=prod rake prepare_orders`. Use the appropriate `STAGE` for whichever environment the orders will be loaded to so the UUIDs are created for the correct environment.
1. Load orders to FOLIO using `STAGE=prod rake load_orders_and_tags`. This is a long-running task, so it is best to run it in a `screen` session on the Symphony server.
1. After inventory is loaded, we need to link the po lines to inventory by using the `STAGE=prod rake orders:link_po_lines_to_inventory[sul]` and `STAGE=prod rake orders:link_po_lines_to_inventory[law]`.

#### Using screen session
From `/s/SUL/Bin/folio-tasks/current` start a screen session with `screen -S order-load`. In the screen session, run `rake -T orders` to see the available tasks related to orders. Run the load_orders task with pool size as argument, e.g. `{ date; STAGE=prod rake load_orders[1]; date; } > ~/load_orders.log 2>&1`. To detach from screen: `ctrl + a, d`. To re-attach to screen, `screen -r ${screen session name}`. To list screens, `screen -ls`. To remove the screen session use `screen -S {session.name} -p 0 -X quit`

### App user for edge_connexion, edge_sip2

After running the `rake tsv_users:load_app_users` task, assign the permission sets using `rake tsv_users:assign_app_user_psets`.

## Development notes
When a new task is created add the task definition to the `Rakefile` and also to the `load_new_data_and_settings` array
if the task is something that should be loaded into a new instance of FOLIO.

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
