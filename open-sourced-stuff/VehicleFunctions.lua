--[[-------------------------------------------------------------------
---------------------- Information & Licensing ------------------------
-----------------------------------------------------------------------

	PROGRAMMER(S): UnlimitedKeeping / Avenze
	OWNER(S): Frostcloud Studios
	DETAILS: haha module go spawn vehicle
	LICENSE: GNU Affero General Public License v3.0

--]]-------------------------------------------------------------------
----------------- Variables & Services & Functions --------------------
-----------------------------------------------------------------------

local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local coregui = game:GetService("CoreGui")
local lighting = game:GetService("Lighting")
local replicated = game:GetService("ReplicatedStorage")
local serverscriptservice = game:GetService("ServerScriptService")
local serverstorage = game:GetService("ServerStorage")
local startergui = game:GetService("StarterGui")
local datastoreservice = game:GetService("DataStoreService")
local messagingservice = game:GetService("MessagingService")
local httpservice = game:GetService("HttpService")

local remotes = replicated.Remotes

-- /*/ Dependencies
local gameAnalytics = require(serverstorage:WaitForChild("GameAnalytics"))
local vehicleDatatable = require(replicated.Modules.Datatables:WaitForChild("VehicleDatatable"))
local controlsDatatable = require(replicated.Modules.Datatables:WaitForChild("VehicleDatatable"):WaitForChild("ControlsDatatable"))
local tuningDatatable = require(replicated.Modules.Datatables:WaitForChild("VehicleDatatable"):WaitForChild("TuningDatatable"))
local configurationDatatable = require(replicated.Modules.Datatables:WaitForChild("ConfigurationDatatable"))
local serverFunctions = require(replicated.Modules.Functions:WaitForChild("ServerFunctions"))
local datastoreFunctions = require(replicated.Modules.Functions.ServerFunctions.Modules:WaitForChild("DatastoreFunctions"))
local mathLibrary = require(replicated.Modules.Libraries:WaitForChild("MathLibrary"))

-- /*/ Datastores
local datastoreVersion = "865"
local playerDataDatastore = datastoreservice:GetDataStore("PlayerDataDatastore - " .. datastoreVersion)
	local backup_playerDataDatastore = datastoreservice:GetDataStore("BACKUP_PlayerDataDatastore - " .. datastoreVersion)
local vehicleRegistrationDatastore = datastoreservice:GetDataStore("VehicleRegistrationDatastore - " .. datastoreVersion)
	local backup_vehicleRegistrationDatastore = datastoreservice:GetDataStore("BACKUP_VehicleRegistrationDatastore - " .. datastoreVersion)
local existingVehiclesDatastore = datastoreservice:GetDataStore("ExistingVehiclesDatastore - " .. datastoreVersion)
	local backup_existingVehiclesDatastore = datastoreservice:GetDataStore("BACKUP_ExistingVehiclesDatastore - " .. datastoreVersion)

-- /*/ Internal Functions
local printDebug = function(debugMode, debugSide, debugMessage)
	local debugConfigurations = configurationDatatable.debugConfigurations
	if debugSide == "Server" then
		local debugStatuses = debugConfigurations["SERVER_DEBUGS"]
		if debugStatuses[debugMode] == true then
			print(debugMessage)
		end
	elseif debugSide == "Client" then
		local debugStatuses = debugConfigurations["CLIENT_DEBUGS"]
		if debugStatuses[debugMode] == true then
			print(debugMessage)
		end
	end
end

local functions = {}
local library = {}

-----------------------------------------------------------------------
------------------------------- Library -------------------------------
---------------------------------------------------------r--------------

--[[

	initialize vehicle:
		functions:initializeVehicle(vehicleName) - returns a model of the requested vehicle
		
	manage vehicle:
		functions:manageVehicle()

--]]

-- /*/ private functions
function library:configureDatastore(...)
	local arguments = {...}
	if arguments[1] == "VehicleRegistrationDatastore" then
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Configuring VehicleRegistrationDatastore key for player (" .. arguments[2].Name .. ")...")
		datastoreFunctions:SetDatastoreData(arguments[2], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, tostring("UID_" .. arguments[2].UserId), {})
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Finished configuring VehicleRegistrationDatastore key for player (" .. arguments[2].Name .. ").")
	elseif arguments[1] == "ExistingVehiclesDatastore" then
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Configuring ExistingVehiclesDatastore...")
		
		local existingVehicles, vehiclesConfiguration = {}, vehicleDatatable
		for vehicleName, vehicleConfiguration in pairs(vehiclesConfiguration) do
			if datastoreFunctions:GetDatastoreData(arguments[2], existingVehiclesDatastore, backup_existingVehiclesDatastore, vehicleName)["data"] == nil then
				printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Found an unloaded vehicle, loading the vehicle into the vehicle table.")
				datastoreFunctions:SetDatastoreData(arguments[2], existingVehiclesDatastore, backup_existingVehiclesDatastore, vehicleName, {})
			end
		end
		
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Finished configuring ExistingVehiclesDatastore!")
	end
end
function library:generateLicense()
	math.randomseed(tick())

	local numberToCharacters = {[0] = "A", [1] = "B", [2] = "C", [3] = "D", [4] = "E", [5] = "F", [6] = "G", [7] = "H", [8] = "I", [9] = "J", [10] = "K", [11] = "L", [12] = "M", [13] = "N", [14] = "O", [15] = "P", [16] = "Q", [17] = "R", [18] = "S", [19] = "T", [20] = "U", [21] = "V", [22] = "W", [23] = "X", [24] = "Y", [25] = "Z"}
	local randomizedCharacter1, randomizedCharacter2, randomizedCharacter3, randomizedCharacter4 = numberToCharacters[math.random(0, #numberToCharacters)], numberToCharacters[math.random(0, #numberToCharacters)], numberToCharacters[math.random(0, #numberToCharacters)], numberToCharacters[math.random(0, #numberToCharacters)]
	local randomizedNumber1, randomizedNumber2 = math.random(1,9), math.random(1,9)
	
	printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Configuring ExistingVehiclesDatastore...")
	return randomizedCharacter1 .. randomizedCharacter2 .. randomizedCharacter3 .. randomizedNumber1 .. randomizedNumber2 .. randomizedCharacter4
end
function functions:manageDatastore(...)
	local arguments = {...}
	if arguments[1] == "GenerateNewVehicle" then
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Starting generation of vehicles")
		for i = 1, tonumber(arguments[3]), 1 do
			local vehicleConstructor = ""
			if typeof(arguments[4]) == "Instance" then
				vehicleConstructor = tostring(arguments[4].UserId)
			elseif typeof(arguments[4]) == "string" and arguments[4] == "Server" then
				vehicleConstructor = "Government"
			end

			local licensePlate = library:generateLicense()
			local currentDateTable = os.date("*t", os.time()) 
			local registeredVehicleTable = {
				["CurrentVehicleOwner"] = 0, -- this is a user id
				["CurrentVehicleLicense"] = licensePlate,
				["CurrentVehicleDamage"] = 0, -- percentage of how broken the car is,
				["CurrentVehicleConstructor"] = vehicleConstructor,
				["VehicleModelName"] = arguments[2], -- the name of the car model
				["VehiclePurchaseDate"] = currentDateTable.year .. "/" .. currentDateTable.month .. "/" .. currentDateTable.day, -- this is a date of when the car was purchased
				["VehiclePurchasePrice"] = vehicleDatatable[arguments[2]]["VehiclePurchasePrice"],
				["VehicleModelColor"] = {["R"] = 255,  ["G"] = 255, ["B"] = 255},
				["VehicleModelColorType"] = "Standard",
				["VehicleFuelAmount"] = 100,
				["VehiclePurchased"] = false
			}

			-- /*/ saving to the datastore stuff lmao
			local data = datastoreFunctions:GetDatastoreData(arguments[4], existingVehiclesDatastore, backup_existingVehiclesDatastore, arguments[2])["data"]
			data[licensePlate] = {}

			datastoreFunctions:SetDatastoreData(arguments[4], existingVehiclesDatastore, backup_existingVehiclesDatastore, arguments[2], data)
			datastoreFunctions:SetDatastoreData(arguments[4], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, licensePlate, registeredVehicleTable)
			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Successfully generated vehicle " .. i .. " of " .. arguments[3] .. "!")
		end
	end
end

-- /*/ public functions
function functions:playerOwnsVehicle(...)
	local arguments = {...}
	local playerVehicleRegistration = datastoreFunctions:GetDatastoreData(arguments[1], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, "UID_" .. arguments[1].UserId)["data"]
	
	if not playerVehicleRegistration then
		library:configureDatastore("VehicleRegistrationDatastore", arguments[1])
		return {
			["status"] = "Player does not own specified vehicle!",
			["data"] = {}
		}
	else
		for license, data in pairs(playerVehicleRegistration) do
			if data["VehicleModelName"] == arguments[2] then
				return {
					["status"] = "Player owns specified vehicle.",
					["data"] = {
						["VehicleLicense"] = license,
						["VehicleModelName"] = data["VehicleModelName"],
						["CurrentVehicleOwner"] = data["CurrentVehicleOwner"]
					}
				}
			end
		end
	end
	
	return { -- this is mostly a fallback function, in case of the datastore being registered, but the player actually does not own the vehicle.
		["status"] = "Player does not own specified vehicle!",
		["data"] = {}
	}
end
function functions:purchaseVehicle(...)
	local arguments = {...}

	local existingVehiclesData = datastoreFunctions:GetDatastoreData(arguments[1], existingVehiclesDatastore, backup_existingVehiclesDatastore, arguments[2])["data"] -- the data is just a thing so that I can check status of the request too lol
	local vehicleRegistrationData = datastoreFunctions:GetDatastoreData(arguments[1], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, "UID_" .. arguments[1].UserId)["data"]
	local availableVehicle, availableVehicleLicense, owningVehicle, playerRegistered = false, "", true, false

	local rawData = {}

	-- /*/ perform check to see if there are any non purchased vehicles availible
	if existingVehiclesData then -- checking if the datastore is old or not
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: The ExistingVehiclesDatastore is up to date!")
		for license, licenseData in pairs(existingVehiclesData) do
			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Retrieving data regarding license: " .. license .. " from the datastore...")

			local licenseRawData = datastoreFunctions:GetDatastoreData(arguments[1], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, license)

			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Datastore retrieval status: " .. licenseRawData["status"])
			rawData = licenseRawData["data"]

			if licenseRawData["data"]["VehiclePurchased"] == false then
				availableVehicle = true
				availableVehicleLicense = license
			end
		end
	else
		library:configureDatastore("ExistingVehiclesDatastore", arguments[1]) -- the datastore is outdated, bruh
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") tried purchasing the vehicle from an outdated datastore!")
		return {
			["status"] = "Outdated datastore, try purchasing again.",
			["data"] = {}
		}
	end
	if availableVehicle == false and availableVehicleLicense == "" then
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") tried purchasing a vehicle that was out of stock!")
		return {
			["status"] = "The vehicle you requested to purchase is out of stock.",
			["data"] = {}
		}
	end

	-- /*/ perform check to see if the player already owns the requested vehicle
	if functions:playerOwnsVehicle(arguments[1], arguments[2])["status"] == "Player does not own specified vehicle!" then
		owningVehicle = false
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") does not own a vehicle!")
	elseif functions:playerOwnsVehicle(arguments[1], arguments[2])["status"] == "Player owns specified vehicle." then
		owningVehicle = true
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") already owns the vehicle they requested to purchase!")
		return {
			["status"] = "Player already owns the requested vehicle!",
			["data"] = {}
		}
	end

	-- /*/ perform check to see if the player has been registered in the registeredvehiclesdatastore.
	if vehicleRegistrationData then
		playerRegistered = true
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") is indeed registered in the VehicleRegistrationDatastore!")
	elseif vehicleRegistrationData == nil then
		library:configureDatastore("VehicleRegistrationDatastore", arguments[1])
		playerRegistered = false

		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") tried purchasing the vehicle from an outdated datastore!")
		return {
			["status"] = "Outdated datastore, try purchasing again.",
			["data"] = {}
		}
	end

	-- /*/ start purchase process
	if availableVehicle and availableVehicleLicense and not owningVehicle and playerRegistered then
		local vehicleLicense = availableVehicleLicense

		-- /*/ prepare the vehicle registration data stuff
		local currentDateTable = os.date("*t", os.time()) 
		local vehicleRegistrationTable = {
			["CurrentVehicleOwner"] = arguments[1].UserId,
			["CurrentVehicleLicense"] = vehicleLicense,
			["CurrentVehicleDamage"] = 0,
			["CurrentVehicleConstructor"] = rawData["CurrentVehicleConstructor"],
			["VehicleModelName"] = rawData["VehicleModelName"],
			["VehiclePurchaseDate"] = currentDateTable.year .. "/" .. currentDateTable.month .. "/" .. currentDateTable.day,
			["VehiclePurchasePrice"] = vehicleDatatable[arguments[2]]["VehiclePurchasePrice"],
			["VehicleModelColor"] = {["R"] = 255,  ["G"] = 255, ["B"] = 255},
			["VehicleModelColorType"] = "Standard",
			["VehicleFuelAmount"] = 100,
			["VehiclePurchased"] = true
		}
		local playerRegistrationTable = {
			["VehicleModelName"] = rawData["VehicleModelName"],
			["CurrentVehicleOwner"] = arguments[1].UserId
		}

		vehicleRegistrationData[vehicleLicense] = playerRegistrationTable
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Successfully configured the tables!")

		-- /*/ perform the economy related stuff, such as taking money and shit
		local purchaseInformation = serverFunctions:managePlayerEconomy(arguments[1], "Remove", vehicleDatatable[arguments[2]]["VehiclePurchasePrice"], "Bank", {"Gameplay", "Vehicle-" .. rawData["VehicleModelName"]})
		if purchaseInformation["status"] == "OK." then -- the player does indeed have enough money and is able to make the purchase
			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") has enough money to continue with the purchase!")
			vehicleRegistrationData[vehicleLicense] = playerRegistrationTable

			datastoreFunctions:SetDatastoreData(arguments[1], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, "UID_" .. arguments[1].UserId, vehicleRegistrationData)
			datastoreFunctions:SetDatastoreData(arguments[1], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, vehicleLicense, vehicleRegistrationTable)
			
			local vehicleRegistrationDatastoreStatus = mathLibrary:CalculatePercentage(string.len(httpservice:JSONEncode(vehicleRegistrationData)), 250000)
			local vehicleInformationDatakeyStatus = mathLibrary:CalculatePercentage(string.len(httpservice:JSONEncode(vehicleRegistrationTable)), 250000)

			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: The space in the players VehicleRegistrationDatastore is currently: " .. vehicleRegistrationDatastoreStatus .. "% used up!")
			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: The space used for the purchased vehicle is currently: " .. vehicleInformationDatakeyStatus .. "%!")

			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") successfully purchased the vehicle!")
			return {
				["status"] = "Successfully purchased vehicle!",
				["data"] = vehicleRegistrationTable
			}
		elseif purchaseInformation["status"] == "Not enough money!" then
			printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Player (" .. arguments[1].Name .. ") does not have enough money to complete purchase.")
			return {
				["status"] = "Player does not have enough money!",
				["data"] = {}
			}
		end
	else
		return {
			["status"] = "haha thing go fail",
			["data"] = {}
		}
	end
end
function functions:spawnVehicle(...)
	local arguments = {...}
	if vehicleDatatable[arguments[1]] then
		printDebug("Vehicle_Debugging", "Server", "[VehicleFunctions]: Vehicle (" .. arguments[1] .. ") is a valid vehicle!")
		
		local vehicleTuningInformation = {}
		local vehicleAssetsFolder = script.Parent.Parent.VehicleAssets
		
		for name, func in pairs(tuningDatatable) do
			if name == arguments[1] then vehicleTuningInformation = func() end
		end
		
		-- /*/ inserting vehicle function stuff
		local clonedVehicleModel = replicated.Assets.Vehicles[arguments[1]]:Clone()
		local driveSeatAssets = vehicleAssetsFolder.DriveSeat:GetChildren()
		
		vehicleAssetsFolder["A-Chassis Tune"]:Clone().Parent = clonedVehicleModel
		require(clonedVehicleModel["A-Chassis Tune"]).Tune = vehicleTuningInformation
		
		for _,asset in pairs(driveSeatAssets) do
			asset.Parent = clonedVehicleModel.DriveSeat
		end
		
		-- /*/ inserting/changing vehicle information
		local vehicleInformation = functions:playerOwnsVehicle(arguments[2], arguments[1])
		local vehicleDatastoreInfo = datastoreFunctions:GetDatastoreData(arguments[2], vehicleRegistrationDatastore, backup_vehicleRegistrationDatastore, vehicleInformation["data"]["VehicleLicense"])
		for _,instance in pairs(clonedVehicleModel["A-Chassis Tune"].Vehicle:GetChildren()) do
			if instance.Name == "VehicleModelColor" then
				instance.Value = Color3.fromRGB(vehicleDatastoreInfo["data"]["VehicleModelColor"]["R"], vehicleDatastoreInfo["data"]["VehicleModelColor"]["G"], vehicleDatastoreInfo["data"]["VehicleModelColor"]["B"])
			else
				instance.Value = vehicleDatastoreInfo["data"][instance.Name]
			end
		end
		
		-- /*/ inserting vehicle into workspace
		clonedVehicleModel:SetPrimaryPartCFrame(CFrame.new(arguments[2].Character.HumanoidRootPart.Position.X, (arguments[2].Character.HumanoidRootPart.Position.Y + 30), arguments[2].Character.HumanoidRootPart.Position.Z))
		clonedVehicleModel.Parent = workspace.Server.SpawnedVehicles
		clonedVehicleModel.Name = arguments[2].Name .. "'s Vehicle"
		
		return {
			["status"] = "Successfully spawned vehicle!",
			["data"] = {
				["VehicleModel"] = clonedVehicleModel,
				["VehicleModelCFrame"] = CFrame.new(arguments[2].Character.HumanoidRootPart.Position.X, (arguments[2].Character.HumanoidRootPart.Position.Y + 30), arguments[2].Character.HumanoidRootPart.Position.Z)
			}
		}
	else
		serverFunctions:punishPlayer("Kick", arguments[2].Name, "Non Existant | #NE01", "Server")
	end
end
