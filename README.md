# **DNC Daemon**

DNC Daemon is a Ruby application for the management of a three-node file control system.

## Documentation

See documentation on [RubyDoc](http://www.rubydoc.info/github/z64/dnc-daemon/master)

## Configuration

Each of these folder locations is configured in `config.yaml`.

- **CAM Folder:** Template programs are stored here, ready for production.
- **Outgoing Folder:** Copies of files from CAM, to be sent to the floor.
- **Incoming Folder:** Programs returned to the floor, possibly with modifications.

You can also configure the polling frequency at which files are processed.

See the `config-example.yaml` for reference.

## Running

Run `ruby run.rb`.

### Dependencies

- `rufus-scheduler`

## Workflow

1. On startup, the Daemon will cache `File` handlers to all available template programs in `cam/`, and child programs in `incoming/` and `outgoing/`.

2. The Daemon will match the template files with existing files in `incoming/` and `outgoing/` and if any are found, will move them both into timestamped folders inside the template `cam/` directory.

3. The Daemon will stay on and continue to process files at the time interval specified in `config.yaml`.
