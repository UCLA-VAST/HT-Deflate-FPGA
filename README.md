# High-Throughput Compression

## Table of Contents

- [Deflate](#deflate)
  * [Restrictions](#restrictions)
  * [Compression Format](#compression-format)
  * [Deflate Kernel](#deflate-kernel)
  * [Interface](#interface)
  * [Verification](#verif)
    + [Requirement](#requirement)
    + [Execution](#execution)

## Restrictions


## Compression Format

The compression format here we use exactly follows RFC1951: each block of compressed data begins with 3 header bits and ends with code "7'b0000000". Since RFC1951 doesn't limit the compressed block size, we take the whole file as a single block to avoid extra overhead.

## Deflate Kernel


## Interface

The original design was implemented on Intel-Altera HARP and HARPv2 platforms, which have over 15GB/s CPU-FPGA communication bandwidth, to get a maximum end-to-end throughput of ~12GB/s. However, due to copyright issue we will not provide the communication interface code here. But it should be fairly easy for you to wrap the kernel with your own interface if you are a HARP/HARPv2 user and follow what our paper described.

You can also integrate this kernel into SDAccel flow on Xilinx Platforms, i.e. AWS F1 instance. However, as already discussed in our paper, the actual read/write PCIe bandwidth of SDAccel is very limited (less than 3GB/s). So we recommend you using AWS hdk flow to directly feed data from PCIe to the kernel and bypassing the FPGA DRAM access. You can find the relavent information from https://vast.cs.ucla.edu/sites/default/files/publications/st-accel-high.pdf.

If you don't know how to do it, no worries! We will release the interface which bypasses the FPGA DRAM and achieve an end-to-end throughput of >10 GB/s on AWS F1 instance. Please check back later.

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

