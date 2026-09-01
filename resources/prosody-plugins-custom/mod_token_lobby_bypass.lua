-- Allows selected JWT users to bypass an active lobby.
-- Based on jitsi-contrib/prosody-plugins/token_lobby_bypass.

local LOGLEVEL = "debug";

local muc_util = module:require "muc/util";
local valid_affiliations = muc_util.valid_affiliations;
local util = module:require "util";
local is_healthcheck_room = util.is_healthcheck_room;

module:log("info", "loaded");

module:hook("muc-occupant-pre-join", function (event)
    local room, occupant = event.room, event.occupant;

    if is_healthcheck_room(room.jid) then
        return;
    end

    if room._data.lobbyroom == nil then
        module:log(LOGLEVEL, "skip room with no active lobby - %s", room.jid);
        return;
    end

    if not event.origin.auth_token then
        module:log(LOGLEVEL, "skip user with no token - %s", occupant.bare_jid);
        return;
    end

    local context = event.origin.jitsi_meet_context_user;
    if context and context["lobby_bypass"] == true then
        module:log(LOGLEVEL, "Bypassing lobby for room %s occupant %s", room.jid, occupant.bare_jid);

        occupant.role = "participant";

        local affiliation = room:get_affiliation(occupant.bare_jid);
        if valid_affiliations[affiliation or "none"] < valid_affiliations.member then
            module:log(LOGLEVEL, "Setting affiliation for %s -> member", occupant.bare_jid);
            room:set_affiliation(true, occupant.bare_jid, "member");
        end
    end
end, -3);
