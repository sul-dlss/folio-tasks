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

folio:
  url: https://folio-test.dev.sul.stanford.edu

tsv: tsv
tsv_orders: tsv/acquisitions/orders
json: json
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

### Run tests to verify the validity of the downloaded files
- `rspec spec/users`
- `rspec spec/data_import`

It may be necessary to replace the `spec/fixtures/support` files with new ones from the https://github.com/folio-org/ repo if the json schema tests fail.

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

### Loading Orders
The `prepare_*_orders` and `load_orders_*` rake tasks should be run from the Symphony server since the tasks need tsv and yaml files that are generated there.
1. Run `/s/SUL/Bin/folio_symphony_extract/acquisitions/orders/run_reports.ksh` to get current order data for migration from Symphony.
2. Copy the `order_type_map.tsv` and `sym_hldg_code_location_map.tsv` files from the [FOLIO Ops shared drive](https://drive.google.com/drive/folders/1-FWsDUcc3DRa3sw6jzh4Puvbn-LRcQ-4?usp=sharing) to the `Settings.tsv_orders` directory.
3. Optionally, delete the yaml files in the `Settings.yaml.*` directories, using the tasks `acquisitions:delete_*_order_yaml`.
4. Consolidate all the order tsv data into one yaml file per order by running the `prepare_*_orders` rake tasks.
5. Load orders to FOLIO using the `load_orders_*` rake tasks. This is a long-running task, so it is best to run it in a `screen` session on the Symphony server.
6. Monitor progress by checking the json files written to the `Settings.json_orders` directory.

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
ruby bin/folio_post.rb '/configurations/entries' 'json/email/config_smtp_server_ssl.json'
...
```
