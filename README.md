# Template Netronome P4

A template repository to work with P4 programs on Netronome SmartNICs. Mostly a wrapper around `nfp4build` with sensible defaults for `Agilio CX 2x10GbE` SmartNICs. 

## Usage

**This assumes you have the SDK Hosted Toolchain installed locally**

1. Click in `Use this Template > Create a new repository` to create your own repository

2. Clone your repository

3. Run `./configure.sh` with the intended options to generate the `Makefile`
    - Example:
        ```
        ./configure.sh --option_1=value --option_2=value --flag_option
        ```
    - **Default options are recommended.** See [Configuration Options](#configuration-options) for a full list.

4. Add your program's source files to the `src` directory

5. Run `make` to compile your program

6. Load your program:
    ```
    make load REMOTEHOST=<target host> CONFIG=<config_file.json>
    ```
    - `CONFIG` default value is `configs/config.json`

7. You can repeat step **3.** any time to adjust options and generate a new `Makefile`

---

## Critical Sections

Netronome's compiler ignores the `@atomic` annotation present in P4's specification. To create critical sections an example C plugin is included at [`src/critical.c`](src/critical.c).

##### Usage:

> [!WARNING]
> This implementation utilizes only one spin lock! If you have multiple critical regions they will all share the same lock! 

1. Declare the C plugin source file when running the `configure.sh` script:
    ```
    ./configure.sh --sandbox-c=critical
    ```

2. Declare the extern functions in P4:
    ```p4
    extern void critical_begin();
    extern void critical_end();
    ```

3. Delimit your critical sections:
    ```p4
    critical_begin();
    // Your critical code
    critical_end();
    ```

---

## Configuration Options

> [!NOTE]  
> `nfp4build` has additional options available not covered/wrapped by this script but that can also be used. For more details run `nfp4build --help`.

| Option | Description | Default Vaue |
|--------|-------------|--------------|
| --program | Program's name | program |
| --source | Main P4 source file (without extension) | main |
| --sku | SKU | AMDA0096-0001:0 |
| --platform | Platform | lithium |
| --me-count | Number of Microengines to instantiate | " " (Maximum) |
| --sandbox-c | C plugin source file (without extension) | " " (none) |
| --no-reduce-threads | Use 8-context mode for microengines | false |
| --no-shared-codestore | Build with no shared codestore support | false |
| --p4-version | P4 version | 16 |
| --no-header-ops | Do not allow all headers to be addable/removable | false |
| --implicit-header-valid | Enable P4 implicit header valid matching semantics | false |
| --no-zero-new-headers | No strict P4 behaviour of zeroing all new headers | false |
| --m-group-count | Number of multicast groups to support | 16 |
| --m-group-size | Number of multicast ports per group | 16 |
