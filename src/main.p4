/* -*- P4_16 -*- */
#include <v1model.p4>
#include <core.p4>

#include "headers.p4"

/*************************************************************************
************************* P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet, out headers_t hdr, inout metadata_t meta,
                inout standard_metadata_t standard_metadata) {

  state start {
    packet.extract(hdr.ethernet);

    transition select(hdr.ethernet.etherType) {
      TYPE_IPV4: parse_ipv4;
      default: accept;
    }
  }

  state parse_ipv4 {
    packet.extract(hdr.ipv4);
    transition accept;
  }
}

/*************************************************************************
*************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers_t hdr, inout metadata_t meta) {
  apply { }
}

/*************************************************************************
***************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers_t hdr, inout metadata_t meta,
                  inout standard_metadata_t standard_metadata) {

  action forward(bit<16> port) { 
    standard_metadata.egress_spec = port; 
  }

  table table_vf_forward {
    key = { 
      standard_metadata.ingress_port : exact; 
    }
    actions = { 
      forward; 
    }
    size = 4;
  }

  apply {
    table_vf_forward.apply();
  }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers_t hdr, inout metadata_t meta,
                 inout standard_metadata_t standard_metadata) {

  action append_nfp_mac_eg_cmd() {
    hdr.nfp_mac_eg_cmd.setValid();
    hdr.nfp_mac_eg_cmd = {0, 1, 0, 0x0};
  }

  table table_append_nfp_mac_eg_cmd {
    key = { 
      standard_metadata.egress_port : exact; 
    }
    actions = { 
      NoAction;
      append_nfp_mac_eg_cmd;
    }
    default_action = NoAction; // From core.p4
    size = 2;
  }

  apply { 
    table_append_nfp_mac_eg_cmd.apply(); 
  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers_t hdr, inout metadata_t meta) {
  apply { }
}

/*************************************************************************
************************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers_t hdr) {
  apply { packet.emit(hdr); }
}

/*************************************************************************
****************************  S W I T C H  *******************************
*************************************************************************/

V1Switch(MyParser(), MyVerifyChecksum(), MyIngress(), MyEgress(),
         MyComputeChecksum(), MyDeparser()) main;
