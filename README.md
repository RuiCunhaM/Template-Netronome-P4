# Template Netronome P4

A template repository to work with P4 programs on Netronome SmartNICs.


## Usage

**This assumes you have the SDK Hosted Toolchain installed locally**

1. Run `./configure.sh` with the intended options to generate the `Makefile`
    - Example:
        ```
        ./configure.sh --option_1=value --option_2=value --flag_option
        ```
    - **Default options are recommended.** See [Configuration Options](#configuration-options) for a full list.

2. Add your program's source files to the `src` directory

3. Run `make` to compile your program

4. Load your program:
    ```
    make load REMOTEHOST=<target host> CONFIG=<config_file.json>
    ```
    - `CONFIG` default value is `configs/config.json`

5. You can repeat step **1.** any time to adjust options and create a new `Makefile`

---

## Configuration Options

Available options for the `configure.sh` script. Note that `nfp4build` has additional options available not covered by this script. For more details run `nfp4build --help`.

| Option | Description | Default Vaue |
|--------|-------------|--------------|
| --program | Program's name | program |
| --source | Main P4 source file (without extension) | main |
| --sku | SKU | AMDA0096-0001:0 |
| --platform | Platform | lithium |
| --me-count | Number of Microengines to instantiate | " " (Maximum) |
| --sandbox-c | C plugin source file (without extension) | " " (none) |
| --no-reduce-threads | Use 8-context mode for microengines | false |
| --shared-codestore | Build with shared codestore support | false |
| --p4-version | P4 version | 16 |
| --no-header-ops | Do not allow all headers to be addable/removable | false |
| --implicit-header-valid | Enable P4 implicit header valid matching semantics | false |
| --no-zero-new-headers | No strict P4 behaviour of zeroing all new headers | false |
| --m-group-count | Number of multicast groups to support | 16 |
| --m-group-size | Number of multicast ports per group | 16 |
