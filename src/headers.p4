/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

const bit<16> TYPE_IPV4 = 0x800;

header ethernet_t {
  bit<48> dstAddr;
  bit<48> srcAddr;
  bit<16> etherType;
}

header ipv4_t {
  bit<4> version;
  bit<4> ihl;
  bit<8> diffserv;
  bit<16> totalLen;
  bit<16> identification;
  bit<3> flags;
  bit<13> fragOffset;
  bit<8> ttl;
  bit<8> protocol;
  bit<16> hdrChecksum;
  bit<32> srcAddr;
  bit<32> dstAddr;
}

header tcp_t {
  bit<16> srcPort;
  bit<16> dstPort;
  bit<32> seqNum;
  bit<32> ackNum;
  bit<4> dataOffset;
  bit<12> opts;
  bit<16> winSize;
  bit<16> checksum;
  bit<16> urgPtr;
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
