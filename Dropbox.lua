-- Project: Dropbox sample app
--
-- File name: Dropbox.lua
--
-- Author: Michael Weingarden (thinkatorium.com)
--
-- Abstract: Demonstrates how to connect to Dropbox using Oauth Authenication.
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local oAuth = require "oAuth"
local widget2 = require( "widget" )
local json = require("json")

_W = display.contentWidth
_H = display.contentHeight

-- Fill in the following fields from your Dropbox app developer account
consumer_key = ""			-- key string goes here
consumer_secret = ""		-- secret string goes here

-- The web URL address below can be anything
-- Dropbox sends the webaddress with the token back to your app and 
--		the code strips out the token to use to authorise it
--
webURL = "http://google.com/"

-- url is unrelated to webURL, it is used to store the url returned from Dropbox
url = ""

-- Note: Once logged on, the access_token and access_token_secret should be saved so they can
--	     be used for the next session without the user having to log in again.
-- The following is returned after a successful authenications and log-in by the user
--
local access_token
local access_token_secret
local dropbox_request_token_secret
local uid

-- Display a message if there is not app keys set
--
if not consumer_key or not consumer_secret then
	-- Handle the response from showAlert dialog boxbox
	--
	print("can't find key or secret")
	local function onComplete( event )
		if event.index == 1 then
			system.openURL( "https://www.dropbox.com/developers/start" )
		end
	end

	native.showAlert( "Error", "To develop for DropBox, you need to get an API key and application secret. This is available from Dropbox's website.",
		{ "Learn More", "Cancel" }, onComplete )
end


-----------------------------------------------------------------------------------------
-- RESPONSE TO TABLE
--
-- Strips the token from the web address returned
-- Converts string to table
-----------------------------------------------------------------------------------------
--
function responseToTable(str, delimiters)
	local obj = {}
	print("responseToTable string: "..str)

	while str:find(delimiters[1]) ~= nil do
		--print("entered responseToTable loop")
		if #delimiters > 1 then
			local key_index = 1
			local val_index = str:find(delimiters[1])
			local key = str:sub(key_index, val_index - 1)
	
			str = str:sub((val_index + delimiters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimiters[2]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimiters[2])
				value = str:sub(1, (end_index - 1))
				str = str:sub((end_index + delimiters[2]:len()), str:len())
			end
			obj[key] = value
			print(key .. ":" .. value)		-- **debug
		else
	
			local val_index = str:find(delimiters[1])
			str = str:sub((val_index + delimiters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimiters[1]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimiters[1])
				value = str:sub(1, (end_index - 1))
				str = str:sub(end_index, str:len())
			end
			
			obj[#obj + 1] = value
			--print(value)					-- **debug
		end
	end
	print("done with responseToTable loop")
	
	return obj
end


function displayAuthButton()

	local function authListener(event)
		print("authListener: ", event.url)
		url = event.url

		print("done with authListener")

		return true
	end

	print("access_token: ",access_token)
	
	-- Check to see if we are authorized to access Dropbox
	if not access_token then
		print( "Authorizing account" )
		
		if not consumer_key or not consumer_secret then
			print("consumer_key: "..consumer_key)
			print("consumer_secret: "..consumer_secret)
			-- Exit if no API keys set (avoids crashing app)
			--delegate.dropBoxFailed()
			return
		end
		
		-- Need to authorize first
		--
		print("about to do getRequestToken")
		local dropbox_request = (oAuth.getRequestToken(consumer_key, webURL,
			"https://api.dropbox.com/1/oauth/request_token", consumer_secret))
		
		dropBoxButton2 = widget2.newButton{
		        id = "button2",
		        label = "2. Authorize",
		        left = _W*0.1,
		        top = _H*0.3,
		        width = _W*0.8, height = _H*0.1,
		        fontSize = 24,
		        labelColor = { default = {80, 80, 255}, over = {255} },
		        strokeColor = {0},
		        defaultColor = {255},
		        overColor = {128},
		        cornerRadius = 8,
		        -- Interesting, you can call dropit with no ()'s
		        --    and if you put in the ()'s it runs automatically without waiting for button press?
		        onRelease = function()
		            local token = _G.response:match('oauth_token=([^&]+)')
        		    local token_secret = _G.response:match('oauth_token_secret=([^&]+)')

					print("completed getRequestToken")
					print("_G.response: ".._G.response.."")
					print("token: "..token.."")

					local dropbox_request_token = token
					print("dropbox_request_token: "..dropbox_request_token.."")
					dropbox_request_token_secret = token_secret
					print("dropbox_request_token_secret: "..dropbox_request_token_secret.."")

					if not dropbox_request_token then
						-- No valid token received. Abort
						print("dropbox_request_token not found")
						return
					end

					print("dropbox_request_token found")
					
					-- Request the authorization
					native.showWebPopup(0, 0, 320, 480, "https://www.dropbox.com/1/oauth/authorize?oauth_token="
						.. dropbox_request_token, {urlRequest = authListener})

		        end -- end of onRelease function
		    } -- end of dropBoxButton2

	end
end


-- this function goes with the dropBoxButton3 function below
local function accessRequest( event )
		print( "Asking for access" )
		
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, dropbox_request_token_secret,
			consumer_key, consumer_secret, "https://api.dropbox.com/1/oauth/access_token"), {"=", "&"})

		print("ready to get account info")

end

dropBoxButton3 = widget2.newButton{
	id = "button3",
	label = "3. Get Access Token",
	left = _W*0.05,
	top = _H*0.5,
	width = _W*.9, height = _H*.1,
	fontSize = 24,
	labelColor = { default = {80, 80, 255}, over = {255} },
	strokeColor = {0},
	defaultColor = {255},
	overColor = {128},
	cornerRadius = 8,
	-- Interesting, you can call dropit with no ()'s
	--    and if you put in the ()'s it runs automatically without waiting for button press?
	onPress = accessRequest

	
}  -- end of dropBoxButton3

-- This function goes with the dropboxbutton4 button below
local function getAcctInfo( event )
		print( "get account info" )
		
		local response = responseToTable(_G.response, {"=", "&"})

		access_token = response.oauth_token
		access_token_secret = response.oauth_token_secret
		uid = response.uid

		print( "Got access token: "..access_token )

		------------------------------
		-- API CALL:
		------------------------------
		-- no params are needed for Dropbox API calls
		local params = {}

		request_response = oAuth.makeRequest("https://api.dropbox.com/1/account/info",
			params, consumer_key, access_token, consumer_secret, access_token_secret, "GET")
			
		print("_G.response: ".._G.response)
		print("Dropbox response: "..request_response)
end

dropBoxButton4 = widget2.newButton{
	id = "button4",
	label = "4. Get Acct Info",
	left = _W*0.05,
	top = _H*0.7,
	width = _W*.9, height = _H*.1,
	fontSize = 24,
	labelColor = { default = {80, 80, 255}, over = {255} },
	strokeColor = {0},
	defaultColor = {255},
	overColor = {128},
	cornerRadius = 8,
	-- Interesting, you can call the function with no ()'s
	--    and if you put in the ()'s it runs automatically without waiting for button press?
	onPress = getAcctInfo	
}  --end of dropBoxButton4

-- This function goes with the dropboxbutton5 button below
local function dispAcctInfo( event )
		print( "display account info" )
			
		print("_G.response: ".._G.response)

		local data = json.decode(_G.response)

		print("data[display_name]: "..data["display_name"])

end

dropBoxButton5 = widget2.newButton{
	id = "button5",
	label = "5. Display Acct Info",
	left = _W*0.05,
	top = _H*0.9,
	width = _W*.9, height = _H*.1,
	fontSize = 24,
	labelColor = { default = {80, 80, 255}, over = {255} },
	strokeColor = {0},
	defaultColor = {255},
	overColor = {128},
	cornerRadius = 8,
	-- Interesting, you can call the function with no ()'s
	--    and if you put in the ()'s it runs automatically without waiting for button press?
	onPress = dispAcctInfo	
}  --end of dropBoxButton5