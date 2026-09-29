// license:BSD-3-Clause
// copyright-holders:AJR

#include "emu.h"

#include "bus/nscsi/cd.h"
#include "bus/nscsi/hd.h"

void default_scsi_devices(device_slot_interface &device)
{
	device.option_add("cdrom", NSCSI_CDROM);
	device.option_add("cdrom_2x", NSCSI_CDROM_2X);
	device.option_add("harddisk", NSCSI_HARDDISK);
}
