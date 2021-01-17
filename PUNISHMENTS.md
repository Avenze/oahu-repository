# Welcome to the Oahu Punishment documentation file!

This document was written by Avenze, I'm going to document every possible reason to why you were/can be kicked/banned from Oahu. There are always 2 characters in front of the identifying number, the 2 characters can mean:

- NP : No Permission
- NE : Non Existant
- IA : Invalid Arguments
- UA : Unauthorized Action

# NP Documentation

- NP01 : You were kicked/banned for attempting to edit values of a vehicle that you do not own, neither are driving at that time.
- NP02 : You attempted to spawn a vehicle that you do not own, the vehiclemenu only shows purchased vehicles.
- NP03 : ~~You attempted to run the generatevehicles command without proper permissions being configured for you in the configurationdatatable.~~
- NP04 : The player attempted to purchase a vehicle that they already own, this is already sort of prevented in the InterfaceController, exploiter lmao
- NP05 : The player attempted to interact with an interactable that they do not have permission to interact with.

# NE Documentation

- NE01 : The vehicle that the player requested to spawn/purchase does not exist in the Vehicles folder in ReplicatedStorage.

# IA Documentation

- IA01 : The RemoteFunction that the player attempted to fire detected invalid arguments that were passed from the player.
- IA02 : The player fired invalid arguments to the CrossCommunicationHandler, that was later passed on to the interactionmodule, which detected them being invalid.
- IA03 : The arguments/parameters that were passed had been fiddled with, the event was manually fired by an exploiter most likely.
- IA04 : Tampering was detected while validating if a player has sat down at a workplace

# UA Documentation

- UA01 : The player attempted to join Oahu when a server whitelist was enabled, this should most likely only occour during the testing phases of Oahu.
