from systemrdl import rdltypes

# sw <--> ipxact:access
ACCESS_MAP = [
    (rdltypes.AccessType.r,     "RO"),
    (rdltypes.AccessType.rw,    "RW"),
    (rdltypes.AccessType.w,     "WO"),
    (rdltypes.AccessType.w1,    "W1"),
]

def access_from_sw(sw):
    for sw_entry, access_entry in ACCESS_MAP:
        if sw == sw_entry:
            return access_entry
    return None

def sw_from_access(access):
    for sw_entry, access_entry in ACCESS_MAP:
        if access == access_entry:
            return sw_entry
    return None

#-------------------------------------------------------------------------------
# onwrite <--> ipxact:modifiedWriteValue
MWV_MAP = [
    (rdltypes.OnWriteType.wclr,     "WC"),
    (rdltypes.OnWriteType.woclr,    "W1C"),
    (rdltypes.OnWriteType.woset,    "W1S"),
    (rdltypes.OnWriteType.wot,      "W1T"),
    (rdltypes.OnWriteType.wset,     "WS"),
    (rdltypes.OnWriteType.wzc,      "W0C"),
    (rdltypes.OnWriteType.wzs,      "W0S"),
    (rdltypes.OnWriteType.wzt,      "W0T"),
]

def mwv_from_onwrite(onwrite):
    for onwrite_entry, mwv_entry in MWV_MAP:
        if onwrite == onwrite_entry:
            return mwv_entry
    return None

def onwrite_from_mwv(mwv):
    for onwrite_entry, mwv_entry in MWV_MAP:
        if mwv == mwv_entry:
            return onwrite_entry
    return None

#-------------------------------------------------------------------------------
# onread <--> ipxact:readAction
READ_ACTION_MAP = [
    (rdltypes.OnReadType.rclr, "RC"),
    (rdltypes.OnReadType.rset, "RS"),
]

def readaction_from_onread(onread):
    for onread_entry, read_action_entry in READ_ACTION_MAP:
        if onread == onread_entry:
            return read_action_entry
    return None

def onread_from_readaction(readaction):
    for onread_entry, read_action_entry in READ_ACTION_MAP:
        if readaction == read_action_entry:
            return onread_entry
    return None
    
