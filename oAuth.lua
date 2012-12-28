-- Project: Twitter sample app
--
-- File name: oAuth.lua
--
-- Author: Corona Labs
--
-- Abstract: Demonstrates how to connect to Twitter using Oauth Authenication.
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
-----------------------------------------------------------------------------------------

module(...,package.seeall)
 
--[[
local http = require("socket.http")
local ltn12 = require("ltn12")
local crypto = require("crypto")
local mime = require("mime")
]]--

--mySigMethod = "HMAC-SHA1"
mySigMethod = "PLAINTEXT"
_G.response = ""


-----------------------------------------------------------------------------------------
-- GET REQUEST TOKEN
-----------------------------------------------------------------------------------------
--
function getRequestToken(consumer_key, token_ready_url, request_token_url, consumer_secret)
 
        local post_data = 
        {
                oauth_consumer_key = consumer_key,
                oauth_timestamp    = get_timestamp(),
                oauth_version      = '1.0',
                --oauth_nonce        = get_nonce(),
                oauth_callback         = token_ready_url,
                oauth_signature_method = mySigMethod

        }
    
    print("in getRequestToken")
    local post_data = oAuthSign(request_token_url, "POST", post_data, consumer_secret)
    print("completed oAuthSign")
    _G.response = rawPostRequest(request_token_url, post_data)
    print("completed rawPostRequest")
    --local result = _G.response
    print("result of rawPostRequest: ".._G.response.."")

    result = _G.response..""
    print("result: "..result.."")
    
    local token = result:match('oauth_token=([^&]+)')
            --print("token: "..token)
            local token_secret = result:match('oauth_token_secret=([^&]+)')
            --print("token_secret: "..token_secret)    
                return 
                {
                        token = token,
                        token_secret = token_secret
                }

        
end

-----------------------------------------------------------------------------------------
-- GET ACCESS TOKEN
-----------------------------------------------------------------------------------------
--
function getAccessToken(token, verifier, token_secret, consumer_key, consumer_secret, access_token_url)
            
    local post_data = 
        {
                oauth_consumer_key = consumer_key,
                oauth_timestamp    = get_timestamp(),
                oauth_version      = '1.0',
                --oauth_nonce        = get_nonce(),
                oauth_token        = token,
                oauth_token_secret = token_secret,
                oauth_verifier     = verifier,
                oauth_signature_method = mySigMethod
 
    }
    print("in getAccessToken")
    local post_data = oAuthSign(access_token_url, "POST", post_data, consumer_secret)
    print("query string (post_data): "..post_data)
    local result = rawPostRequest(access_token_url, post_data)
    print("completed rawPostRequest: "..result)
    return result
end

-----------------------------------------------------------------------------------------
-- MAKE REQUEST
-----------------------------------------------------------------------------------------
--
function makeRequest(url, body, consumer_key, token, consumer_secret, token_secret, method)
    
    local post_data = 
        {
                oauth_consumer_key = consumer_key,
                oauth_nonce        = get_nonce(),
                oauth_signature_method = mySigMethod,
                oauth_token        = token,
                oauth_timestamp    = get_timestamp(),
                oauth_version      = '1.0',
                oauth_token_secret = token_secret
    }
    
    for i=1, #body do
        post_data[body[i].key] = body[i].value
    end

    post_data = oAuthSign(url, method, post_data, consumer_secret)
 
    local result
        
    if method == "POST" then
      result = rawPostRequest(url, post_data)
    else
      result = rawGetRequest(post_data)
    end
        
    return result
end

-----------------------------------------------------------------------------------------
-- OAUTH SIGN
-----------------------------------------------------------------------------------------
--
function oAuthSign(url, method, args, consumer_secret)
 
    local token_secret = args.oauth_token_secret or ""
 
    args.oauth_token_secret = nil
 
        local keys_and_values = {}
 
        for key, val in pairs(args) do
                table.insert(keys_and_values, 
                {
                        key = encode_parameter(key),
                        val = encode_parameter(val)
                })
    end
 
    table.sort(keys_and_values, function(a,b)
        if a.key < b.key then
            return true
        elseif a.key > b.key then
            return false
        else
            return a.val < b.val
        end
    end)
    
    local key_value_pairs = {}
 
    for _, rec in pairs(keys_and_values) do
        table.insert(key_value_pairs, rec.key .. "=" .. rec.val)
    end
    
   local query_string_except_signature = table.concat(key_value_pairs, "&")
   
   local sign_base_string = method .. '&' .. encode_parameter(url) .. '&'
   		.. encode_parameter(query_string_except_signature)
 
   local key = encode_parameter(consumer_secret) .. '&' .. encode_parameter(token_secret)
   --print( "consumer_secret key: " .. consumer_secret )	-- **debug
   --print( "Encoded key: " .. key )						-- **debug
 
   -- try just putting the mime.b64 encoded key into the query string
   --local hmac_binary = sha1(sign_base_string, key, true)
   --local hmac_b64 = mime.b64(hmac_binary)
   -- try not even mime.b64 encoding the key
   --local hmac_b64 = mime.b64(key)

   --local query_string = query_string_except_signature .. '&oauth_signature=' .. encode_parameter(hmac_b64)
   --print("oauth_signature: "..encode_parameter(hmac_b64))
   local query_string = query_string_except_signature .. '&oauth_signature=' .. encode_parameter(key)
   print("oauth_signature: "..encode_parameter(key))

        if method == "GET" then
           return url .. "?" .. query_string
        else
                return query_string
        end
end

-----------------------------------------------------------------------------------------
-- ENCODE PARAMETER (URL_Encode)
-- Replaces unsafe URL characters with %hh (two hex characters)
-----------------------------------------------------------------------------------------
--
function encode_parameter(str)
        return str:gsub('[^-%._~a-zA-Z0-9]',function(c)
                return string.format("%%%02x",c:byte()):upper()
        end)
end

-----------------------------------------------------------------------------------------
-- SHA 1
-----------------------------------------------------------------------------------------
--
function sha1(str,key,binary)
        binary = binary or false
        return crypto.hmac(crypto.sha1,str,key,binary)
end

-----------------------------------------------------------------------------------------
-- GET NONCE
-----------------------------------------------------------------------------------------
--
function get_nonce()
        -- if used with PLAINTEXT, you will need to remove the crypto encoding
        --return mime.b64(crypto.hmac(crypto.sha1,tostring(math.random()) .. "random".. tostring(os.time()),"keyyyy"))
end

-----------------------------------------------------------------------------------------
-- GET TIMESTAMP
-----------------------------------------------------------------------------------------
--
function get_timestamp()
        return tostring(os.time() + 1)
end

--[[
-----------------------------------------------------------------------------------------
-- RAW GET REQUEST
-----------------------------------------------------------------------------------------
--
function rawGetRequest(url)
        local r,c,h
        local response = {}
 
        --//TODO: can't use PLAINTEXT with this non-HTTPS request.  Arrrrggghhh!!!
        r,c,h = http.request
        {
                url = url,
                sink = ltn12.sink.table(response)
        }
 
        return table.concat(response,"")
end
]]--

-----------------------------------------------------------------------------------------
-- RAW GET REQUEST
-----------------------------------------------------------------------------------------
--
function rawGetRequest(url)
    local response = ""
    local function networkListener( event )
            if ( event.isError ) then
                    print( "Network error!")
            else
                    print ( "rawGetRequest RESPONSE: " .. event.response )
                    --local response = json.decode(event.response)
                    --return table.concat(response,"")
                    response = event.response
                    _G.response = event.response
            end
    end
 
    network.request( url, "GET", networkListener )

    return response
end

-----------------------------------------------------------------------------------------
-- RAW POST REQUEST
-----------------------------------------------------------------------------------------
--
function rawPostRequest(url, rawdata)

        --using https might allow the use of PLAINTEXT for oauth signature method
        response = ""

        local function networkListener( event )
            if ( event.isError ) then
                print("Network error! in rawPostRequest in oAuth: "..event.isError)
            else
                print("rawPostRequest STATUS: "..event.status)
                print ( "rawPostRequest RESPONSE: " .. event.response )
                response = event.response
                _G.response = event.response
                print("_G.response: ".._G.response)
            end
        end
	
        body = rawdata

        local params = {}
        params.body = body

        network.request( url, "POST", networkListener,  params) 

        return response
end

---
-- Converts all UTF-8 character sets to unicode/ASCII characters
-- to generate ISO-8859-1 email bodies etc.
--@param utf8 UTF-8 encoded string
--@return a ASCII/ISO-8859-1 8-bit conform string
function utf8_decode(utf8)
 
   local unicode = ""
   local mod = math.mod
 
   local pos = 1
   while pos < string.len(utf8)+1 do
 
      local v = 1
      local c = string.byte(utf8,pos)
      local n = 0
 
      if c < 128 then v = c
      elseif c < 192 then v = c
      elseif c < 224 then v = mod(c, 32) n = 2
      elseif c < 240 then v = mod(c, 16) n = 3
      elseif c < 248 then v = mod(c,  8) n = 4
      elseif c < 252 then v = mod(c,  4) n = 5
      elseif c < 254 then v = mod(c,  2) n = 6
      else v = c end
      
      for i = 2, n do
         pos = pos + 1
         c = string.byte(utf8,pos)
         v = v * 64 + mod(c, 64)
      end
 
      pos = pos + 1
      if v < 255 then unicode = unicode..string.char(v) end
 
   end
 
   return unicode
end
 
---
-- Converts all unicode characters (>127) into UTF-8 character sets
--@param unicode ASCII or unicoded string
--@return a UTF-8 representation
function utf8_encode(unicode)
 
   local math = math
   local utf8 = ""
 
   for i=1,string.len(unicode) do
      local v = string.byte(unicode,i)
      local n, s, b = 1, "", 0
      if v >= 67108864 then n = 6; b = 252
      elseif v >= 2097152 then n = 5; b = 248
      elseif v >= 65536 then n = 4; b = 240
      elseif v >= 2048 then n = 3; b = 224
      elseif v >= 128 then n = 2; b = 192
      end
      for i = 2, n do
         local c = math.mod(v, 64); v = math.floor(v / 64)
         s = string.char(c + 128)..s
      end
      s = string.char(v + b)..s
      utf8 = utf8..s
   end
 
   return utf8
end
