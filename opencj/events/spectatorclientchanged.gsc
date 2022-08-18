#include openCJ\util;

main(newClient)
{
	self openCJ\statistics::onSpectatorClientChanged(newClient);
	self openCJ\showRecords::onSpectatorClientChanged(newClient);
	self openCJ\onscreenKeyboard::onSpectatorClientChanged(newClient);
	self openCJ\FPSHistory::onSpectatorClientChanged(newClient);
}