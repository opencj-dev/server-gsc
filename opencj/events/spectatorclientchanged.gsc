#include openCJ\util;

main(newClient)
{
	self openCJ\statistics::onSpectatorClientChanged(newClient);
	self openCJ\showRecords::onSpectatorClientChanged(newClient);
}