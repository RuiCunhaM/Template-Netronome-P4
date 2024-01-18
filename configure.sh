#!/bin/bash

PROGRAM=program
SOURCE=main
SANDBOX=""

P4_VERSION=16

# Agilio CX 2x10GbE
SKU=AMDA0096-0001:0
PLATFORM=lithium

ME_COUNT=""

# Multicast options
# Default values used in the SDK
M_GROUP_COUNT=16
M_GROUP_SIZE=16

NO_REDUCE_THREAD=false
NO_SHARED_CODESTORE=false
NO_HEADER_OPTS=false
IMPLICIT_HEADER_VALID=false
NO_ZERO_NEW_HEADERS=false

EXTRA_ARGS=""

# Parse arguments
for i in "$@"; do
  case $i in
    --program=*)
      PROGRAM="${i#*=}"
      shift 
      ;;
    --source=*)
      SOURCE="${i#*=}"
      shift
      ;;
    --sku=*)
      SKU="${i#*=}"
      shift
      ;;
    --platform=*)
      PLATFORM="${i#*=}"
      shift
      ;;
    --me-count=*)
      ME_COUNT="${i#*=}"
      shift
      ;;
    --sandbox-c=*)
      SANDBOX="${i#*=}"
      shift
      ;;
    --no-reduce-threads)
      NO_REDUCE_THREAD=true
      shift
      ;;
    --no-shared-codestore)
      NO_SHARED_CODESTORE=true
      shift
      ;;
    --p4-version=*)
      P4_VERSION="${i#*=}"
      shift
      ;;
    --no-header-ops)
      NO_HEADER_OPTS=true
      shift
      ;;
    --implicit-header-valid)
      IMPLICIT_HEADER_VALID=true
      shift
      ;;
    --no-zero-new-header)
      NO_ZERO_NEW_HEADERS=true
      shift
      ;;
    --m-group-count=*)
      M_GROUP_COUNT="${i#*=}"
      shift
      ;;
    --m-group-size=*)
      M_GROUP_SIZE="${i#*=}"
      shift
      ;;
    --*)
      EXTRA_ARGS+=" $i"
      ;;
    *)
      echo "Unknown option: $i"
      exit 1
      ;;
  esac
done

COMMAND="/opt/netronome/p4/bin/nfp4build --output-nffw-filename ./build/$PROGRAM.nffw"\
" --pif-output-dir ./pifs"\
" --sku $SKU"\
" --platform $PLATFORM"\
" --block-make"\
" --nfp4c_p4_version $P4_VERSION"\
" --nfp4c_p4_compiler p4c-nfp"\
" --nfirc_multicast_group_count $M_GROUP_COUNT"\
" --nfirc_multicast_group_size $M_GROUP_SIZE"\
" $EXTRA_ARGS"\

if [ -n "$ME_COUNT" ];
then 
  COMMAND+=" --application-me-count $ME_COUNT"
fi

if [ -n "$SANDBOX" ];
then 
  COMMAND+=" --define PIF_PLUGIN_INIT"
  COMMAND+=" --sandbox-c src/$SANDBOX.c"
fi

# Since there is no clear indication which one is the default option
# For the following options we always set one of the two

if $NO_REDUCE_THREAD;
then
  COMMAND+=" --no-reduced-thread-usage"
else
  COMMAND+=" --reduced-thread-usage"
fi

if $NO_SHARED_CODESTORE;
then
  COMMAND+=" --no-shared-codestore"
else
  COMMAND+=" --shared-codestore"
fi

if $NO_HEADER_OPTS;
then
  COMMAND+=" --nfirc_no_all_header_ops"
else
  COMMAND+=" --nfirc_all_header_ops"
fi

if $IMPLICIT_HEADER_VALID;
then
  COMMAND+=" --nfirc_implicit_header_valid"
else
  COMMAND+=" --nfirc_no_implicit_header_valid"
fi

if $NO_ZERO_NEW_HEADERS;
then
  COMMAND+=" --nfirc_no_zero_new_headers"
else
  COMMAND+=" --nfirc_zero_new_headers"
fi


COMMAND+=" --incl-p4-build src/$SOURCE.p4"

# Create build directory
mkdir -p build

# Run nfp4build
$COMMAND

echo "# $COMMAND" > Makefile

cat Makefile-nfp4build >> Makefile
rm Makefile-nfp4build

echo "" >> Makefile
echo "################" >> Makefile
echo "# Custom Rules #" >> Makefile
echo "################" >> Makefile

# Add load rule
echo "
REMOTEHOST=<remote-host>
CONFIG=configs/config.json

.PHONY: load
load: \$(OUTDIR)/$PROGRAM.nffw
	\$(SDKP4DIR)/bin/rtecli -r \$(REMOTEHOST) design-load -f \$(OUTDIR)/$PROGRAM.nffw -c \$(CONFIG)
" >> Makefile
