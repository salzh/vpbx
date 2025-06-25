--
--	FusionPBX
--	Version: MPL 1.1
--
--	The contents of this file are subject to the Mozilla Public License Version
--	1.1 (the "License"); you may not use this file except in compliance with
--	the License. You may obtain a copy of the License at
--	http://www.mozilla.org/MPL/
--
--	Software distributed under the License is distributed on an "AS IS" basis,
--	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
--	for the specific language governing rights and limitations under the
--	License.
--
--	The Original Code is FusionPBX
--
--	The Initial Developer of the Original Code is
--	Mark J Crane <markjcrane@fusionpbx.com>
--	Copyright (C) 2010-2015
--	the Initial Developer. All Rights Reserved.
--
--	Contributor(s):
--	Mark J Crane <markjcrane@fusionpbx.com>

--include config.lua
	require "resources.functions.config";

--set variables
	digit_timeout = "5000";

--check if a file exists
	require "resources.functions.file_exists"

--run if the session is ready
	if ( session:ready() ) then
		--answer the call
			session:answer();

		--add short delay before playing the audio
			--session:sleep(1000);

		--get the variables
			uuid = session:getVariable("uuid");
			domain_name = session:getVariable("domain_name");
			context = session:getVariable("context");
			sounds_dir = session:getVariable("sounds_dir");
			destination_number = session:getVariable("destination_number");
			caller_id_number = session:getVariable("caller_id_number");
			record_ext = session:getVariable("record_ext");
			ring_group_confirm_file = session:getVariable("ring_group_confirm_file") or '';
			freeswitch.consoleLog("notice", "[confirm.lua] ring_group_confirm_file: " .. ring_group_confirm_file .. "\n");
		--confirm or not to confirm
			if (session:getVariable("confirm")) then
				confirm = session:getVariable("confirm");
			end

		--prepare the api
			api = freeswitch.API();

            session:execute('amd', '');
            amd_result = session:getVariable('amd_result')
        --process the response
            if (amd_result == "HUMAN") then
                freeswitch.consoleLog("NOTICE", "[confirm] answered by human\n");
            elseif (digit == "MACHINE") then
                freeswitch.consoleLog("NOTICE", "[confirm] answered by machine\n");
                session:hangup("NO_ANSER"); --LOSE_RACE
            
            else
                --freeswitch.consoleLog("NOTICE", "[confirm] no answer\n");
                freeswitch.consoleLog("NOTICE", "[confirm] answered by unknown\n");
                session:hangup("NO_ANSWER");
            end

	end
