# **DNC Daemon**

DNC Daemon is a Ruby application for the management of a three-node file control system.

***Some details below have not been implemented yet, or differs from the current implementation.***

## Documentation

See documentation on [RubyDoc](http://www.rubydoc.info/github/z64/dnc-daemon/master) here.

## Configuration

Each of these folder locations is configured in `config.yaml`.

- **CAM Folder:** Template programs are stored here, ready for production.
- **Outgoing Folder:** Copies of files from CAM, to be sent to the floor.
- **Incoming Folder:** Programs returned to the floor, possibly with modifications.

## Running

Run `ruby run.rb`.

###  Command-Line Flags

Append these after `ruby run.rb` to configure DNC Daemon's behavior. \**(not yet implemented)*

- `--poll (frequency)` - set polling frequency. *(currently set in the `config.yaml` file under the top-level `poll` key)*
- `--config file.yaml` - use a specific `*.yaml` file for configuration
- `--log` - enable verbose logging

### Dependencies

- `rufus-scheduler`

## Workflow

1. On startup, the Daemon will cache `File` handlers to all available template programs in `cam/`.

2. The Daemon will poll for files in `incoming/` with matching filenames, and if any are found, will run a boolean comparison (*has the file changed?*, not: *what has changed?*) to see if any contents of the file have been modified.

3. If `true`, the modified file will be removed from `incoming/` and moved to `daemon/incoming/` (this folder will be created if it does not exist).

4. A timestamped note will be added to the file to mark when it was automatically captured by the Daemon.
