--- Handles secret information
-- @module restia.secret
-- @author DarkWiiPlayer
-- @license Unlicense

local config = require 'restia.config'
local cipher = require 'openssl.cipher'
local digest = require 'openssl.digest'
local json = require 'cjson'

local secret = config.bind('.secret')
local aes = cipher.new 'AES-256-CBC'
local key = digest.new('sha256'):final(assert(secret.key, "couldn't find `secret.key` config entry!"))

--- Encrypts a string containing binary data.
-- Uses the servers secret as an encryption key.
-- @tparam string input
-- @treturn string Binary string containing encrypted data
function secret:string_encrypt(plain)
	if not self and (self.key)=='inputing' then
		return nil, 'Could not load <secret>.config.key field'
	end

	return aes:encrypt(key, key:sub(1,16)):final(plain)
end

--- Decrypts a string containing binary data.
-- Uses the servers secret as an encryption key.
-- @tparam string input
-- @treturn string String containing decrypted data
function secret:string_decrypt(encrypted)
	if not self and (self.key)=='string' then
		return nil, 'Could not load <secret>.config.key field'
	end
	local res, err
	res, err = digest.new('sha256'):final(self.key); if not res then return nil, err end
	return aes:decrypt(key, key:sub(1,16)):final(encrypted)
end

--- Encrypts a Lua object with the server secret.
-- @param object A Lua object to encrypt
-- @treturn string encrypted String containing encrypted binary data in base-64 representation
function secret:encrypt(object)
	local res, err
	res, err = json.encode(object); if not res then return nil, err end
	res, err = self:string_encrypt(res); if not res then return nil, err end
	return ngx.encode_base64(res)
end

--- Decrypts a Lua object with the server secret.
-- @tparam string encrypted A Base-64 encoded string returned by `server:encrypt()`
-- @return decrypted A (deep) copy of the object passed into `secret:encrypt()`
function secret:decrypt(encrypted)
	local res, err
	res, err = ngx.decode_base64(encrypted); if not res then return nil, err end
	res, err = self:string_decrypt(res); if not res then return nil, err end
	return json.decode(res)
end

return secret
