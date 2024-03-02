/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

const bit<16> TYPE_IPV4 = 0x800;
const bit<8>  TYPE_TCP  = 0x06;
const bit<8>  TYPE_UDP  = 0x11;

header ethernet_t {
  bit<48> dstAddr;
  bit<48> srcAddr;
  bit<16> etherType;
}

header ipv4_t {
  bit<4>  version;
  bit<4>  ihl;
  bit<8>  diffserv;
  bit<16> totalLen;
  bit<16> identification;
  bit<3>  flags;
  bit<13> fragOffset;
  bit<8>  ttl;
  bit<8>  protocol;
  bit<16> hdrChecksum;
  bit<32> srcAddr;
  bit<32> dstAddr;
}

header tcp_t {
  bit<16> srcPort;
  bit<16> dstPort;
  bit<32> seqNo;
  bit<32> ackNo;
  bit<4>  dataOffset;
  bit<4>  res;
  bit<8>  flags;
  bit<16> window;
  bit<16> checksum;
  bit<16> urgentPtr;
}

header udp_t {
  bit<16> srcPort;
  bit<16> dstPort;
  bit<16> length;
  bit<16> checksum;
}

header nfp_mac_eg_cmd_t {
  bit l3Sum;        // Enable L3 checksum computation
  bit l4Sum;        // Enable L4 checksum computation
  bit tsMark;       // Enable Timestamp marking on egress
  bit<29> ignore;
}

struct headers_t {
  nfp_mac_eg_cmd_t nfp_mac_eg_cmd;
  ethernet_t ethernet;
  ipv4_t ipv4;
}

struct metadata_t {
  /* empty */
}
