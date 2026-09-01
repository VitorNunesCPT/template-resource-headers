-- Auto-activates lobby for all non-healthcheck rooms.
-- Based on jitsi-contrib/prosody-plugins/lobby_autostart.

local util = module:require "util";
local is_healthcheck_room = util.is_healthcheck_room;

module:log("info", "loaded");

module:hook("muc-room-pre-create", function (event)
    local room = event.room;

    if is_healthcheck_room(room.jid) then
        return;
    end

    prosody.events.fire_event("create-persistent-lobby-room", { room = room; });
end);
