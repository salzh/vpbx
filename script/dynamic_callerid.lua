--	intercom.lua
--	Part of FusionPBX
--	Copyright (C) 2010 Mark J Crane <markjcrane@fusionpbx.com>
--	All rights reserved.
--
--	Redistribution and use in source and binary forms, with or without
--	modification, are permitted provided that the following conditions are met:
--
--	1. Redistributions of source code must retain the above copyright notice,
--	   this list of conditions and the following disclaimer.
--
--	2. Redistributions in binary form must reproduce the above copyright
--	   notice, this list of conditions and the following disclaimer in the
--	   documentation and/or other materials provided with the distribution.
--
--	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
--	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
--	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--	AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
--	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
--	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
--	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--	POSSIBILITY OF SUCH DAMAGE.

--include config.lua
	require "resources.functions.config";

--connect to the database
	local Database = require "resources.functions.database";
	dbh = Database.new('system');

--include json library
	local json
	if (debug["sql"]) then
		json = require "resources.functions.lunajson"
	end

--define the trim function
	require "resources.functions.trim"

--get the variables
	domain_name = session:getVariable("domain_name");
	domain_uuid = session:getVariable("domain_uuid");
	outbound_number = session:getVariable("destination_number");
	freeswitch.consoleLog("notice", "outbound_number: --" .. outbound_number .. "--\n");
	if (string.sub(outbound_number,1,2) == '+1') then
		outbound_area_code = string.sub(outbound_number,3,5);
	elseif(string.sub(outbound_number,1,1) == '1') then
		outbound_area_code = string.sub(outbound_number,2,4);
	else
		outbound_area_code = string.sub(outbound_number,1,3);
	end
	
	freeswitch.consoleLog("notice", "Area Code: " .. outbound_area_code .. "\n");

	--caller_id_name = session:getVariable("caller_id_name");
	caller_id_number = session:getVariable("caller_id_number");

--get if dynamic feature enabled
    sql = "SELECT domain_setting_value FROM v_domain_settings where domain_uuid = :domain_uuid and domain_setting_category='outbound' and domain_setting_subcategory='dynamic_callerid' and domain_setting_enabled='true' limit 1";
    local params = {domain_uuid = domain_uuid};
    if (debug["sql"]) then
		freeswitch.consoleLog("notice", "SQL: " .. sql .. "; params:" .. json.encode(params) .. "\n");
	end
    global_dynamic_callerid = 'false';
    dbh:query(sql, params, function(row)
		global_dynamic_callerid = row.domain_setting_value;
	end);
    
    if (global_dynamic_callerid == 'false') then 
        sql = "SELECT dynamic_callerid FROM v_extensions where extension = :extension and domain_uuid = :domain_uuid limit 1";
        params = {extension = caller_id_number, domain_uuid = domain_uuid};
        if (debug["sql"]) then
            freeswitch.consoleLog("notice", "SQL: " .. sql .. "; params:" .. json.encode(params) .. "\n");
        end
    
        x = 0;
        dbh:query(sql, params, function(row)
            dynamic_callerid = row.dynamic_callerid;
            x = x + 1;
        end);
    else
        dynamic_callerid = 'true';
	end
    
	if (dynamic_callerid and dynamic_callerid == 'true')  then
		--get the destination_number
		sql = "SELECT destination_number FROM v_destinations where destination_number like :destination_number and domain_uuid = :domain_uuid and destination_enabled='true'";
		local params = {destination_number = outbound_area_code .. '%', domain_uuid = domain_uuid};
		if (debug["sql"]) then
			freeswitch.consoleLog("notice", "SQL: " .. sql .. "; params:" .. json.encode(params) .. "\n");
		end

		x = 0;
		dbh:query(sql, params, function(row)
			destination_number = row.destination_number;
			--destination_caller_id_name = row.destination_caller_id_name;
			--destination_caller_id_number = row.destination_caller_id_number;
			x = x + 1;
		end);

	--session actions
		if (session:ready()) then
			if (destination_number) then
				freeswitch.consoleLog("notice", "outbound_caller_id_number="..destination_number.."\n");
				session:execute("set", "outbound_caller_id_number="..destination_number);
			end
			--session:hangup();
		end
	end