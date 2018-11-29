# High-Throughput Compression

## Table of Contents

- [Deflate](#deflate)
  * [Restrictions](#restrictions)
  * [Compression Format](#compression-format)
  * [Deflate Kernel](#deflate-kernel)
  * [Interface](#interface)
  * [Verification](#verif)
    + [Requirement](#platform-requirement)
    + [Execution](#execution)

## Restrictions


## Compression Format


## Deflate Kernel


## Interface


## Verification

### Requirement

The provided exection files for decompression are generated through SDACCEL 2017.4. They are basically software emulation files and should be performed on the "xinlinx_vcu1525_dynamic_5_0" platform.

### Execution

The verification procedure is similar to software emulation in xocc, you can refer to UG1023(v2017.4) Page 47-49 for detailed information. 

First, create the emulation configuration file. 
```
$ emconfigutil --platform xilinx_vcu1525_dynamic_5_0
```

Then, set your emulation mode to csim.
```
export XCL_EMULATION_MODE=sw_emu
```

Now you can execute the host application with proper arguments. For example, assume you have a compressed file "bib.comp" under the folder ${IN_DIR} and want to decompress it and store it as ${OUT_DIR}/bib.decomp. You need to type in the following command:
```
./host ${IN_DIR}/bib.comp ${OUT_DIR}/bib.decomp
```

