#include <mem_atomic.h>
#include <nfp.h>
#include <pif_plugin.h>

// Based on TurboFlow's implementation
// (https://github.com/jsonch/TurboFlow)

__declspec(emem export aligned(64)) int lock;

void acquire(volatile __declspec(mem addr40) void *addr) {
  SIGNAL_PAIR signal_pair;
  unsigned int addr_hi, addr_lo;
  __declspec(read_write_reg) int xfer;
  addr_hi = ((unsigned long long int)addr >> 8) & 0xff000000;
  addr_lo = (unsigned long long int)addr & 0xffffffff;

  do {
    xfer = 1;
    __asm {
            mem[test_subsat, xfer, addr_hi, <<8, addr_lo, 1], sig_done[signal_pair];
            ctx_arb[signal_pair]
    }
  } while (xfer == 0);
}

void release(volatile __declspec(mem addr40) void *addr) {
  unsigned int addr_hi, addr_lo;
  __declspec(read_write_reg) int xfer;
  addr_hi = ((unsigned long long int)addr >> 8) & 0xff000000;
  addr_lo = (unsigned long long int)addr & 0xffffffff;

  __asm {
        mem[incr, --, addr_hi, <<8, addr_lo, 1];
  }
}

int pif_plugin_critical_begin(EXTRACTED_HEADERS_T *headers,
                              MATCH_DATA_T *data) {
  acquire(&lock);

  return PIF_PLUGIN_RETURN_FORWARD;
}

int pif_plugin_critical_end(EXTRACTED_HEADERS_T *headers, MATCH_DATA_T *data) {
  release(&lock);

  return PIF_PLUGIN_RETURN_FORWARD;
}

void pif_plugin_init_master() { release(&lock); }

void pif_plugin_init() {}
